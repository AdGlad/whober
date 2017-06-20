//
//  matchRequest.swift
//  whober
//
//  Created by Adam Glasdstone on 19/6/17.
//  Copyright © 2017 swiftary. All rights reserved.
//

import UIKit

class matchRequest {
    
    //MARK: Properties
    
    var userId: String
    var requestId: String
    var photo:  UIImage?
    var matchStatus: String?
    var firstName: String?
    var surname: String?
    
    
    init?(userId: String, requestId: String, photo:  UIImage?,
        matchStatus: String,firstName: String?, surname: String?)
    {
        
        self.userId = userId
        self.requestId = requestId
        self.photo = photo
        self.matchStatus = matchStatus
        self.firstName = firstName
        self.surname = surname
    }
}
