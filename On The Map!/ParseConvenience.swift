//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Ian MacFarlane on 8/3/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import Foundation
import UIKit

extension ParseClient {
    
    func loadStudentInformation(completionHandlerForLoadStudentInformation: (success: Bool, error: NSError?) -> Void) {
        let mutableMethod: String = Methods.StudentLocation
        
        taskForGETMethod(mutableMethod) { (result, error) in
            
            func sendError(error: String, code: Int = 1) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForLoadStudentInformation(success: false, error: NSError(domain: "loadStudentInformation", code: code, userInfo: userInfo))
            }
            
            //pass deeper error on if error occurred elsewhere
            if let error = error {
                completionHandlerForLoadStudentInformation(success: false, error: error)
            } else {
                //cast parsed JSON response as Swift dictionary
                if let result = result[ParseClient.JSONResponseKeys.Students] as? [[String:AnyObject]] {
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    //initialize all students found in JSON response as StudentInformation structs in the AppDelegate
                    for student in result {
                        delegate.students.append(StudentInformation.init(infoDictionaryForStudent: student))
                    }
                    
                    completionHandlerForLoadStudentInformation(success: true, error: nil)
                } else {
                    sendError("Couldn't cast JSON as dictionary.")
                }
            }
        }
    }
    func postStudentInformation(completionHandlerForPostStudentInformation: (success: Bool, error: String?) -> Void) {
        let method = Methods.StudentLocation
        let jsonBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}"
        
        taskForPOSTMethod(method, jsonBody: jsonBody) { (result, error) in
            
        }
    }
    
}