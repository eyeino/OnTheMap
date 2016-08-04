//
//  LoginViewController.swift
//  On The Map!
//
//  Created by Ian MacFarlane on 8/1/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButtonUdacity: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        password.text = ""
    }
    
    var session: NSURLSession!
    
    @IBAction func loginButtonUdacity(sender: AnyObject) {
        UdacityClient.sharedInstance().authenticateWithUdacity(username.text!, password: password.text!, hostViewController: self) { (success, error) in
                if success {
                    ParseClient.sharedInstance().loadStudentInformation() { (success, error) in
                        if success {
                            performUIUpdatesOnMain {
                                self.performSegueWithIdentifier("SegueToTabBar", sender: sender)
                            }
                        } else {
                            performUIUpdatesOnMain({ 
                                self.showLoginAlertWithError(error)
                            })
                        }
                    }
                        
                } else {
                    if let error = error {
                        performUIUpdatesOnMain({
                            self.showLoginAlertWithError(error)
                        })
                        
                    }
                        
                    }
                    //self.showAlertWithErrorMessageString(errorString!)
                }
        }
    }
    


extension LoginViewController {
    
    //MARK: UITextFieldDelegate Functions
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController {
    
    private func showLoginAlertWithError(error: NSError?) {
        var alertMessage: String!
        if let error = error {
            switch error.code {
            case 301:
                alertMessage = "Incorrect username and/or password."
            case 302:
                alertMessage = "Unable connect to Udacity servers."
            case 1:
                alertMessage = "Error origin: \(error.domain), Details: \(error.userInfo[NSLocalizedDescriptionKey]!)"
            default:
                alertMessage = "Generic error: Origin not specified."
            }
        }
        
        let alert = UIAlertController(title: "Error!", message: alertMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
    
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [UI.LoginColorTop, UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        // config login button color
        loginButtonUdacity.backgroundColor = UI.BlueColor
        
        //UITextField settings
        username.placeholder = "Username"
        password.placeholder = "Password"
        configureTextField(username)
        configureTextField(password)
        password.secureTextEntry = true

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
    
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
}