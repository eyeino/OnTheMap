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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    var session: NSURLSession!
    
    @IBAction func loginButtonUdacity(sender: AnyObject) {
        UdacityClient.sharedInstance().authenticateWithViewController( username.text!, password: password.text!, hostViewController: self) { (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.performSegueWithIdentifier("SegueToTabBar", sender: sender)
                } else {
                    print(errorString)
                }
            }
        }
    }
    
}

extension LoginViewController {
    
    //MARK: UITextFieldDelegate Functions
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    //Clears textfields when editing begins
    func textFieldDidBeginEditing(textField: UITextField) {
        let text = textField.text
        if text == "Username" || text == "Password" {
            textField.text = ""
        }
    }
    
    enum TextFieldTags: Int {
        case Username = 0
        case Password = 1
    }
    
    //If textfield is empty when editing ends, insert "TOP" or "BOTTOM"
    func textFieldDidEndEditing(textField: UITextField) {
        let text = textField.text!
        let tag = textField.tag
        switch (text, tag) {
        case ("", TextFieldTags.Username.rawValue):
            textField.text = "Username"
        case ("", TextFieldTags.Password.rawValue):
            textField.text = "Password"
        default:
            break
        }
    }
    */
}

extension LoginViewController {
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [UI.LoginColorTop, UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
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