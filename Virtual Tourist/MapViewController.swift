//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/7/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK:  Properties
    
    @IBOutlet weak var mapView: MKMapView!
    var dragged = false
    var deleteMode = false
    var pin: Pin!
    var pins = [Pin]()
    var prefetched = Bool()
    var annotation: MKPointAnnotation!
    
    
    // MARK: - UI Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Add and configure gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addPin:")
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        
        pins = fetchAllPins()
        
        // Configure nav bar button
        navigationItem.rightBarButtonItem = editButtonItem()
        navigationItem.rightBarButtonItem!.enabled = !pins.isEmpty
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Default prefetched variable to false
        prefetched = false
    }
    
    
    // MARK: - Core Data Convenience
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func fetchAllPins() -> [Pin] {
        
        // Create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the fetch request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            print("Error in fetchAllPins(): \(error)")
            return [Pin]()
        }
    }
    
    
    // MARK: - Set Editing
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            // Slide up view to show 'Tap Pins to Delete' label
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.frame.origin.y = -50.0
            })
            
            // Enable delete mode
            deleteMode = true
        }
        else {
            // Slide view back down
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.frame.origin.y = +50.0
            })
            
            // Disable delete mode
            deleteMode = false
            
            // Disable Edit button if mapView has no more annotations
            navigationItem.rightBarButtonItem!.enabled = mapView.annotations.count > 0
        }
    }
    
    
    // MARK: - Actions
    func addPin(gestureRecognizer: UIGestureRecognizer) {
        
        if deleteMode == false {
            
            // Get point from gesture recognizer and convert to map coordinates
            let point = gestureRecognizer.locationInView(mapView)
            let coordinates = mapView.convertPoint(point, toCoordinateFromView: mapView)
            
            switch gestureRecognizer.state {
            case .Began:
                print("gesture began")
                
                // Create annotation from coordinates and add to map view
                annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                
                print(coordinates)
                
                // Create new Pin object
                pin = Pin(coordinate: coordinates, getPhotosCompleted: false, context: sharedContext)
                
                print(pin)
                
                // Add pin to array
                pins.append(pin)
                
                // Save pin
                saveContext()
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotation(self.annotation)
                    self.navigationItem.rightBarButtonItem!.enabled = true
                }
                
                print("annotation added")
                
            case .Changed:
                print("gesture changed")
                print(coordinates)
                
                // Update annotation coordinates
                dispatch_async(dispatch_get_main_queue()) {
                    self.annotation.coordinate = coordinates
                    self.pin.setCoordinate(coordinates)
                }
                
                print(pin.coordinate)
                
            case .Ended:
                print("gesture ended")
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.mapView.removeAnnotation(self.annotation)
                    self.mapView.addAnnotation(self.pin)
                }
                
                // Pre-fetch images
                getPhotosURLArrayFromFlickr(pin)
                
            default:
                return
            }
        }
    }
    

    // MARK: - MKMapViewViewDelegate Methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = false
            pinView!.draggable = true
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
            
            // Set annotation as selected so that it is draggable after being created
            pinView!.setSelected(true, animated: true)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        for view in views {

            if view.selected {
                
                // Animate drop
                var i = -1;
                for view in views {
                    i++;
                    let mkView = view 
                    if view.annotation is MKUserLocation {
                        continue;
                    }
                    
                    // Check if current annotation is inside visible map rect, else go to next one
                    let point:MKMapPoint  =  MKMapPointForCoordinate(mkView.annotation!.coordinate);
                    if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                        continue;
                    }
                    
                    let endFrame:CGRect = mkView.frame;
                    
                    // Move annotation out of view
                    mkView.frame = CGRectMake(mkView.frame.origin.x, mkView.frame.origin.y - self.view.frame.size.height, mkView.frame.size.width, mkView.frame.size.height);
                    
                    // Animate drop
                    let delay = 0.2 * Double(i)
                    UIView.animateWithDuration(0.5, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations:{() in
                        mkView.frame = endFrame}, completion: nil)
                }
                
            } else {
                // Set annotation view to selected so that they're draggable after being added
                view.setSelected(true, animated: false)
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        let selectedPin = view.annotation as! Pin
        
        switch newState {
        case .Starting:
            print("drag starting")
            
//            // Delete old photos from pin
//            selectedPin.photos = []
            
        case .Canceling, .Ending:
            print("drag ended")
            
            let draggedAnnotation = view.annotation
            print("annotation dropped at: \(draggedAnnotation!.coordinate.latitude), \(draggedAnnotation!.coordinate.longitude)")
            
            // Since annotation view will be automatically selected after dragging occurs, set to true so that push to PhotoAlbumViewController doesn't occur
            dragged = true
            
            selectedPin.getPhotosCompleted = false
            
            saveContext()
            
            // Pre-fetch new photos for pin
            getPhotosURLArrayFromFlickr(selectedPin)
            
        default:
            return
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        if deleteMode == false {
            
            // Deselect annotation from map view so that it can be tapped again without having to first be deselected by the user
            mapView.deselectAnnotation(view.annotation, animated: false)
            
            // Set annotation view as selected so that it is draggable
            view.setSelected(true, animated: true)
            
            // If annotation view is selected by tapping (instead of by dragging), segue to PhotoAlbumViewController
            if dragged == false {
                
                performSegueWithIdentifier("showAlbum", sender: view)
                
            } else {
                // If 'dragged' was true, set to false to enable push to PhotoAlbumViewController by tapping on annotation view
                dragged = false
            }
        }
        
        else {
            let selectedPin = view.annotation as! Pin
            pins.removeAtIndex(pins.indexOf(selectedPin)!)
            print("annotation removed")
            
            mapView.removeAnnotation(view.annotation!)
            
            sharedContext.deleteObject(selectedPin)
            saveContext()
        }
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        
        if fullyRendered {
            mapView.addAnnotations(pins)
        }
    }
    
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAlbum" {
            
            let photoAlbumVC = segue.destinationViewController as! PhotoAlbumViewController
            
            photoAlbumVC.coordinate = (sender as! MKAnnotationView).annotation!.coordinate
            photoAlbumVC.pin = (sender as! MKAnnotationView).annotation! as! Pin
            photoAlbumVC.mapViewRegion = mapView.region
            photoAlbumVC.prefetched = prefetched
        }
    }
    
    
    // MARK: - Helper Methods
    
    // Get images from Flickr
    func getPhotosURLArrayFromFlickr(selectedPin: Pin) {
        
        let latitude = selectedPin.latitude as Double
        let longitude = selectedPin.longitude as Double
        FlickrClient.sharedInstance().getPhotosURLArrayByLocation(latitude, longitude: longitude) {
            (success, photosArray, errorString) in
            
            if success {
                
                if !photosArray.isEmpty {
                    
                    self.prefetched = true
                    
                    // Create photo objects and append to selectedPin's photos array
                    for photo in photosArray {
                        
                        let photoObject = Photo(dictionary: photo, context: self.sharedContext)
//                        selectedPin.photos.append(photoObject)
                        
                        photoObject.pin = selectedPin
                    }

                    print("Photos downloaded successfully.")
                }
                    
                else {
                    print("No images found.")
                }
                
                selectedPin.getPhotosCompleted = true
            }
                
            else {
                print(errorString!)
            }
        }
    }

}

