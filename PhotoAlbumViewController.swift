//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/7/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeightContraint: NSLayoutConstraint!
    
    
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure map view height
        mapViewHeightContraint.constant = view.frame.height * 0.3
        
    }
}
