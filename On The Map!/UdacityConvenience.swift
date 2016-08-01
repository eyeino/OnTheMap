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
    
    func authenticateWithViewController(hostViewController: UIViewController, username: String, password: String, completionHandlerForAuth: (success: Bool, errorString: String?, username: String, password: String) -> Void) {
        
        print("authenticating")
        createSessionID(username, password: password) { (success, sessionID, errorString) in
            if success {
                print(sessionID)
            } else {
                completionHandlerForAuth(success: success, errorString: errorString, username: username, password: password)
            }
        }
    
    }
    
    private func createSessionID(username: String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        //let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Username)\": \"\(username)\", \"\(UdacityClient.JSONBodyKeys.Password)\": \"\(password)\"}}"

        let jsonBody = "{\"udacity\": {\"username\": \"***REMOVED***\", \"password\": \"***REMOVED***\"}}"
            
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { (results, error) in
            
            if error != nil { // Handle error…
                return
            }
            let newData = results!.subdataWithRange(NSMakeRange(5, results!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            print(newData)
            
        }
    }
}