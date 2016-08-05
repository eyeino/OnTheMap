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
    var method = "POST"
    
    @IBOutlet weak var mapStringTextField: UITextField!
    @IBOutlet weak var mediaURLTextField:  UITextField!
    
    var userID: String? = nil
    var studentDictionary = [String:AnyObject]()
    
    override func viewDidLoad() {
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        userID = delegate.udacityUserID!
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        
        self.studentDictionary[ParseClient.JSONResponseKeys.StudentMediaURL] = mediaURLTextField.text!
        self.studentDictionary[ParseClient.JSONResponseKeys.StudentMapString] = mapStringTextField.text!
        
        let address = mapStringTextField.text!
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
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
                    
                    let student = StudentInformation.init(infoDictionaryForStudent: self.studentDictionary)
                    
                    ParseClient.sharedInstance().postStudentInformation(student, completionHandlerForPostStudentInformation: { (success, error) in
                        if success {
                            performUIUpdatesOnMain({
                                print("Success")
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                        } else {
                            print(error)
                        }
                    })
                })
            }
        })
    }
    
    private func showMapAlertWithError(error: NSError?) {
        var alertMessage: String!
        if let error = error {
            alertMessage = "Error origin: \(error.domain), Details: \(error.userInfo[NSLocalizedDescriptionKey]!)"
        }
        
        let alert = UIAlertController(title: "Error!", message: alertMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}