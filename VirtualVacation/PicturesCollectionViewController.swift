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
        title = "Location Photos"
        noPhotosLabel.isHidden = true
        reloadPhotosButton.isEnabled = false

        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if (fetchedResultsCollectionController?.fetchedObjects?.count)! > 0 {
            downloadPhotos()
        } else {
            print("There is no photo!")
            noPhotosLabel.isHidden = false
            reloadPhotosButton.isEnabled = true
        }
    }


    func downloadPhotos() {
    
        self.reloadPhotosButton.isEnabled = false
        
        for result in (fetchedResultsCollectionController?.fetchedObjects)! {
            
            let photo = result as! Photo
            
            FlickrClient.SharedInstance.getPicturesFor(photo: photo) { (data, image, error) in
                guard error == nil else {
                    print(error ?? "")
                    return
                }
                photo.thumbnail = data! as NSData
                CoreDataStack.sharedInstance.saveContext()
            }
        }
        
        self.reloadPhotosButton.isEnabled = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PicturesCollectionViewCell
        
        cell.cellImageView?.image = nil
        cell.cellImageView?.alpha = 1.0
        
        let photo = fetchedResultsCollectionController?.object(at: indexPath) as! Photo
        
        if let data = photo.thumbnail as Data? {

            let cellImage = UIImage(data: data)
            // Configure cell
            cell.cellImageView?.image = cellImage
            cell.activityIndicator.stopAnimating()
        }
        else {
            cell.activityIndicator.startAnimating()
         }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        sharedContext.delete(fetchedResultsCollectionController?.object(at: indexPath) as! Photo)
        CoreDataStack.sharedInstance.saveContext()
        
    }

    func updatePhotoAlbum() {
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: vacationLocation.latitude, longitude: vacationLocation.longitude)
        
        FlickrClient.SharedInstance.getRandomPicturesURLListFor(locationCoordinate) { (photoURLsDownloaded, error) in
            
            guard let photoURLs = photoURLsDownloaded, photoURLs.count > 0  else {
                print("No photo URL was downloaded")
                return
            }
            
            DispatchQueue.main.async {
                // Download pictures from urls array and populate Core Data table
                for photoURL in photoURLs {
                    
                    // Create photo and image objects
                    let _ = Photo(vacationLocation: self.vacationLocation, title: "No title", photoLink: photoURL.absoluteString, thumbnail: nil, latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, context: self.sharedContext)
                }
                CoreDataStack.sharedInstance.saveContext()
                self.executeSearch()
                self.downloadPhotos()
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
        updatePhotoAlbum()
    }
}
