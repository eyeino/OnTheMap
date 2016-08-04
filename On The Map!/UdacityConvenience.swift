//
//  UdacityConvenience.swift
//  On The Map!
//
//  Created by Ian MacFarlane on 8/1/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    func authenticateWithUdacity(username: String, password: String, hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        //create session with Udacity
        createSessionID(username, password: password) { (success, sessionID, userID, errorString) in
            if success {
                if let sessionID = sessionID, userID = userID {
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    delegate.udacitySessionID = sessionID
                    delegate.udacityUserID = userID
                }
                completionHandlerForAuth(success: success, errorString: errorString)
                
            } else {
                print("Ultimate failure in Udacity login process:")
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    
    }
    
    private func createSessionID(username: String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Username)\": \"\(username)\", \"\(UdacityClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
            
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { (results, error) in
            
            func sendError(error: String) {
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error with the request: \(String(error))")
                return
            }
            
            guard let resultsDictionary = results as? [String:AnyObject] else {
                sendError("results could not be casted as dictionary in createSessionID")
                return
            }
            
            if let sessionDictionary = resultsDictionary[UdacityClient.JSONResponseKeys.Session] as? [String:AnyObject], accountDictionary = resultsDictionary[UdacityClient.JSONResponseKeys.Account] as? [String:AnyObject] {
                
                if let sessionID = sessionDictionary[UdacityClient.JSONResponseKeys.SessionID] as? String, userID = accountDictionary[UdacityClient.JSONResponseKeys.UserID] as? String {
                    completionHandlerForSession(success: true, sessionID: sessionID, userID: userID, errorString: nil)
                } else {
                    sendError("Could not get sessionID and/or userID from parsed data.")
                }
                
            } else {
                sendError("Could not cast parsed JSON data as a dictionary.")
            }
        }
    }
    
    private func getUserData(userID: String?, completionHandlerForUserID: (userData: [String:AnyObject]?, errorString: String?) -> Void) {
        
        var mutableMethod: String = Methods.UserData
        mutableMethod = substituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: userID!)!
        
        taskForGETMethod(mutableMethod) { (result, error) in
            if let error = error {
                completionHandlerForUserID(userData: nil, errorString: String(error))
            } else {
                if let result = result[UdacityClient.JSONResponseKeys.User] {
                    completionHandlerForUserID(userData: result as? [String:AnyObject], errorString: nil)
                } else {
                    completionHandlerForUserID(userData: nil, errorString: "Could not find \(UdacityClient.JSONResponseKeys.User) in \(result)")
                }
            }
        }
    }
}