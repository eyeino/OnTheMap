//
//  StudentInformation.swift
//  On The Map
//
//  Created by Ian MacFarlane on 8/2/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import Foundation
import UIKit

struct StudentInformation {
    init(infoDictionaryForStudent info: [String:AnyObject]) {
        //Info pulled from JSON
        firstName = info[ParseClient.JSONResponseKeys.StudentFirstName] as? String
        lastName  = info[ParseClient.JSONResponseKeys.StudentLastName]  as? String
        mapString = info[ParseClient.JSONResponseKeys.StudentMapString] as? String
        mediaURL  = info[ParseClient.JSONResponseKeys.StudentMediaURL]  as? String
        latitude  = info[ParseClient.JSONResponseKeys.StudentLatitude]  as? Double
        longitude = info[ParseClient.JSONResponseKeys.StudentLongitude] as? Double
        
        //Date formatting config
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        //Date information as String
        let createdAtString = info[ParseClient.JSONResponseKeys.StudentCreatedAt] as? String
        let updatedAtString = info[ParseClient.JSONResponseKeys.StudentUpdatedAt] as? String
        
        //Formatted date information pulled from JSON
        if let createdAtString = createdAtString, updatedAtString = updatedAtString {
            createdAt = dateFormatter.dateFromString(createdAtString)
            updatedAt = dateFormatter.dateFromString(updatedAtString)
        }
        
        //id numbers: objectId is unique to every SI object, uniqueKey is the Udacity account id
        objectId  = info[ParseClient.JSONResponseKeys.StudentObjectID]  as? String
        uniqueKey = info[ParseClient.JSONResponseKeys.StudentUniqueKey] as? String
        
    }
    
    var firstName: String? = nil
    var lastName:  String? = nil
    var mediaURL:  String? = nil
    var latitude:  Double? = nil
    var longitude: Double? = nil
    var mapString: String? = nil
    var createdAt: NSDate? = nil
    var updatedAt: NSDate? = nil
    var objectId:  String? = nil
    var uniqueKey: String? = nil
    
}