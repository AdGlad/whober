//
//  matchRequest.swift
//  whober
//
//  Created by Adam Glasdstone on 19/6/17.
//  Copyright © 2017 swiftary. All rights reserved.
//

import UIKit
import os.log

class matchRequest: NSObject, NSCoding {
    
    //MARK: Properties
    
    var userId: String
    var requestId: String
    var photo:  UIImage?
    var matchStatus: String?
    var firstName: String?
    var surname: String?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("matchRequests")
    
    
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
    
    //MARK: Types
    
    
    struct PropertyKey {
        static let userId = "userId"
        static let requestId = "requestId"
        static let photo = "photo"
        static let matchStatus = "matchStatus"
        static let firstName = "firstName"
        static let surname = "surname"
        
    }
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userId, forKey: PropertyKey.userId)
        aCoder.encode(requestId, forKey: PropertyKey.requestId)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(matchStatus, forKey: PropertyKey.matchStatus)
        aCoder.encode(firstName, forKey: PropertyKey.firstName)
        aCoder.encode(surname, forKey: PropertyKey.surname)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let userId = aDecoder.decodeObject(forKey: PropertyKey.userId) as? String
        let requestId = aDecoder.decodeObject(forKey: PropertyKey.requestId) as? String
        let matchStatus = aDecoder.decodeObject(forKey: PropertyKey.matchStatus) as? String
        let firstName = aDecoder.decodeObject(forKey: PropertyKey.firstName) as? String
        let surname = aDecoder.decodeObject(forKey: PropertyKey.surname) as? String
         let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        // Must call designated initializer.
        
        self.init(userId: (userId)!, requestId: (requestId)!, photo: photo, matchStatus: (matchStatus)!, firstName: firstName, surname: surname)
        
        
    }
    
}
