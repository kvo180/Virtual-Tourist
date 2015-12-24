//
//  PointAnnotation.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/24/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import MapKit

class PointAnnotation: MKPointAnnotation {
    
    var pin: Pin!
    
    init(pin: Pin) {
        self.pin = pin
    }
}
