//
//  ParseConstants.swift
//  On The Map!
//
//  Created by Ian MacFarlane on 8/1/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

extension ParseClient {
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let APIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
    }
    
    //MARK: HTTP Headers
    struct HTTPHeaderKeys {
        
        static let APIKey = "X-Parse-REST-API-Key"
        static let ApplicationID = "X-Parse-Application-Id"
        
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Account
        static let StudentLocation = "/StudentLocation"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
        static let Where = "where"
    }
    
    struct ParameterValues {
        static let OrderByNewestFirst = "-updatedAt"
        static let WhereUniqueKey = "{\"uniqueKey\":\"{id}\"}"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        //MARK: Initial conversion to dict
        static let Students = "results"
        static let Student  = "results"
        
        //MARK: Students
        static let StudentCreatedAt = "createdAt"
        static let StudentFirstName = "firstName"
        static let StudentLastName = "lastName"
        static let StudentLatitude = "latitude"
        static let StudentLongitude = "longitude"
        static let StudentObjectID = "objectId"
        static let StudentUniqueKey = "uniqueKey"
        static let StudentMediaURL = "mediaURL"
        static let StudentMapString = "mapString"
        static let StudentUpdatedAt = "updatedAt"
        
    }
    
    struct JSONBodyKeys {
        //MARK: Students
        static let StudentFirstName = "firstName"
        static let StudentLastName = "lastName"
        static let StudentLatitude = "latitude"
        static let StudentLongitude = "longitude"
        static let StudentUniqueKey = "uniqueKey"
        static let StudentMediaURL = "mediaURL"
        static let StudentMapString = "mapString"
    }
}