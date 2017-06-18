//
//  Photo+CoreDataClass.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-04-29.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
//    var photoLink {
//        didSet{
//            
//        }
//    }
    
    convenience init(vacationLocation: VacationLocation, title: String = "photoName", photoLink: String, thumbnail: NSData?, latitude: Double, longitude: Double, context: NSManagedObjectContext ) {
        
        //         An EntityDescription is an object that has access to all
        //         the information you provided in the Entity part of the model
        //         you need it to create an instance of this class.
        
            if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
                self.init(entity: ent, insertInto: context)
                
                self.vacationLocation = vacationLocation
                self.title = title
                self.photoLink = photoLink
                self.thumbnail = thumbnail
                self.creationDate = Date() as NSDate
                self.id = Int32(Date().timeIntervalSince1970)
                self.latitude = latitude
                self.longitude = longitude
                self.vacationLocationId = vacationLocation.id
            } else {
                fatalError("Unable to find Photo entity name")
            }

    }
        
}
