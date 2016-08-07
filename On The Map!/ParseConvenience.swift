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
                    //initializce all students found in JSON response as StudentInformation structs in the AppDelegate
                    for student in result {
                        Students.sharedInstance.list.append(StudentInformation.init(infoDictionaryForStudent: student))
                    }
                    completionHandlerForLoadStudentInformation(success: true, error: nil)
                    
                } else {
                    sendError("Couldn't cast JSON as dictionary.")
                }
            }
        }
    }
    
    func postStudentInformation(student: StudentInformation, completionHandlerForPostStudentInformation: (success: Bool, error: NSError?) -> Void) {
        let method = Methods.StudentLocation
        
        let jsonBody = "{\"\(JSONBodyKeys.StudentUniqueKey)\": \"\(student.uniqueKey!)\", \"\(JSONBodyKeys.StudentFirstName)\": \"\(student.firstName!)\", \"\(JSONBodyKeys.StudentLastName)\": \"\(student.lastName!)\",\"\(JSONBodyKeys.StudentMapString)\": \"\(student.mapString!)\", \"\(JSONBodyKeys.StudentMediaURL)\": \"\(student.mediaURL!)\",\"\(JSONBodyKeys.StudentLatitude)\": \(student.latitude!), \"\(JSONBodyKeys.StudentLongitude)\": \(student.longitude!)}"
        
        taskForPOSTMethod(method, jsonBody: jsonBody) { (result, error) in
            
            func sendError(error: String, code: Int = 1) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPostStudentInformation(success: false, error: NSError(domain: "postStudentInformation", code: code, userInfo: userInfo))
            }
            
            if let error = error {
                completionHandlerForPostStudentInformation(success: false, error: error)
            } else {
                //cast parsed JSON response as Swift dictionary
                if let objectId = result[ParseClient.JSONResponseKeys.StudentObjectID] as? String {
                    print("Location posting successful. Object ID of StudentLocation: \(objectId)")
                    completionHandlerForPostStudentInformation(success: true, error: nil)
                    
                } else {
                    sendError("Post unsuccessful: No valid confirmation of successful post found.")
                }
            }
            
            
        }
    }
    
    func getStudentInformationWithID(udacityUserID uniqueKey: String, completionHandlerForGetClientsStudentInfo: (success: Bool, error: NSError?) -> Void) {
        
        var whereUniqueKey = ParseClient.ParameterValues.WhereUniqueKey
        whereUniqueKey = self.substituteKeyInMethod(whereUniqueKey, key: ParseClient.URLKeys.UserID, value: uniqueKey)!
        
        let method = Methods.StudentLocation
        let methodParameters = [
            ParseClient.ParameterKeys.Where: whereUniqueKey]
        
        taskForGETMethod(method, parameters: methodParameters) { (result, error) in
            
            func sendError(error: String, code: Int = 1) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetClientsStudentInfo(success: false, error: NSError(domain: "getStudentInformationWithID", code: code, userInfo: userInfo))
            }
            
            if let error = error {
                completionHandlerForGetClientsStudentInfo(success: false, error: error)
            } else {
                if let student = result[ParseClient.JSONResponseKeys.Student] as? [String:AnyObject] {
                    
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    delegate.myStudentInformation = StudentInformation.init(infoDictionaryForStudent: student)
                    
                    completionHandlerForGetClientsStudentInfo(success: true, error: nil)
                } else {
                    sendError("Could not cast student information as a dictionary.")
                }
            }
            
            
        }
        
    }
    
}