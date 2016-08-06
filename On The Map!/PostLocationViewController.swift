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

class PostLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mapStringTextField: UITextField!
    @IBOutlet weak var mediaURLTextField:  UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
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
            
            //add values to student dict from textfield input
            self.studentDictionary[ParseClient.JSONResponseKeys.StudentMediaURL] = mediaURLTextField.text!
            self.studentDictionary[ParseClient.JSONResponseKeys.StudentMapString] = mapStringTextField.text!
            
            let address = mapStringTextField.text!
            let geocoder = CLGeocoder()
        
            activityIndicator.startAnimating()
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                if(error != nil) {
                    performUIUpdatesOnMain({
                        self.setUIEnabled(true)
                        self.activityIndicator.stopAnimating()
                        self.showMapAlertWithError(error)
                    })
                }
                if let placemark = placemarks?.first {
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                    self.studentDictionary[ParseClient.JSONResponseKeys.StudentLatitude] = coordinates.latitude
                    self.studentDictionary[ParseClient.JSONResponseKeys.StudentLongitude] = coordinates.longitude
                
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
                }
            })
        } else if !userIDInParseData { //this should be changed to userIDInParseData, see above
            //there should be a PUT method here in a future version
        }
    }
    
    @IBAction func dismissButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        mapStringTextField.enabled = enabled
        mediaURLTextField.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            submitButton.alpha = 1
            cancelButton.alpha = 1
            mapStringTextField.alpha = 1
            mediaURLTextField.alpha = 1
        } else {
            submitButton.alpha = 0.5
            cancelButton.alpha = 0.5
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
    
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    
}