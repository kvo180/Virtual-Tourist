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
    var droppedPin: MKPointAnnotation!
    var dragged = false
    var deleteMode = false
    
    // MARK: - UI Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                droppedPin = MKPointAnnotation()
                droppedPin.coordinate = coordinates
                
                // Set title property to make annotation draggable
                droppedPin.title = "pin selected"
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotation(self.droppedPin)
                    self.navigationItem.rightBarButtonItem!.enabled = true
                }
                print("annotation added")
                
            case .Changed:
                print("gesture changed")
                
                if droppedPin != nil {
                    // Update annotation coordinates
                    dispatch_async(dispatch_get_main_queue()) {
                        self.droppedPin.coordinate = coordinates
                    }
                }
                
            case .Ended:
                print("gesture ended")
                
                // Save pin and pre-fetch images
                
                // Get images from Flickr
                let latitude = coordinates.latitude as Double
                let longitude = coordinates.longitude as Double
                FlickrClient.sharedInstance().getImagesByLocation(latitude, longitude: longitude) {
                    (success, errorString) in
                    
                    if success {
                        print("Photos downloaded successfully.")
                    }
                    else {
                        print(errorString)
                    }
                }
                
            default:
                return
            }
        }
    }
    

    // MARK: MKMapViewViewDelegate Methods
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
        
        switch newState {
        case .Starting:
            print("drag starting")
            
            // Delete old photos from pin
            
        case .Canceling, .Ending:
            print("drag ended")
            
            let draggedAnnotation = view.annotation
            print("annotation dropped at: \(draggedAnnotation!.coordinate.latitude), \(draggedAnnotation!.coordinate.longitude)")
            
            // Since annotation view will be automatically selected after dragging occurs, set to true so that push to PhotoAlbumViewController doesn't occur
            dragged = true
            
            // Delete previously pre-fetched photos
            // Pre-fetch new photos for pin
            
        default:
            return
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("annotation view selected")
        
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
            mapView.removeAnnotation(view.annotation!)
            print("annotation removed")
        }
        
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        print("annotation view deselected")
    }
    
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAlbum" {
            
            let photoAlbumVC = segue.destinationViewController as! PhotoAlbumViewController
            
            photoAlbumVC.coordinate = (sender as! MKAnnotationView).annotation!.coordinate
        }
    }
    
    
    // MARK: - Helper Methods

}

