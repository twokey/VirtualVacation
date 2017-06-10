//
//  PicturesTableViewController.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-05-29.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PicturesTableViewController: CoreDataTableViewController {
    
    
    // MARK: Properites
    
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

    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photos"
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Photo.fetchRequest()
        
        // Configure Fetch Request
        let coordinatesArray = [locationCoordinate.latitude, locationCoordinate.longitude]
        let predicate = NSPredicate(format: "latitude = %@ AND longitude =%@", argumentArray: coordinatesArray)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        // Configure Fetched Results Controller
        fetchedResultsTableController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Download array of links to photos from Flickr
        FlickrClient.SharedInstance.getRandomPicturesURLListFor(locationCoordinate) { photoURLs in
                
            var objectsSaved = 1
            
            // Download pictures from urls array and populate Core Data table
            for photoURL in photoURLs {
                
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
                    
                    DispatchQueue.main.async {
                        
                        // Create photo and image objects
                        //let photo = Photo(context: self.sharedContext)
                        //let imageObject = Image(context: self.sharedContext)
                        let imageObject = Image(imageData: imageJPEGData as NSData, context: self.sharedContext)
                        
                        // Configure image object
                        //imageObject.fullResolution = imageJPEGData as NSData
                        //imageObject.photo = photo
            
                        // Configure photo object
//                        photo.vacationLocation = self.vacationLocation
//                        photo.title = "photoName"
//                        photo.image = imageObject
//                        photo.thumbnail = thumbnailJPEGData as NSData
//                        photo.creationDate = Date() as NSDate
//                        photo.id = Int32(Date().timeIntervalSince1970)
//                        photo.latitude = self.locationCoordinate.latitude
//                        photo.longitude = self.locationCoordinate.longitude
//                        photo.vacationLocationId = self.vacationLocation.id
                        
                        let photo = Photo(vacationLocation: self.vacationLocation, title: "No title", imageObject: imageObject, thumbnail: thumbnailJPEGData as NSData, latitude: self.locationCoordinate.latitude, longitude: self.locationCoordinate.longitude, context: self.sharedContext)
                        CoreDataStack.sharedInstance.saveContext()
                        objectsSaved += 1
                    }
                }
            }
            print("Objects saved: \(objectsSaved)")
        }
    }


    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
        let photo = fetchedResultsTableController?.object(at: indexPath) as! Photo
        let cellImage = UIImage(data: (photo.thumbnail as Data?)!)
        
        // Configure cell
        cell.imageView?.image = cellImage
        cell.textLabel?.text = String(photo.id)

        return cell
    }
    
}
