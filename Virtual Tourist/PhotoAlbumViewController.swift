//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/7/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import MapKit
import CoreData

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
    var mapViewRegion = MKCoordinateRegion()
    var prefetched = Bool()
    
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
        
        // Show mapView with same region as the mapView from MapViewController
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
        
        // Configure view elements
        noImagesLabel.hidden = true
        bottomButton.enabled = false
        navigationItem.rightBarButtonItem!.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if pin.photos.isEmpty {
            print("photos empty")
            
            // Pin's photos empty due to no photos returned
            if pin.getPhotosCompleted {
                print("fetch complete - no photos found")

                noImagesLabel.text = "No photos found."
                noImagesLabel.hidden = false
                bottomButton.enabled = false
                navigationItem.rightBarButtonItem!.enabled = false
            }
            else {
                // If pin is selected immediately after it's created, the prefetch dataTask will not have returned any results and the pin's photos will be empty
                
                // Cancel pre-fetch dataTask to avoid duplicate tasks
                FlickrClient.sharedInstance().session.getAllTasksWithCompletionHandler() { tasksArray in
                    
                    if let prefetchDataTask = tasksArray.last {
                        prefetchDataTask.cancel()
                        print("previous dataTask canceled")
                    }
                }
                
                // Initiate a new download from Flickr
                getPhotosURLArrayFromFlickr(pin)
            }
        }
        else {
            print("pin contains \(pin.photos.count) photos" )
            
            // If photos are returned by the prefetch dataTask method, update views
            if prefetched {
                print("prefetch complete - photos returned")
                
                noImagesLabel.hidden = true
                
                // Enable bottom button and bar button after delay
                let delay = 1.5 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.bottomButton.enabled = true
                    self.navigationItem.rightBarButtonItem!.enabled = true
                }
            }
            else {
                // Pin already contains photos
                print("pin contains images")
                bottomButton.enabled = true
                navigationItem.rightBarButtonItem!.enabled = true
            }
        }
    }
    
    
    // MARK: - Core Data Convenience
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
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
            
            // Disable edit button if all photos have been removed
            navigationItem.rightBarButtonItem!.enabled = !pin.photos.isEmpty
            
            // Configure bottom button
            bottomButton.setTitle("New Collection", forState: .Normal)
            bottomButton.setTitleColor(nil, forState: .Normal)
            bottomButton.enabled = true
        }
    }
    
    
    // MARK: - IBActions
    @IBAction func bottomButtonTouchUp(sender: AnyObject) {
        
        if deleteMode == true {
            removeSelectedPhotos()
        }
        else {
            getNewCollection()
        }
    }
    
    
    // MARK: - Helper Methods
    
    func getNewCollection() {
        
        for photo in pin.photos {
            
            // Remove association with Pin object
            photo.pin = nil
            
            // Remove Photo object from context
            sharedContext.deleteObject(photo)
        }


        bottomButton.enabled = false
        navigationItem.rightBarButtonItem!.enabled = false
        getPhotosURLArrayFromFlickr(pin)
    }
    
    func removeSelectedPhotos() {
        // Get array of selected indexPaths (sorted descendingly in order to prevent array index out of range and to preserve correct indexPath reference)
        let deleteIndexPaths = photoCollectionView.indexPathsForSelectedItems()!.sort({
            return $0.row > $1.row
        })

        for indexPath in deleteIndexPaths {
            let photo = pin.photos[indexPath.row]
            
            // Remove association with Pin object
            photo.pin = nil
            
            // Remove Photo object from context
            sharedContext.deleteObject(photo)
        }
        
        // Save the context
        saveContext()

        photoCollectionView.deleteItemsAtIndexPaths(deleteIndexPaths)
        print("photos removed: \(deleteIndexPaths.count)")
        
        // Configure bottom button
        bottomButton.setTitle("Select Photos to Remove", forState: .Normal)
        bottomButton.enabled = false
        
        if pin.photos.isEmpty {
            noImagesLabel.text = "All photos removed."
            noImagesLabel.hidden = false
        }
    }
    
    // Get images from Flickr
    func getPhotosURLArrayFromFlickr(selectedPin: Pin) {
        
        let latitude = selectedPin.latitude as Double
        let longitude = selectedPin.longitude as Double
        FlickrClient.sharedInstance().getPhotosURLArrayByLocation(latitude, longitude: longitude) {
            (success, photosArray, errorString) in
            
            if success {
                
                if !photosArray.isEmpty {
                    
                    // Create photo objects and append to selectedPin's photos array
                    for photo in photosArray {
                        
                        let photoObject = Photo(dictionary: photo, context: self.sharedContext)
                        
                        // Add photoObject to Pin's photos array
                        photoObject.pin = self.pin
                    }
                    
                    // Save the context
                    self.saveContext()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.noImagesLabel.hidden = true
                        self.photoCollectionView.reloadData()
                        print("reloaded")
                        
                        // Enable bottom button and bar button after delay
                        let delay = 1.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        
                        dispatch_after(time, dispatch_get_main_queue()) {
                            self.bottomButton.enabled = true
                            self.navigationItem.rightBarButtonItem!.enabled = true
                        }
                    }
                    
                    print("Photos downloaded successfully.")
                }
                
                else {
                    print("No images found.")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.noImagesLabel.text = "No photos found."
                        self.noImagesLabel.hidden = false
                        self.navigationItem.rightBarButtonItem!.enabled = false
                    }
                }
                
                self.pin.getPhotosCompleted = true
            }
                
            else {
                print(errorString!)
            }
        }
    }
    
    
    // MARK: - UICollectionViewDelegate/DataSource Methods
    
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
        
        // If Photo object already contains a cached photo, assign it to cell
        if let storedImage = photo.image {
            
            cell.photoImageView.image = storedImage
        }
        else {
            cell.loadingIndicator.startAnimating()
            
            // Download image and save it to the file system
            FlickrClient.sharedInstance().getImageWithURL(photo.imageURLString) { (downloadedImage, error) in
                if let image = downloadedImage {
                    
                    // Set the Photo object's imagePath and image. 
                    // NOTE: Since the Application folder directory changes each time the app launches, absolute paths cannot be used (only relative paths to the Documents folder). Therefore, the path to the image's data is simply the file name.
                    photo.imagePath = "\(photo.imageID).jpg"
                    photo.image = image
                    self.saveContext()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.photoImageView.image = image
                        cell.loadingIndicator.stopAnimating()
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.photoImageView.image = UIImage(named: "no_image.png")
                        cell.loadingIndicator.stopAnimating()
                    }
                }
            }
        }
        
        return cell
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
