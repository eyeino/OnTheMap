//
//  Students.swift
//  On The Map
//
//  Created by Ian MacFarlane on 8/6/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import Foundation

//singleton
class Students {
    static let sharedInstance = Students()
    private init() {}
    
    var list = [StudentInformation]()
    

}