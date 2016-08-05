//
//  MapViewController.swift
//  On The Map!
//
//  Created by Ian MacFarlane on 8/3/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import UIKit
import MapKit

/**
 * This view controller demonstrates the objects involved in displaying pins on a map.
 *
 * The map is a MKMapView.
 * The pins are represented by MKPointAnnotation instances.
 *
 * The view controller conforms to the MKMapViewDelegate so that it can receive a method
 * invocation when a pin annotation is tapped. It accomplishes this using two delegate
 * methods: one to put a small "info" button on the right side of each pin, and one to
 * respond when the "info" button is tapped.
 */

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    var userIDInParseResults: Bool = false
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func logoutButton(sender: AnyObject) {
        UdacityClient.sharedInstance().logoutWithUdacity(self) { (success, error) in
            if success {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true, completion: {
                        //set stored user details back to nil upon logout
                        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
                        delegate?.udacityUserID = nil
                        delegate?.udacitySessionID = nil
                        
                    })
                }
            } else {
                print("Logout failure: \(error)")
            }
        }
    }
    
    @IBAction func postLocationButton(sender: AnyObject) {
        if userIDInParseResults {
            print("Your username was found in the Parse response. You need to use PUT to update it. Also this needs an alert.")
        } else {
            print("No username matching yours was found in the Parse response. POST is needed.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get list of students from AppDelegate
        var students: [StudentInformation] {
            get {
                let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
                if let students = delegate?.students {
                    return students
                } else {
                    print("Students array not found in AppDelegate.")
                    return [StudentInformation]()
                }
            }
        }
        
        var udacityUserID: String? {
            get {
                if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    return delegate.udacityUserID
                } else {
                    return ""
                }
            }
        }
        
        //Convert list of students to map annotations
        var annotations = [MKPointAnnotation]()
        
        for student in students {
            
            //Convert double to degrees
            let lat = CLLocationDegrees(student.latitude!)
            let long = CLLocationDegrees(student.longitude!)
            
            //Create instance in 2D space
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName!) \(student.lastName!)"
            annotation.subtitle = student.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
            //check if client userID is found in Parse results
            if let myUniqueKey = udacityUserID, let studentUniqueKey = student.uniqueKey {
                if myUniqueKey == studentUniqueKey {
                    userIDInParseResults = true
                }
            }
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - MKMapViewDelegate

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
}