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
    
    @IBOutlet weak var travelLocationsMapView: MKMapView!
    
    
    // MARK: - UI Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        travelLocationsMapView.delegate = self
        
        // Add and configure gesture recognizers
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addPin:")
        longPressGesture.minimumPressDuration = 0.5
        travelLocationsMapView.addGestureRecognizer(longPressGesture)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: - Actions
    
    func addPin(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            // Get point from gesture recognizer and convert to map coordinates
            let point = gestureRecognizer.locationInView(travelLocationsMapView)
            let coordinates = travelLocationsMapView.convertPoint(point, toCoordinateFromView: travelLocationsMapView)
            
            // Create annotation from coordinates and add to map view
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = "pin selected"
            travelLocationsMapView.addAnnotation(annotation)
        }
    }


    // MARK: MKMapViewViewDelegate Methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.draggable = true
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
            
            pinView!.setSelected(true, animated: true)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == MKAnnotationViewDragState.Ending {
            let draggedAnnotation = view.annotation
            print("annotation dropped at: \(draggedAnnotation!.coordinate.latitude), \(draggedAnnotation!.coordinate.longitude)")
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("annotation view selected")
        
        // Push PhotoAlbumViewController to top of stack
        let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        navigationController!.pushViewController(controller, animated: true)
        
        // Deselect annotation from map view so that it can be tapped again without having to first be deselected by the user
        let selectedAnnotations = mapView.selectedAnnotations
        travelLocationsMapView.deselectAnnotation(selectedAnnotations[0], animated: false)
        
        // Set annotation view to selected so that it is draggable
        view.setSelected(true, animated: true)
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        print("annotation view deselected")
    }
    
}

