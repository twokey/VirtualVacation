//
//  VacationLocation+CoreDataProperties.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-05-30.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import CoreData


extension VacationLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VacationLocation> {
        return NSFetchRequest<VacationLocation>(entityName: "VacationLocation")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension VacationLocation {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
