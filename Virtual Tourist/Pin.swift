//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/10/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Pin: NSManagedObject {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longiture = "longitude"
        static let Photos = "photos"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]
    
    // Keep track of whether method to get photos for the Pin has been called (initialize property to false)
    @NSManaged var getPhotosCompleted: Bool
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coordinate: CLLocationCoordinate2D, getPhotosCompleted: Bool, context: NSManagedObjectContext) {
        
        // Initialize entity for Core Data context
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.getPhotosCompleted = getPhotosCompleted
  
    }
}
