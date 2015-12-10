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
    
    // MARK: - UI Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Add and configure gesture recognizers
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addPin:")
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Actions
    
    func addPin(gestureRecognizer: UIGestureRecognizer) {
        
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
            }
            
        case .Changed:
            print("gesture changed")
            
            if droppedPin != nil {
                // Update annotation coordinates
                dispatch_async(dispatch_get_main_queue()) {
                    self.droppedPin.coordinate = coordinates
                    print(self.droppedPin.coordinate)
                }
            }
            
        case .Ended:
            print("gesture ended")
            
            // Save pin and fetch images
            
        default:
            return
        }
    }
    
    
    // MARK: - Helper Methods
    


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
            let draggedAnnotation = view.annotation
            print("annotation dropped at: \(draggedAnnotation!.coordinate.latitude), \(draggedAnnotation!.coordinate.longitude)")
            
            // Since annotation view will be automatically selected after dragging occurs, set to true so that push to PhotoAlbumViewController doesn't occur
            dragged = true

            // Get new photos for pin
            
        default:
            return
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("annotation view selected")
        
        // Deselect annotation from map view so that it can be tapped again without having to first be deselected by the user
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        // Set annotation view as selected so that it is draggable
        view.setSelected(true, animated: true)
        
        // If annotation view is selected by tapping (instead of by dragging), push PhotoAlbumViewController to top of nav stack
        if dragged == false {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            navigationController!.pushViewController(controller, animated: true)
        } else {
            // Set to false to enable push to PhotoAlbumViewController by tapping on annotation view
            dragged = false
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        print("annotation view deselected")
    }
    
}

