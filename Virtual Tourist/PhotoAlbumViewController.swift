//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/7/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noImagesLabel: UILabel!
    var pin: Pin!
    var width: CGFloat!
    var height: CGFloat!
    var coordinate = CLLocationCoordinate2D()
    var photosFound = Bool()

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
        
        // Configure collection view
        let spacing: CGFloat = 4.0
        width = (view.frame.size.width - (4 * spacing)) / 3.0
        height = (view.frame.size.height - (6 * spacing)) / 5.0
        
        flowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.itemSize = CGSizeMake(width, height)
        
        automaticallyAdjustsScrollViewInsets = false
        
        // Hide noImagesLabel
        noImagesLabel.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide/show 'No images found' label
        if photosFound {
            noImagesLabel.hidden = true
        } else {
            noImagesLabel.hidden = false
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func getNewCollection(sender: AnyObject) {
        print("bottom button pressed")
    }
    
    
    // MARK: UICollectionViewDelegate/DataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
        let photo = pin.photos[indexPath.row]
//        var image = UIImage()
//        
//        if photo.imageURLString == nil || photo.image == "" {
//            image = UIImage(named: "noImage")!
//        } else if photo.image != nil {
//            image = photo.image!
//        }
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
        cell.photoImageView.image = photo.image
//        cell.photoImageView.image = image
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("item selected at indexpath: \(indexPath)")
    }
}
