//
//  AppDelegate.swift
//  On The Map!
//
//  Created by Ian MacFarlane on 8/1/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //Store userID and sessionID generated by logging into Udacity w/ the LoginViewController
    var udacityUserID: String? = nil
    var udacitySessionID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    //Store array of StudentInformation structs after parsing info from Udacity's Parse server
    var students = [StudentInformation]()
    
    //client's student information; some data comes from the Login VC, some from the PostLocationVC
    var myStudentInformationDictionary = [String:AnyObject]()
    
    var myStudentInformation: StudentInformation? = nil
    
    var userIDInParseResults: Bool = false
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}