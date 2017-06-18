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

//    var photos = [Photo]()
    
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
        //photosCollectionView = collectionView
        title = "Location Photos"
        self.noPhotosLabel.isHidden = true
        self.reloadPhotosButton.isEnabled = false
//        configureDeleteButton(selectedIndexes.count)
        
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
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        // Configure Fetched Results Controller
        fetchedResultsCollectionController = NSFetchedResultsController(fetchRequest: fetchRequest , managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsCollectionController?.delegate = self
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
    

            
        
//        for result in (self.fetchedResultsCollectionController?.fetchedObjects)! {
//            
//            let indexPath = self.fetchedResultsCollectionController?.indexPath(forObject: result)
//            print(indexPath)
//            let photo = result as! Photo
//            
//            
//            if photo.thumbnail == nil {
//                
  //              let photoURL = URL(string: photo.photoLink)!
                
                
                // Download pictures from urls array and populate Core Data table
                
//                let imageData = try? Data(contentsOf: photoURL)
//                let imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "Photo-1"), 1.0)
        //        sharedContext.performAndWait {
                    
//                                    photo.thumbnail = imageData! as NSData
          //      }
//                print(imageData!)
                
                //photo.thumbnail = imageData! as NSData
//                CoreDataStack.sharedInstance.saveContext()
//                self.executeSearch()
//                
//            }
//        }

//        if (fetchedResultsCollectionController?.fetchedObjects?.count)! > 0 {
//            downloadPhotos()
//        } else {
//            print("There is no photo!")
//            self.reloadPhotosButton.isEnabled = true
//        }

 //   }


//    func downloadPhotos() {
//        
//        self.reloadPhotosButton.isEnabled = false
//        
//        for result in (fetchedResultsCollectionController?.fetchedObjects)! {
//            
//            let indexPath = fetchedResultsCollectionController?.indexPath(forObject: result)
//            print(indexPath)
//            let photo = result as! Photo
//            
//            
//            if photo.thumbnail == nil {
//                
//                let photoURL = URL(string: photo.photoLink)!
//                
//                // Download pictures from urls array and populate Core Data table
//                
//                let imageData = try? Data(contentsOf: photoURL)
//                
//                print(imageData!)
//                
//                photo.thumbnail = imageData! as NSData
//                CoreDataStack.sharedInstance.saveContext()
//                self.executeSearch()
//                
//         
//            }
//
//        }
//        
//        self.reloadPhotosButton.isEnabled = true
//    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("providing cell at index path \(indexPath)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PicturesCollectionViewCell
        
        DispatchQueue.main.async {
            cell.cellImageView?.image = nil
        }
        
        let photo = fetchedResultsCollectionController?.object(at: indexPath) as! Photo
        
        if let data = photo.thumbnail as Data? {
            DispatchQueue.main.async {
            let cellImage = UIImage(data: data)
            // Configure cell
            print(data)
            cell.cellImageView?.image = cellImage
            cell.activityIndicator.stopAnimating()

            }

        } else {
            print("no image data")
            cell.activityIndicator.startAnimating()
            FlickrClient.SharedInstance.getPicturesFor(indexPath, photo: photo) { (data, image, error) in
                guard error == nil else {
                    print(error)
                    return
                }
                DispatchQueue.main.async {
                    cell.cellImageView?.image = image
                    cell.activityIndicator.stopAnimating()
                }
                photo.thumbnail = data! as NSData
                CoreDataStack.sharedInstance.saveContext()
            }
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
        
        CoreDataStack.sharedInstance.saveContext()
        
        selectedIndexes = [IndexPath]()

    }
    
    func updatePhotoAlbumFor() {
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: vacationLocation.latitude, longitude: vacationLocation.longitude)
        
        FlickrClient.SharedInstance.getRandomPicturesURLListFor(locationCoordinate) { (photoURLsDownloaded, error) in
            
            guard let photoURLs = photoURLsDownloaded, photoURLs.count > 0  else {
                print("No photo URL was downloaded")
                return
            }
            
            print(photoURLs)
            
            DispatchQueue.main.async {
                // Download pictures from urls array and populate Core Data table
                for photoURL in photoURLs {
                    
                    // Create photo and image objects
                    let _ = Photo(vacationLocation: self.vacationLocation, title: "No title", photoLink: photoURL.absoluteString, thumbnail: nil, latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, context: self.sharedContext)
                    print(photoURL)
                    
                }
                CoreDataStack.sharedInstance.saveContext()
                self.executeSearch()
//                self.collectionView!.reloadData()
//                self.downloadPhotos()
                
            }
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

        executeSearch()
        collectionView!.reloadData()
        updatePhotoAlbumFor()
    }
    
    @IBAction func deleteSelectedPhotosAction(_ sender: UIBarButtonItem) {
        
        deleteSelectedPhotos()
//        self.collectionView?.reloadData()
        
    }
}
