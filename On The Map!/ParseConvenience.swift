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
    
    
    
    func loadStudentInformation(completionHandlerForLoadStudentInformation: (success: Bool, error: String?) -> Void) {
        
        let mutableMethod: String = Methods.StudentLocation
        
        taskForGETMethod(mutableMethod) { (result, error) in
            if let error = error {
                completionHandlerForLoadStudentInformation(success: false, error: "Error occurred in GET method: \(error).")
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
                    completionHandlerForLoadStudentInformation(success: false, error: "Students not found in response, or can't otherwise cast response to dictionary.")
                }
            }
        }
    }
    
}