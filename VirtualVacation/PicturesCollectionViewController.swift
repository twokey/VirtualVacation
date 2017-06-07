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

class PicturesCollectionViewController: UICollectionViewController {

    
    // MARK: Properties
    
    var sharedContext = CoreDataStack.sharedInstance().persistentContainer.viewContext
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
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searching through the code for 'selectedIndexes'
    var selectedIndexes = [IndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!

    var fetchedResultsController: NSFetchedResultsController<Photo>? {
        didSet {
            // Whenever the frc changes, we execute the search and reload the table
            executeSearch()
            self.collectionView?.reloadData()
            print("Collection view reloaded")
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photosss"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
 //       self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        
        let space: CGFloat = 3.0
        let itemsRow: CGFloat = 2.0
        let dimension = (view.frame.size.width - ((itemsRow - 1.0) * space)) / itemsRow
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        // Configure Fetch Request
        let coordinatesArray = [self.locationCoordinate.latitude, self.locationCoordinate.longitude]
        let predicate = NSPredicate(format: "latitude = %@ AND longitude =%@", argumentArray: coordinatesArray)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        // Configure Fetched Results Controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
//        do {
//            try fetchedResultsController?.performFetch()
//        } catch let error as NSError {
//            print("Error performing initial fetch \(error)")
//        }
        
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
                        let imageObject = Image(imageData: imageJPEGData as NSData, context: self.sharedContext)
                        let photo = Photo(vacationLocation: self.vacationLocation, title: "No title", imageObject: imageObject, thumbnail: thumbnailJPEGData as NSData, latitude: self.locationCoordinate.latitude, longitude: self.locationCoordinate.longitude, context: self.sharedContext)
                        CoreDataStack.sharedInstance().saveContext()
                        objectsSaved += 1
                    }
                }
            }
            print("Objects saved: \(objectsSaved)")
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let frc = fetchedResultsController  {
            print("Number of sections: \((frc.sections?.count)!)")
            return (frc.sections?.count)!
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let frc = fetchedResultsController {
            print("Number of items: \(frc.sections![section].numberOfObjects)")
            return frc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PicturesCollectionViewCell
        
        if let frc = fetchedResultsController {
            
            let photo = frc.object(at: indexPath)
            let cellImage = UIImage(data: (photo.thumbnail as Data?)!)
        
            // Configure cell
//            cell.backgroundView?.backgroundColor = UIColor.black
            cell.cellImageView?.image = cellImage
        } else {
            cell.cellImageView?.image = #imageLiteral(resourceName: "Photo-1")
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("in collectionView(_:didSelectItemAtIndexPath)")
        let cell = collectionView.cellForItem(at: indexPath) as! PicturesCollectionViewCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        // Then reconfigure the cell
        configureCell(cell, atIndexPath: indexPath)
        
        // And update the buttom button
//        updateBottomButton()
    }
    
    func executeSearch() {
        if let frc = fetchedResultsController {
            do {
                try frc.performFetch()
                print("fetch is performed")
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }

    
    func configureCell(_ cell: PicturesCollectionViewCell, atIndexPath indexPath: IndexPath) {
        print("in configureCell")
//        let color = self.fetchedResultsController.object(at: indexPath)
        
//        cell.color = color.value
//        cell.rgbLabel.text = String(describing: color.value)
//        print(String(describing: color.value))
        
        // If the cell is "selected", its color panel is grayed out
        // we use the Swift `find` function to see if the indexPath is in the array
        
        if let _ = selectedIndexes.index(of: indexPath) {
            cell.cellImageView?.alpha = 0.05
        } else {
            cell.cellImageView?.alpha = 1.0
        }
    }

    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */

}

extension PicturesCollectionViewController: NSFetchedResultsControllerDelegate {

    
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        
        print("in controllerWillChangeContent")
    }

    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an image is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
            //default:
            //break
        }
    }
    
    // This method is invoked after all of the changed objects in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        self.collectionView?.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView?.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView?.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView?.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }


}
    




