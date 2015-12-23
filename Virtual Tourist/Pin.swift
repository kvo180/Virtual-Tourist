//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/10/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import MapKit

class Pin: MKPointAnnotation {

    var photos = [Photo]()
    
    // Keep track of if method to get photos for the Pin has been called - initialize bool property to false
    var getPhotosCompleted: Bool = false
}
