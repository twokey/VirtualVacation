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

class PicturesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    // MARK: Properites
    
//    var coordinates: CLLocationCoordinate2D!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
 //   var photos = [Photo]()
    var sharedContext = CoreDataStack.sharedInstance().persistentContainer.viewContext
    
//    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Photo> = {
//        
//        // Create Fetch Request
//        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
//        let latitude = coordinates.latitude
//        
//        //let fetchRequestPredicate = NSPredicate(format: "latitude = %@", argumentArray: [coordinates.latitude])
//        
//        // Configure Fetch Request
//        fetchRequest.sortDescriptors = []
//        
//        // Create Fetched Results Controller
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
//        
//        // Configure Fetched Results Controller
//        fetchedResultsController.delegate = self
//        
//        return fetchedResultsController
//    }()
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get Core Data stack
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        
//        let context = appDelegate.persistentContainer.viewContext
//        do {
//            photos = try sharedContext.fetch(Photo.fetchRequest())
//        } catch {
//            print("Image fetch failed")
//        }
        
//        for location in vacationLocations {
//            let annotation = MKPointAnnotation()
//            
//            // locationVacation.latitude can be nil this line can fail
//            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//            annotation.title = location.title
//            annotation.subtitle = location.subtitle
//            mapView.addAnnotation(annotation)
//        }
        
        // Start the Fetched Resudlt Controller
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error performing initial fetch: \(error)")
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
        let photo = fetchedResultsController.object(at: indexPath)

        // Configure the cell...
        print(photo)
        print(photo.id)
        
        cell.textLabel?.text = String(photo.id)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
