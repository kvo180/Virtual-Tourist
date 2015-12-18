//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/10/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit

class Photo {
    
    var title = ""
    var id = 0
    var image: UIImage?
    
    init(dictionary: [String : AnyObject], image: UIImage) {
        
        title = dictionary[FlickrClient.JSONResponseKeys.Title] as! String
        if title == "" {
            title = "Untitled"
        }
        
        id = Int(dictionary[FlickrClient.JSONResponseKeys.ID] as! String)!
        
        self.image = image
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
