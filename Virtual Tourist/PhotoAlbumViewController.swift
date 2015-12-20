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
    
    // IBActions
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    
    // Initialized by segue
    var coordinate = CLLocationCoordinate2D()
    var pin: Pin!
    var photosFound = Bool()
    
    // Global properties
    var width: CGFloat!
    var height: CGFloat!
    var deleteMode = false
    
    
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        // Configure nav bar button
        navigationItem.rightBarButtonItem = editButtonItem()
        
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
        
        photoCollectionView.allowsMultipleSelection = true
        
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
    

    // MARK: - Set Editing
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            deleteMode = true
            
            // Configure bottom button
            bottomButton.setTitle("Select Photos to Remove", forState: .Normal)
            bottomButton.enabled = false
            bottomButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        }
        else {
            deleteMode = false
            
            // Reset collection view to deselect any cells that were selected
            photoCollectionView.reloadData()
            
            // Configure bottom button
            bottomButton.setTitle("New Collection", forState: .Normal)
            bottomButton.setTitleColor(nil, forState: .Normal)
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func getNewCollection(sender: AnyObject) {
        
        if deleteMode == true {
            // removeSelectedPhotos
        }
        else {
            // getNewCollection
        }
    }
    
    
    // MARK: UICollectionViewDelegate/DataSource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

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
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if deleteMode == false {
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("showPhoto", sender: indexPath)
        }
            
        else {
            
            // Configure bottom button
            if !collectionView.indexPathsForSelectedItems()!.isEmpty {
                bottomButton.setTitle("Remove Selected Photos", forState: .Normal)
                bottomButton.enabled = true
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        if deleteMode == true {
            
            // Configure bottom button
            if collectionView.indexPathsForSelectedItems()!.isEmpty {
                bottomButton.setTitle("Select Photos to Remove", forState: .Normal)
                bottomButton.enabled = false
            }
        }
    }
    
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Show PhotoDetailViewController with selected photo
        let detailVC = segue.destinationViewController as! PhotoDetailViewController
        detailVC.photoAlbum = pin.photos
        detailVC.imageIndex = (sender as! NSIndexPath).row
    }
}
