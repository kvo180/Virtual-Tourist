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
    var imageURLString: String? = nil
    var image: UIImage?
    
    init(dictionary: [String : AnyObject]) {
        
        title = dictionary[FlickrClient.JSONResponseKeys.Title] as! String
        if title == "" {
            title = "Untitled"
        }
        
        id = Int(dictionary[FlickrClient.JSONResponseKeys.ID] as! String)!
        
        // Check if photo object contains an imageURLString
        if let imageURLString = dictionary[FlickrClient.JSONResponseKeys.ImageURL] as? String {
            
            // Check if image exists at URL
            let imageURL = NSURL(string: imageURLString)
            if let imageData = NSData(contentsOfURL: imageURL!) {
                image = UIImage(data: imageData)
            }
            else {
                print("Image does not exist at \(imageURL).")
            }
        }
        else {
            print("Photo object does not contain an imageURLString.")
        }
        
//        imageURLString = dictionary[FlickrClient.JSONResponseKeys.ImageURL] as? String
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
