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
    
    var session: NSURLSession!
    
    @IBAction func loginButtonUdacity(sender: AnyObject) {
        UdacityClient.sharedInstance().authenticateWithViewController(self, username: username.text!, password: password.text!) { (success, errorString, username, password) in
            if success {
                print(success)
            } else {
                print(errorString)
            }
        }
    }
    
}