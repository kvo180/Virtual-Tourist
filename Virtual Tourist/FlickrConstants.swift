//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/10/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

extension FlickrClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: API
        static let APIKey = "3d99a7b9345ed97b6e3fc2b927ebd9ea"
        static let baseURLSecure = "https://api.flickr.com/services/rest"
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Search Photos
        static let SearchPhotos = "flickr.photos.search"
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let NoJSONCallback = "1"
        static let PhotoSize = "url_z"
        static let SafeSearch = "1"
        static let DataFormat = "json"
        static let PerPage = "30"
        static let Page = "page"
        static let BBox = "bbox"
    }
    
    // MARK: - JSONResponseKeys
    struct JSONResponseKeys {
        
        static let Title = "title"
        static let ID = "id"
        static let ImageURL = "url_z"
        static let Photos = "photos"
        static let Total = "total"
        static let Photo = "photo"
        static let Pages = "pages"
    }
    
    // MARK: - Bounding Box
    struct BoundingBox {
        
        static let HalfWidth = 0.5
        static let HalfHeight = 0.5
        static let LatMin = -90.0
        static let LatMax = 90.0
        static let LonMin = -180.0
        static let LonMax = 180.0
    }
}