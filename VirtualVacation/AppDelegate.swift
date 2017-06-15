//
//  AppDelegate.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-04-29.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func checkIfFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            
            // Set the key for the first launch
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            // Set initial location for the first lounch at above the USA
            let mapViewRegionDictionary: [String : Double] = ["center_latitude" : 38.810508454750078,
                                       "center_longitude" : -98.632882194281535,
                                       "latitude_delta" : 79.009668524180711,
                                       "longitude_delta" : 64.605460338176371]
            
            UserDefaults.standard.set(mapViewRegionDictionary, forKey: "mapViewRegion")
            UserDefaults.standard.synchronize()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkIfFirstLaunch()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        UserDefaults.standard.synchronize()
        CoreDataStack.sharedInstance.saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        UserDefaults.standard.synchronize()
        CoreDataStack.sharedInstance.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.

        UserDefaults.standard.synchronize()
        CoreDataStack.sharedInstance.saveContext()
    }
}

