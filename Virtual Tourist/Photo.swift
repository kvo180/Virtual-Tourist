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
    var imageURLString = ""
    
    init(dictionary: [String : AnyObject]) {
        
        title = dictionary[FlickrClient.JSONResponseKeys.Title] as! String
        if title == "" {
            title = "Untitled"
        }
        
        id = Int(dictionary[FlickrClient.JSONResponseKeys.ID] as! String)!
        
        imageURLString = dictionary[FlickrClient.JSONResponseKeys.ImageURL] as! String
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
