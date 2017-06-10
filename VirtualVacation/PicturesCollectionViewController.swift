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
    var backgroundContext = CoreDataStack.sharedInstance.backgroundContext
    var locationCoordinate = CLLocationCoordinate2D()
    var photosAvailable = 0
    
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
//    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photosss"
        
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
        
        // Configure Fetched Results Controller
        fetchedResultsCollectionController = NSFetchedResultsController(fetchRequest: fetchRequest , managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsCollectionController?.delegate = self
        
        if let frc = fetchedResultsCollectionController, frc.sections![0].numberOfObjects == 0 {
        

            print("NNumber of items: \(frc.sections![0].numberOfObjects)")


        // Download array of links to photos from Flickr
        CoreDataStack.sharedInstance.performBackgroundBatchOperation() {_ in 
            FlickrClient.SharedInstance.getRandomPicturesURLListFor(self.locationCoordinate) { photoURLs in
    
                self.photosAvailable = photoURLs.count
    
                // Download pictures from urls array and populate Core Data table
                for photoURL in photoURLs {
    
                    if let imageData = try? Data(contentsOf: photoURL) {
                
                        let image = UIImage(data: imageData)!
           //         let image = #imageLiteral(resourceName: "Photo-1")
                        guard let imageJPEGData = UIImageJPEGRepresentation(image, 1.0) else {
                            print("Image conversion to JPEG failed")
                            return
                        }
    
                        let thumbnail = image.scale(toSize: self.view.frame.size)
                        guard let thumbnailJPEGData = UIImageJPEGRepresentation(thumbnail, 0.7) else {
                            print("Thumbnail conversion to JPEG failed")
                            return
                        }
                        
                        DispatchQueue.main.async {
    
                            // Create photo and image objects
                            let imageObject = Image(imageData: imageJPEGData as NSData, context: self.sharedContext)
                            let photo = Photo(vacationLocation: self.vacationLocation, title: "No title", imageObject: imageObject, thumbnail: thumbnailJPEGData as NSData, latitude: self.locationCoordinate.latitude, longitude: self.locationCoordinate.longitude, context: self.sharedContext)
                            CoreDataStack.sharedInstance.saveContext()
                        }
//                        objectsSaved += 1
                    }
                }
 //               print("Objects saved: \(objectsSaved)")
            }
        }
                    }
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PicturesCollectionViewCell
        
            let photo = fetchedResultsCollectionController?.object(at: indexPath) as! Photo
            let cellImage = UIImage(data: (photo.thumbnail as Data?)!)
        
            // Configure cell
            cell.cellImageView?.image = cellImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let frc = fetchedResultsCollectionController {
            print("Number of items: \(frc.sections![section].numberOfObjects)")
            return frc.sections![section].numberOfObjects
        } else {
            print("Photos available: \(self.photosAvailable)")
            return photosAvailable

        }
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

