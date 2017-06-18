//
//  CoreDataCollectionViewController.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-06-07.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import CoreData
import UIKit


// MARK: - CoreDataCollectionViewController

class CoreDataCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    // MARK: Properties
    
    var collectionView: UICollectionView?
    
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searching through the code for 'selectedIndexes'
    var selectedIndexes = [IndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var fetchedResultsCollectionController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and reload the table
            executeSearch()
            self.collectionView?.reloadData()
        }
    }
    
    
    // MARK: Initializers
    
    // This initializer has to be implemented because of the way Swift interfaces with NSArchiving.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let frc = fetchedResultsCollectionController  {
            return (frc.sections?.count)!
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let frc = fetchedResultsCollectionController {
            return frc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    
    // MARK: - CoreDataCollectionViewController (Subclass Must Implement)
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionViewController")
    }

    
    // MARK: Helpers
    
    func executeSearch() {
        if let frc = fetchedResultsCollectionController {
            do {
                try frc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)")
            }
        }
    }    
}


extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
    
    
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            // Here we are noting that a new instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            // Here we are noting that a Color instance has been deleted from Core Data. We remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an image is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    // This method is invoked after all of the changed objects in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        updateCollectionView()
        
    }
    
    func updateCollectionView() {
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
