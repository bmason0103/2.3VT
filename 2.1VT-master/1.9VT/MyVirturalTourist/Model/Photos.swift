//
//  Photos.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 12/9/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

@objc(Photos)
public class Photos: NSManagedObject {
    
    static let name = "Photos"
    
    convenience init(title: String, imageUrl: String, forPin: ThePin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Photos.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.image = nil
            self.urlImage = imageUrl
            self.ThePin = forPin
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var urlImage: String?
    @NSManaged public var ThePin: ThePin?

}
