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
    var coordinate = CLLocationCoordinate2D()
    
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure map view
        mapViewHeightContraint.constant = view.frame.height * 0.22
        var annotations = [MKPointAnnotation]()
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotations.append(annotation)
        mapView.showAnnotations(annotations, animated: true)
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        mapView.setRegion(region, animated: true)
        
    }
    
    // MARK: - IBActions
    
    @IBAction func getNewCollection(sender: AnyObject) {
        print("bottom button pressed")
    }
}
