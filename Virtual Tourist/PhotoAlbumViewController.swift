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
    var mapViewRegion = MKCoordinateRegion()
    
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
        
        let span = MKCoordinateSpanMake(mapViewRegion.span.latitudeDelta * 0.2, mapViewRegion.span.longitudeDelta * 0.2)
        let region = MKCoordinateRegionMake(coordinate, span)
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
    @IBAction func bottomButtonTouchUp(sender: AnyObject) {
        
        if deleteMode == true {
            removeSelectedPhotos()
        }
        else {
            // getNewCollection
        }
    }
    
    
    // MARK: - Helper Methods
    func removeSelectedPhotos() {
        // Get array of selected indexPaths (sorted descendingly in order to prevent array index out of range and to preserve correct indexPath reference)
        let deleteIndexPaths = photoCollectionView.indexPathsForSelectedItems()!.sort({
            return $0.row > $1.row
        })

        for indexPath in deleteIndexPaths {
            pin.photos.removeAtIndex(indexPath.row)
        }

        photoCollectionView.deleteItemsAtIndexPaths(deleteIndexPaths)
        print("photos removed: \(deleteIndexPaths.count)")
        
        // Configure bottom button
        bottomButton.setTitle("Select Photos to Remove", forState: .Normal)
        bottomButton.enabled = false
    }
    
    
    // MARK: UICollectionViewDelegate/DataSource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let reuseID = "PhotoCell"
 
        let photo = pin.photos[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! PhotoCell
        
        // Configure cell
        cell.photoImageView.contentMode = .ScaleAspectFill
        cell.photoImageView.image = UIImage(named: "blank_navy.jpg")
        cell.loadingIndicator.hidesWhenStopped = true
        cell.loadingIndicator.startAnimating()
        
        FlickrClient.sharedInstance().getImageWithURL(photo.imageURLString) { (downloadedImage, error) in
            if let image = downloadedImage {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.photoImageView.image = image
                    cell.loadingIndicator.stopAnimating()
                }
            }
        }
        
        
        return cell
        
        //        var image = UIImage()
        //
        //        if photo.imageURLString == nil || photo.image == "" {
        //            image = UIImage(named: "noImage")!
        //        } else if photo.image != nil {
        //            image = photo.image!
        //        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if deleteMode == false {
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("showPhoto", sender: indexPath)
        }
            
        else {
            print("selected item: \(indexPath.row)")
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
