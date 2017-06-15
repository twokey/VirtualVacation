//
//  Photo+CoreDataProperties.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-05-30.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var thumbnail: NSData?
    @NSManaged public var title: String?
    @NSManaged public var photoLink: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var vacationLocationId: Int32
    @NSManaged public var image: Image?
    @NSManaged public var vacationLocation: VacationLocation?

}
