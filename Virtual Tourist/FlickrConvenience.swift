//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/10/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit

// MARK: - FlickrClient (Convenient Resource Methods)

extension FlickrClient {
    
    // MARK: - GET Images by Lat/Lon Data
    func getImagesByLocation(latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Set the parameters
        methodArguments[ParameterKeys.BBox] = createBoundingBoxString(latitude, longitude: longitude)
        
        let request = configureURLRequestForGETImagesByLocation()
        
        getImagesFromFlickrBySearch(request) { (result, error) in
            
            if let error = error {
                completionHandler(success: false, errorString: error.localizedDescription)
            } else {
                // Check if result contains 'photos' key
                if let photosDictionary = result[JSONResponseKeys.Photos] as? NSDictionary {
                    
                    // Check if any images have been returned
                    if let totalPhotos = photosDictionary[JSONResponseKeys.Total] as? String {

                        if Int(totalPhotos) > 0 {
                            print("\(totalPhotos) photos found.")
                            
                            // Check if results contain an array of photo dictionaries
                            if let photosArray = photosDictionary[JSONResponseKeys.Photo] as? [[String: AnyObject]] {
                                
                                for photo in photosArray {
                                    let photoObject = Photo(dictionary: photo)
                                    self.photoAlbum.append(photoObject)
                                }
                                
                                completionHandler(success: true, errorString: nil)
                            }
                            else {
                                print("Cannot find key \(JSONResponseKeys.Photo) in \(photosDictionary)")
                                completionHandler(success: false, errorString: "Server results did not contain any photo data.")
                            }
                        }
                        else {
                            print("No images have been returned")
                            completionHandler(success: true, errorString: nil)
                        }
                    }
                }
                else {
                    print("Cannot find key \(JSONResponseKeys.Photos) in \(result)")
                    completionHandler(success: false, errorString: "No results returned from server.")
                }
            }
        }
    }
    
    func configureURLRequestForGETImagesByLocation() -> NSMutableURLRequest {
        
        // Build the URL and configure the request
        let urlString = Constants.baseURLSecure + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        return request
    }
    
    
    // MARK: - Lat/Lon Manipulation
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        let bottom_left_lon = max(longitude - BoundingBox.HalfWidth, BoundingBox.LonMin)
        let bottom_left_lat = max(latitude - BoundingBox.HalfHeight, BoundingBox.LatMin)
        let top_right_lon = min(longitude + BoundingBox.HalfWidth, BoundingBox.LonMax)
        let top_right_lat = min(latitude + BoundingBox.HalfHeight, BoundingBox.LatMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
}
