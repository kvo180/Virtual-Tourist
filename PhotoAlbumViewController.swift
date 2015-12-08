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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure map view height
        mapViewHeightContraint.constant = view.frame.height * 0.3
        
    }
    
    // MARK: - IBActions
    
    @IBAction func getNewCollection(sender: AnyObject) {
        print("bottom button pressed")
    }
}
