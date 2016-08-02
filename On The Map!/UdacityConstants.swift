//
//  UdacityConstants.swift
//  On The Map!
//
//  Created by Ian MacFarlane on 8/1/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

extension UdacityClient {
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Authentication
        static let Session = "/session"
        
        //MARK: User Data
        static let UserData = "/users/id"
        
    }
    
    //MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Account
        static let Account = "account"
        static let Registered = "registered"
        static let UserID = "key"
        
        // MARK: Authorization
        static let Session = "session"
        static let SessionID = "id"
        static let SessionExpiration = "expiration"
        
        //MARK: User Info
        
        
        
        
    }
}