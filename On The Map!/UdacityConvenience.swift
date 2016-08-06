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
    
    func authenticateWithUdacity(username: String, password: String, hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, error: NSError?) -> Void) {
        
        //create session with Udacity
        createSessionID(username, password: password) { (success, sessionID, userID, error) in
            if success {
                if let sessionID = sessionID, userID = userID {
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    delegate.udacitySessionID = sessionID
                    delegate.udacityUserID = userID
                }
                completionHandlerForAuth(success: success, error: error)
                
            } else {
                print("Ultimate failure in Udacity login process.")
                completionHandlerForAuth(success: success, error: error)
            }
        }
    }
    
    func logoutWithUdacity(hostViewController: UIViewController, completionHandlerForLogout: (success: Bool, error: String?) -> Void) {
        
        deleteSession { (success, result, error) in
            if success {
                print("Logout successful for Session ID: \(result!)")
            } else {
                print("There was an error logging out: \(error)")
            }
        }
        
        completionHandlerForLogout(success: true, error: nil)
    }
    
    private func createSessionID(username: String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, userID: String?, error: NSError?) -> Void) {
        
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Username)\": \"\(username)\", \"\(UdacityClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
            
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { (results, error) in
            
            func sendError(error: String, code: Int = 1) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, error: NSError(domain: "taskForPOSTMethod", code: code, userInfo: userInfo))
            }
            
            //if error came from a deeper place, pass it without creating another error
            guard (error == nil) else {
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, error: error)
                return
            }
            
            guard let resultsDictionary = results as? [String:AnyObject] else {
                sendError("results could not be casted as dictionary in createSessionID")
                return
            }
            
            if let sessionDictionary = resultsDictionary[UdacityClient.JSONResponseKeys.Session] as? [String:AnyObject], accountDictionary = resultsDictionary[UdacityClient.JSONResponseKeys.Account] as? [String:AnyObject] {
                
                if let sessionID = sessionDictionary[UdacityClient.JSONResponseKeys.SessionID] as? String, userID = accountDictionary[UdacityClient.JSONResponseKeys.UserID] as? String {
                    completionHandlerForSession(success: true, sessionID: sessionID, userID: userID, error: nil)
                } else {
                    sendError("Could not get sessionID and/or userID from parsed data.")
                }
                
            } else {
                sendError("Could not cast parsed JSON data as a dictionary.")
            }
        }
    }
    
    private func getUserData(udacityUserID userID: String, completionHandlerForUserID: (userData: [String:AnyObject]?, error: NSError?) -> Void) {
        
        var mutableMethod: String = Methods.UserData
        mutableMethod = substituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: userID)!
        
        taskForGETMethod(mutableMethod) { (result, error) in
            
            func sendError(error: String, code: Int = 1) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForUserID(userData: nil, error: NSError(domain: "getUserData", code: code, userInfo: userInfo))
            }
            
            if let error = error {
                completionHandlerForUserID(userData: nil, error: error)
            } else {
                if let result = result[UdacityClient.JSONResponseKeys.User] {
                    completionHandlerForUserID(userData: result as? [String:AnyObject], error: nil)
                } else {
                    sendError("Could not find \(UdacityClient.JSONResponseKeys.User) in \(result)")
                }
            }
        }
    }
    
    func getGovernmentName(udacityUserID userID: String, completionHandlerForGetGovernmentName: (success: Bool, error: NSError?) -> Void) {
        
        getUserData(udacityUserID: userID) { (userData, errorString) in
            
            func sendError(error: String, code: Int = 1) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetGovernmentName(success: false, error: NSError(domain: "getGovernmentName", code: code, userInfo: userInfo))
            }
            
            guard let firstName = userData![UdacityClient.JSONResponseKeys.FirstName] as? String, let lastName = userData![UdacityClient.JSONResponseKeys.LastName] as? String else {
                sendError("First/last name not found in Udacity database.")
                return
            }
            
            let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
            delegate!.firstName = firstName
            delegate!.lastName = lastName
            
            completionHandlerForGetGovernmentName(success: true, error: nil)
            
        }
    }
    
    private func deleteSession(completionHandlerForDeleteSession: (success: Bool, result: String?, error: String?) -> Void) {
        let method: String = Methods.Session
        
        taskForDELETEMethod(method) { (result, error) in
            if let error = error {
                completionHandlerForDeleteSession(success: false, result: nil, error: String(error))
            } else {
                if let deletedSession = result[JSONResponseKeys.Session] as? [String:AnyObject] {
                    let deletedSessionID = deletedSession[JSONResponseKeys.SessionID] as? String
                    completionHandlerForDeleteSession(success: true, result: deletedSessionID, error: nil)
                } else {
                    completionHandlerForDeleteSession(success: false, result: nil, error: "No session was deleted.")
                }
            }
        }
    }
    
    
}