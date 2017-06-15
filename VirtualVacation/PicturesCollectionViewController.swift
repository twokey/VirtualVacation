//
//  PicturesCollectionViewController.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-06-04.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import CoreData
import MapKit

private let reuseIdentifier = "CollectionCell"

class PicturesCollectionViewController: CoreDataCollectionViewController {

    
    // MARK: Properties
    
    var sharedContext = CoreDataStack.sharedInstance.persistentContainer.viewContext
    var locationCoordinate = CLLocationCoordinate2D()

    var photos = [Photo]()
    
    fileprivate lazy var vacationLocation: VacationLocation = {
        
        // Create Fetch Request
        let fr: NSFetchRequest<VacationLocation> = VacationLocation.fetchRequest()
        
        // Configure Fetch Request
        let coordinatesArray = [self.locationCoordinate.latitude, self.locationCoordinate.longitude]
        let predicate = NSPredicate(format: "latitude = %@ AND longitude =%@", argumentArray: coordinatesArray)
        fr.predicate = predicate
        fr.sortDescriptors = []
        
        // Create Fetched Results Controller
        let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try frc.performFetch()
        } catch let error as NSError {
            print("Error performing initial fetch \(error)")
        }
        
        return frc.fetchedObjects!.first!
    }()
    
    
    // MARK: Outlets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var reloadPhotosButton: UIButton!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var deletePhotosButton: UIBarButtonItem!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up UI
        collectionView = photosCollectionView
        title = "Photosss"
        self.noPhotosLabel.isHidden = true
        self.reloadPhotosButton.isEnabled = false
        configureInterface(selectedIndexes.count)
        
        // Set up Collection View Controller
        let space: CGFloat = 3.0
        let itemsRow: CGFloat = 3.0
        let dimension = (view.frame.size.width - ((itemsRow - 1.0) * space)) / itemsRow
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // Create and configure fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Photo.fetchRequest()
        let coordinatesArray = [self.locationCoordinate.latitude, self.locationCoordinate.longitude]
        let predicate = NSPredicate(format: "latitude = %@ AND longitude =%@", argumentArray: coordinatesArray)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        do {
            self.photos = try sharedContext.fetch(fetchRequest) as! [Photo]
        } catch let e as NSError{
            print("Can't execure fetch request \n\(e)")
        }
        
        // Configure Fetched Results Controller
        fetchedResultsCollectionController = NSFetchedResultsController(fetchRequest: fetchRequest , managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsCollectionController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if photos.count > 0 {
            downloadPhotos(photos)
        } else {
            print("There is no photo!")
            self.reloadPhotosButton.isEnabled = true
        }

    }


    func downloadPhotos(_ photos: [Photo]) {
        
        self.reloadPhotosButton.isEnabled = false
        
        for photo in photos {
        
            if photo.thumbnail == nil {
                let photoURL = URL(string: photo.photoLink)!
                // Download pictures from urls array and populate Core Data table

                if let imageData = try? Data(contentsOf: photoURL) {
                
                    let image = UIImage(data: imageData)!
                    guard let imageJPEGData = UIImageJPEGRepresentation(image, 1.0) else {
                        print("Image conversion to JPEG failed")
                        return
                    }

                    let thumbnail = image.scale(toSize: self.view.frame.size)
                    guard let thumbnailJPEGData = UIImageJPEGRepresentation(thumbnail, 0.7) else {
                        print("Thumbnail conversion to JPEG failed")
                        return
                    }
                    // Update photo and image objects
                    photo.thumbnail = thumbnailJPEGData as NSData
                }

                CoreDataStack.sharedInstance.saveContext()
            }

        }
        
        self.reloadPhotosButton.isEnabled = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PicturesCollectionViewCell
        
        let photo = fetchedResultsCollectionController?.object(at: indexPath) as! Photo
        
        if let data = photo.thumbnail as Data? {
            let cellImage = UIImage(data: data)
            // Configure cell
            cell.cellImageView?.image = cellImage
            cell.activityIndicator.stopAnimating()
        }
        
        return cell
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsCollectionController?.object(at: indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.delete(photo)
        }
        
        selectedIndexes = [IndexPath]()
    }
    
    override func configureInterface(_ cellSelected: Int) {
        switch cellSelected {
        case 0:
            deletePhotosButton.isEnabled =  false
        default:
            deletePhotosButton.isEnabled = true
        }
    }

    
    // MARK: Actions
    
    @IBAction func updateAlbum(_ sender: UIButton) {
        
        // Clean table Photo (and Images)
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Photo.fetchRequest()
        let coordinatesArray = [self.locationCoordinate.latitude, self.locationCoordinate.longitude]
        let predicate = NSPredicate(format: "latitude = %@ AND longitude =%@", argumentArray: coordinatesArray)
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            _ = try sharedContext.execute(deleteRequest)
        } catch {
            print("Couldn't clean the Photo entity")
        }

        updatePhotoAlbumFor()
        
    }
    
    func updatePhotoAlbumFor() {
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: vacationLocation.latitude, longitude: vacationLocation.longitude)
        
        FlickrClient.SharedInstance.getRandomPicturesURLListFor(locationCoordinate) { (photoURLsDownloaded, error) in
            
            guard let photoURLs = photoURLsDownloaded, photoURLs.count > 0  else {
                print("No photo URL was downloaded")
                return
            }
            
            let photosAvailable = photoURLs.count
            let maximumPhotos = 30
            
            // Set limit for the number of photos for loading
            let photosDownloadLimit = min(photosAvailable, maximumPhotos)
            var photosDownloaded = 0
            
            // Download pictures from urls array and populate Core Data table
            for photoURL in photoURLs {
                
                // Create photo and image objects
                let imageObject = Image(imageData: nil, context: self.sharedContext)
                let _ = Photo(vacationLocation: self.vacationLocation, title: "No title", photoLink: photoURL.absoluteString, imageObject: imageObject, thumbnail: nil, latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, context: self.sharedContext)
                
                photosDownloaded += 1
                
                if photosDownloaded >= photosDownloadLimit {
                    break
                }
            }
            
            CoreDataStack.sharedInstance.saveContext()
            
            DispatchQueue.main.async {
                
                // Create and configure fetch request
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Photo.fetchRequest()
                let coordinatesArray = [self.locationCoordinate.latitude, self.locationCoordinate.longitude]
                let predicate = NSPredicate(format: "latitude = %@ AND longitude =%@", argumentArray: coordinatesArray)
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = []
                
                do {
                    self.photos = try self.sharedContext.fetch(fetchRequest) as! [Photo]
                } catch let e as NSError{
                    print("Can't execure fetch request \n\(e)")
                }

                self.downloadPhotos(self.photos)
                
            }
        }
    }

    
    @IBAction func deleteSelectedPhotosAction(_ sender: UIBarButtonItem) {
        
        deleteSelectedPhotos()
        self.collectionView?.reloadData()
        
    }
}


// MARK: - CGSize extension

extension CGSize {
    
    func resizeFill(toSize: CGSize) -> CGSize {
        
        let scale : CGFloat = (self.height / self.width) < (toSize.height / toSize.width) ? (self.height / toSize.height) : (self.width / toSize.width)
        return CGSize(width: (self.width / scale), height: (self.height / scale))
    }
}


// MARK: - UIImage extension

extension UIImage {
    
    func scale(toSize newSize:CGSize) -> UIImage {
        
        // make sure the new size has the correct aspect ratio
        let aspectFill = self.size.resizeFill(toSize: newSize)
        
        UIGraphicsBeginImageContextWithOptions(aspectFill, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: aspectFill.width, height: aspectFill.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
