//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/7/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK:  Properties
    
    @IBOutlet weak var mapView: MKMapView!
    var dragged = false
    var deleteMode = false
    var pin: Pin!
    var pins = [Pin]()
    var photosFound = Bool()
    
    // MARK: - UI Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure nav bar buttons
        navigationItem.rightBarButtonItem = editButtonItem()
        navigationItem.rightBarButtonItem!.enabled = false
        
        mapView.delegate = self
        
        // Add and configure gesture recognizers
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addPin:")
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
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
                
                // Create pin object from coordinates and add to map view
                pin = Pin()
                pin.coordinate = coordinates
                
                // Set title property to make annotation draggable
                pin.title = "pin"
                
                // Add pin to array
                pins.append(pin)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotation(self.pin)
                    self.navigationItem.rightBarButtonItem!.enabled = true
                }
                print("annotation added")
                
            case .Changed:
                print("gesture changed")
                
                if pin != nil {
                    // Update annotation coordinates
                    dispatch_async(dispatch_get_main_queue()) {
                        self.pin.coordinate = coordinates
                    }
                }
                
            case .Ended:
                print("gesture ended")
                
                // Save pin and pre-fetch images
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
            pinView!.animatesDrop = true
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        let selectedPin = view.annotation as! Pin
        
        switch newState {
        case .Starting:
            print("drag starting")
            
            // Delete old photos from pin
            selectedPin.photos = []
            
        case .Canceling, .Ending:
            print("drag ended")
            
            let draggedAnnotation = view.annotation
            print("annotation dropped at: \(draggedAnnotation!.coordinate.latitude), \(draggedAnnotation!.coordinate.longitude)")
            
            // Since annotation view will be automatically selected after dragging occurs, set to true so that push to PhotoAlbumViewController doesn't occur
            dragged = true
            
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
            
            // If annotation view is selected by tapping (instead of by dragging), push PhotoAlbumViewController to top of nav stack
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
        }
    }
    
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAlbum" {
            
            let photoAlbumVC = segue.destinationViewController as! PhotoAlbumViewController
            
            photoAlbumVC.coordinate = (sender as! MKAnnotationView).annotation!.coordinate
            photoAlbumVC.pin = sender!.annotation as! Pin
            photoAlbumVC.photosFound = photosFound
            photoAlbumVC.mapViewRegion = mapView.region
        }
    }
    
    
    // MARK: - Helper Methods
    
    // Get images from Flickr
    func getPhotosURLArrayFromFlickr(selectedPin: Pin) {
        
        let latitude = selectedPin.coordinate.latitude as Double
        let longitude = selectedPin.coordinate.longitude as Double
        FlickrClient.sharedInstance().getPhotosURLArrayByLocation(latitude, longitude: longitude) {
            (success, photosArray, imagesFound, errorString) in
            
            if success {
                
                if imagesFound {
                    
                    self.photosFound = true
                    
                    // Create photo objects and append to selectedPin's photos array
                    for photo in photosArray {
                            
                        let photoObject = Photo(dictionary: photo)
                        selectedPin.photos.append(photoObject)
                    }
                    
                    print("Photos downloaded successfully.")
                }
                
                else {
                    print("No images found.")
                    self.photosFound = false
                }
            }
                
            else {
                print(errorString)
            }
        }
    }

}

