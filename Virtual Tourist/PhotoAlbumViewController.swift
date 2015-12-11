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
    var width: CGFloat!
    var height: CGFloat!
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
        
        // Configure collection view
        let spacing: CGFloat = 4.0
        width = (view.frame.size.width - (4 * spacing)) / 3.0
        height = (view.frame.size.height - (6 * spacing)) / 5.0
        
        flowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.itemSize = CGSizeMake(width, height)
        
        automaticallyAdjustsScrollViewInsets = false
        
//        // Get images from Flickr
//        let latitude = coordinate.latitude as Double
//        let longitude = coordinate.longitude as Double
//        FlickrClient.sharedInstance().getImagesByLocation(latitude, longitude: longitude) {
//            (success, errorString) in
//            
//            if success {
//                print("Photos downloaded successfully.")
//            }
//            else {
//                print(errorString)
//            }
//        }
    }
    
    // MARK: - IBActions
    
    @IBAction func getNewCollection(sender: AnyObject) {
        print("bottom button pressed")
    }
    
    
    // MARK: UICollectionViewDelegate/DataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FlickrClient.sharedInstance().photoAlbum.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
        let photo = FlickrClient.sharedInstance().photoAlbum[indexPath.row]
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
