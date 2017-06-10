//
//  CoreDataManager.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-06-07.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import UIKit



class CoreDataManager {


    // MARK: Properties

//    private let managedObjectContext: NSManagedObjectContext
//    var locationCoordinate: CLLocationCoordinate2D
//    
//    fileprivate lazy var vacationLocation: VacationLocation = {
//        
//        // Create Fetch Request
//        let fetchRequest: NSFetchRequest<VacationLocation> = VacationLocation.fetchRequest()
//        
//        // Configure Fetch Request
//        let coordinatesArray = [self.locationCoordinate.latitude, self.locationCoordinate.longitude]
//        let predicate = NSPredicate(format: "latitude = %@ AND longitude =%@", argumentArray: coordinatesArray)
//        fetchRequest.predicate = predicate
//        fetchRequest.sortDescriptors = []
//        
//        // Create Fetched Results Controller
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//        do {
//            try fetchedResultsController.performFetch()
//        } catch let error as NSError {
//            print("Error performing initial fetch \(error)")
//        }
//        
//        return fetchedResultsController.fetchedObjects!.first!
//    }()
//
    
    // MARK: Initializers
    
//    init(locationCoordinate: CLLocationCoordinate2D, managedObjectContext: NSManagedObjectContext) {
//        self.managedObjectContext = managedObjectContext
//        self.locationCoordinate = locationCoordinate
//        
//        super.init()
//    }
    
    // Shared instance
    static let SharedInstance = FlickrClient()

//    var sharedContext = CoreDataStack.sharedInstance().persistentContainer.viewContext

    // Download array of links to photos from Flickr
//    override func main() {
//
//        FlickrClient.SharedInstance.getRandomPicturesURLListFor(locationCoordinate) { photoURLs in
//
//            var objectsSaved = 1
//
//            // Download pictures from urls array and populate Core Data table
//            for photoURL in photoURLs {
//
//                if let imageData = try? Data(contentsOf: photoURL) {
//
//                    let image = UIImage(data: imageData)!
//                    guard let imageJPEGData = UIImageJPEGRepresentation(image, 1.0) else {
//                        print("Image conversion to JPEG failed")
//                        return
//                    }
//
////                    let thumbnail = image.scale(toSize: self.view.frame.size)
//                    let frameSize = CGSize(width: 100, height: 100)
//                    let thumbnail = image.scale(toSize: frameSize)
//
//                    guard let thumbnailJPEGData = UIImageJPEGRepresentation(thumbnail, 0.7) else {
//                        print("Thumbnail conversion to JPEG failed")
//                        return
//                    }
//
//
//
//                    // Create photo and image objects
//                    let imageObject = Image(imageData: imageJPEGData as NSData, context: self.managedObjectContext)
//                    let photo = Photo(vacationLocation: self.vacationLocation, title: "No title", imageObject: imageObject, thumbnail: thumbnailJPEGData as NSData, latitude: self.locationCoordinate.latitude, longitude: self.locationCoordinate.longitude, context: self.managedObjectContext)
//                    self.saveChanges()
//                    objectsSaved += 1
//
//                }
//            }
//            print("Objects saved: \(objectsSaved)")
//        }
//    }
//    
//    private func saveChanges() {
//        managedObjectContext.performAndWait({
//            do {
//                if self.managedObjectContext.hasChanges {
//                    try self.managedObjectContext.save()
//                }
//            } catch let error as NSError {
//                print("Unable to Save Changes of Managed Object Context \n \(error)")
//                //print("\(saveError)")
//            }
//        })
//    }
//}


//class CoreDataManager {
//    
//    
//    // MARK: Properties
//    
//    // Shared instance
//    static let SharedInstance = FlickrClient()
//
//    var sharedContext = CoreDataStack.sharedInstance().persistentContainer.viewContext
//    var locationCoordinate = CLLocationCoordinate2D()
//    
//    fileprivate lazy var vacationLocation: VacationLocation = {
//        
//        // Create Fetch Request
//        let fr: NSFetchRequest<VacationLocation> = VacationLocation.fetchRequest()
//        
//        // Configure Fetch Request
//        let coordinatesArray = [self.locationCoordinate.latitude, self.locationCoordinate.longitude]
//        let predicate = NSPredicate(format: "latitude = %@ AND longitude =%@", argumentArray: coordinatesArray)
//        fr.predicate = predicate
//        fr.sortDescriptors = []
//        
//        // Create Fetched Results Controller
//        let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
//        do {
//            try frc.performFetch()
//        } catch let error as NSError {
//            print("Error performing initial fetch \(error)")
//        }
//        
//        return frc.fetchedObjects!.first!
//    }()
//    
//    // Download array of links to photos from Flickr
//    func downloadPhotos() {
//        
//        FlickrClient.SharedInstance.getRandomPicturesURLListFor(locationCoordinate) { photoURLs in
//    
//            var objectsSaved = 1
//    
//            // Download pictures from urls array and populate Core Data table
//            for photoURL in photoURLs {
//            
//                if let imageData = try? Data(contentsOf: photoURL) {
//            
//                    let image = UIImage(data: imageData)!
//                    guard let imageJPEGData = UIImageJPEGRepresentation(image, 1.0) else {
//                        print("Image conversion to JPEG failed")
//                        return
//                    }
//            
////                    let thumbnail = image.scale(toSize: self.view.frame.size)
//                    let frameSize = CGSize(width: 100, height: 100)
//                    let thumbnail = image.scale(toSize: frameSize)
//                    
//                    guard let thumbnailJPEGData = UIImageJPEGRepresentation(thumbnail, 0.7) else {
//                        print("Thumbnail conversion to JPEG failed")
//                        return
//                    }
//            
//                    DispatchQueue.main.async {
//            
//                        // Create photo and image objects
//                        let imageObject = Image(imageData: imageJPEGData as NSData, context: self.sharedContext)
//                        let photo = Photo(vacationLocation: self.vacationLocation, title: "No title", imageObject: imageObject, thumbnail: thumbnailJPEGData as NSData, latitude: self.locationCoordinate.latitude, longitude: self.locationCoordinate.longitude, context: self.sharedContext)
//                        CoreDataStack.sharedInstance().saveContext()
//                        objectsSaved += 1
//                    }
//                }
//            }
//            print("Objects saved: \(objectsSaved)")
//        }
//    }
}

// MARK: - CGSize extension
//
//extension CGSize {
//    
//    func resizeFill(toSize: CGSize) -> CGSize {
//        
//        let scale : CGFloat = (self.height / self.width) < (toSize.height / toSize.width) ? (self.height / toSize.height) : (self.width / toSize.width)
//        return CGSize(width: (self.width / scale), height: (self.height / scale))
//    }
//}
//
//
//// MARK: - UIImage extension
//
//extension UIImage {
//    
//    func scale(toSize newSize:CGSize) -> UIImage {
//        
//        // make sure the new size has the correct aspect ratio
//        let aspectFill = self.size.resizeFill(toSize: newSize)
//        
//        UIGraphicsBeginImageContextWithOptions(aspectFill, false, 0.0);
//        self.draw(in: CGRect(x: 0, y: 0, width: aspectFill.width, height: aspectFill.height))
//        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
//    
//}
//
