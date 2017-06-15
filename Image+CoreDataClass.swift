//
//  Image+CoreDataClass.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-04-29.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    
    convenience init(imageData: NSData?, context: NSManagedObjectContext ) {
                
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        
        if let ent = NSEntityDescription.entity(forEntityName: "Image", in: context) {
            self.init(entity: ent, insertInto: context)
            self.fullResolution = imageData
//            self.photo = photo
        } else {
            fatalError("Unable to find Image entity name")
        }
    }

}
