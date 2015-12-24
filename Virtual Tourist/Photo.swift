//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/10/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    struct Keys {
        static let Title = "title"
        static let ID = "id"
        static let ImageURL = "url_z"
    }
    
    @NSManaged var title: String
    @NSManaged var id: NSNumber
    @NSManaged var imageURLString: String
    @NSManaged var pin: Pin?
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Initialize entity for Core Data context
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        title = dictionary[Keys.Title] as! String
        if title == "" {
            title = "Untitled"
        }
        id = Int(dictionary[Keys.ID] as! String)!
        imageURLString = dictionary[Keys.ImageURL] as! String
    }
    
//    var image: UIImage? {
//        
//        get {
//            return FlickrClient.Caches.imageCache.imageWithIdentifier(imageURLString)
//        }
//        set {
//            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imageURLString!)
//        }
//    }
}
