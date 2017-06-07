//
//  CoreDataStack.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-05-30.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> CoreDataStack {
        struct Static {
            static let instance = CoreDataStack()
        }
        
        return Static.instance
    }
    
    
    // MARK: The Core Data stack. The code has been moved, unaltered, from AppDelegate
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "VirtualVacation")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror)")
            }
        }
    }
    
    func dropAllData() throws {
        
        if let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first!.url {
            // Delete all the objects in the db. This won't delete the files, it will just leave empty tables
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            try persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        }
    }
    
    
    // MARK: - Path to the SQLite file on device
    
    func applicationDocumentsDirectory() {
//        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
//            print(url.absoluteString)
//        }
        
        if let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first!.url {
            // get me path to the database file
            print("Path to the store: \(storeURL)")
        }

    }

}
