//
//  MapViewController.swift
//  On The Map!
//
//  Created by Ian MacFarlane on 8/3/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var userIDInParseResults: Bool = false
    var myStudentDictionary: [String:AnyObject]?
    var myStudentInformation: StudentInformation? = nil
    var annotations = [MKPointAnnotation]()
    
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
                        delegate?.userIDInParseResults = false
                        
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
    
    //execute this block after
    @IBAction func unwindToMapController(sender: UIStoryboardSegue) {
        if (sender.identifier != nil) {
            if sender.identifier == "studentInformationSubmitted" {
                let postLocationViewController = sender.sourceViewController as! PostLocationViewController
                let studentDictionary = postLocationViewController.studentDictionary
                
                if let firstName = studentDictionary[ParseClient.JSONResponseKeys.StudentFirstName] as? String, lastName = studentDictionary[ParseClient.JSONResponseKeys.StudentLastName] as? String {
                    
                    print("User has first name \(firstName) and last name \(lastName))")
                    
                    self.myStudentInformation = StudentInformation.init(infoDictionaryForStudent: studentDictionary)
                    print("Unwind was a success!")
                    
                    guard let student = self.myStudentInformation else {
                        print("Error: passed StudentInformation from unwind segue was nil.")
                        return
                    }
                    
                    //insert into studentInformation dictionary so the tableView picks it up
                    Students.sharedInstance.list.insert(student, atIndex: 0)
                    
                    //add annotation to existing mapview annotations
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
                    self.mapView.addAnnotation(annotation)
                    
                    //zoom to the new annotation
                    let regionRadius: CLLocationDistance = 1000
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
                    mapView.setRegion(coordinateRegion, animated: true)
                    
                    
                } else {
                    print("Nothing returned. Must have pressed the cancel button.")
                }
                
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get list of students from AppDelegate
        var students: [StudentInformation] {
            get {
                return Students.sharedInstance.list
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
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    delegate.userIDInParseResults = true
                    userIDInParseResults = true
                }
            }
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let student = myStudentInformation {
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
            self.annotations.append(annotation)
        }
        
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
                let toOpenWithHTTPS = "https://" + toOpen
                
                if verifyUrl(toOpen) {
                    app.openURL(NSURL(string: toOpen)!)
                } else if verifyUrl(toOpenWithHTTPS) {
                    app.openURL(NSURL(string: toOpenWithHTTPS)!)
                } else {
                    print("Invalid URL.")
                }
            }
        }
    }
    
    //checks if URL is indeed a valid URL
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
}