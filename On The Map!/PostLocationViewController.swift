//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by Ian MacFarlane on 8/4/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class PostLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mapStringTextField: UITextField!
    @IBOutlet weak var mediaURLTextField:  UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var geocodeButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var userID: String? = nil
    var userIDInParseData: Bool = false
    
    var studentDictionary = [String:AnyObject]()
    
    override func viewDidLoad() {
        
        configureUI()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        userID = delegate.udacityUserID!
        userIDInParseData = delegate.userIDInParseResults
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIEnabled(true)
    }
    
    @IBAction func submitButton(sender: UIStoryboardSegue) {
        
        setUIEnabled(false)
        if userIDInParseData { //this should be changed to !userIDInParse data when PUT method is implemented
            
            activityIndicator.startAnimating()
            //add values to student dict from textfield input
            self.studentDictionary[ParseClient.JSONResponseKeys.StudentMediaURL] = mediaURLTextField.text!
            self.studentDictionary[ParseClient.JSONResponseKeys.StudentMapString] = mapStringTextField.text!
                
                    UdacityClient.sharedInstance().getGovernmentName(udacityUserID: self.userID!, completionHandlerForGetGovernmentName: { (success, error) in
                    
                        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        self.studentDictionary[ParseClient.JSONResponseKeys.StudentFirstName] = delegate.firstName
                        self.studentDictionary[ParseClient.JSONResponseKeys.StudentLastName] = delegate.lastName
                        self.studentDictionary[ParseClient.JSONResponseKeys.StudentUniqueKey] = self.userID
                        
                        //initialize studentinformation object from dictionary
                        let student = StudentInformation.init(infoDictionaryForStudent: self.studentDictionary)
                        
                        //try to post student information to server
                        ParseClient.sharedInstance().postStudentInformation(student, completionHandlerForPostStudentInformation: { (success, error) in
                            //if post is successful
                            if success {
                                performUIUpdatesOnMain({
                                    print("Success! Posted student data.)")
                                    self.activityIndicator.stopAnimating()
                                    self.setUIEnabled(true)
                                    self.performSegueWithIdentifier("studentInformationSubmitted", sender: self)
                                })
                            //if post fails
                            } else {
                                performUIUpdatesOnMain({
                                    self.setUIEnabled(true)
                                    self.activityIndicator.stopAnimating()
                                    self.showMapAlertWithError(error)
                                })
                            }
                        })
                    })
        } else if !userIDInParseData { //this should be changed to userIDInParseData, see above
            //there should be a PUT method here in a future version
        }
    }
    
    @IBAction func dismissButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func geocodeButton(sender: AnyObject) {
        
        activityIndicator.startAnimating()
        
        let address = mapStringTextField.text!
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) -> Void in
            if(error != nil) {
                
                if let existingAnnotation = self.mapView.annotations.first {
                    self.mapView.removeAnnotation(existingAnnotation)
                }
                
                performUIUpdatesOnMain({
                    self.setUIEnabled(true)
                    self.activityIndicator.stopAnimating()
                    self.showMapAlertWithError(error)
                })
            }
            if let placemark = placemarks?.first {
                
                //remove annotation if one already exists
                if let existingAnnotation = self.mapView.annotations.first {
                    self.mapView.removeAnnotation(existingAnnotation)
                }
                
                //get coordinates from geocoded location
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                let lat = CLLocationDegrees(coordinates.latitude)
                let long = CLLocationDegrees(coordinates.longitude)
                
                self.studentDictionary[ParseClient.JSONResponseKeys.StudentLatitude] = lat
                self.studentDictionary[ParseClient.JSONResponseKeys.StudentLongitude] = long
                
                //Create instance in 2D space
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                //Create annotation object and set its coordinates
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                //add single annotation to mapView
                self.mapView.addAnnotation(annotation)
                
                //zoom to annotation config
                let regionRadius: CLLocationDistance = 1000
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
                
                performUIUpdatesOnMain({
                    //reenable submit button once geolocation is successful
                    self.submitButton.enabled = true
                    self.submitButton.alpha = 1.0
                    self.dismissKeyboard()
                    //zoom to annotation
                    self.mapView.setRegion(coordinateRegion, animated: true)
                })
            }
        })
        
        activityIndicator.stopAnimating()
    }
    
    private func showMapAlertWithError(error: NSError?) {
        var alertMessage: String!
        
        if let domain = error?.domain, userInfo = error?.userInfo {
            alertMessage = "Error origin: \(domain), Details: \(userInfo)"
        } else {
            alertMessage = String(error)
        }
        
        let alert = UIAlertController(title: "Error!", message: alertMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func setUIEnabled(enabled: Bool) {
        submitButton.enabled = enabled
        cancelButton.enabled = enabled
        geocodeButton.enabled = enabled
        mapStringTextField.enabled = enabled
        mediaURLTextField.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            submitButton.alpha = 1
            cancelButton.alpha = 1
            geocodeButton.alpha = 1
            mapStringTextField.alpha = 1
            mediaURLTextField.alpha = 1
        } else {
            submitButton.alpha = 0.5
            cancelButton.alpha = 0.5
            geocodeButton.alpha = 0.5
            mapStringTextField.alpha = 0.5
            mediaURLTextField.alpha = 0.5
        }
    }
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [UI.LoginColorTop, UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        // config login button color
        submitButton.backgroundColor = UI.BlueColor
        cancelButton.backgroundColor = UIColor.redColor()
        
        //UITextField settings
        
        configureTextField(mediaURLTextField)
        configureTextField(mapStringTextField)
        
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.autocorrectionType = .No
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.backgroundColor = UI.GreyColor
        textField.textColor = UI.BlueColor
        textField.tintColor = UI.BlueColor
        textField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //disable submit button so user can't submit a location without geolocation
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField.tag == 1 {
            submitButton.enabled = false
            submitButton.alpha = 0.5
        }
    }
    
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}