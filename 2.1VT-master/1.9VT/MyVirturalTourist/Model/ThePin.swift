//
//  Pin.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/18/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

@objc(ThePin)
public class ThePin: NSManagedObject {
    
    static let name = "ThePin"
    
    
    convenience init(latitude: String, longitude: String, context: NSManagedObjectContext) {
      
        if let ent = NSEntityDescription.entity(forEntityName: ThePin.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}

extension ThePin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThePin> {
        return NSFetchRequest<ThePin>(entityName: "ThePin")
    }

    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension ThePin {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photos)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photos)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
