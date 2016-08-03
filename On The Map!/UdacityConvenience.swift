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
    
    func authenticateWithViewController(username: String, password: String, hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {

        createSessionID(username, password: password) { (success, sessionID, errorString) in
            if success {
                self.sessionID = sessionID
                completionHandlerForAuth(success: success, errorString: errorString)
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    
    }
    
    private func createSessionID(username: String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Username)\": \"\(username)\", \"\(UdacityClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
            
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { (results, error) in
            
            func sendError(error: String) {
                completionHandlerForSession(success: false, sessionID: nil, errorString: error)
            }
            
            guard (error == nil) else {
                sendError(String(error))
                return
            }
            
            guard let resultsDictionary = results as? [String:AnyObject] else {
                sendError("results could not be casted as dictionary in createSessionID")
                return
            }
            
            guard let sessionDictionary = resultsDictionary[UdacityClient.JSONResponseKeys.Session] as? [String:AnyObject] else {
                sendError("can't cast sessionDictionary as dictionary")
                return
            }
            
            guard let sessionID = sessionDictionary[UdacityClient.JSONResponseKeys.SessionID] as? String else {
                sendError("no sessionID found in sessionDictionary")
                return
            }
            
            completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
            
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