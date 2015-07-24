//
//  Event.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/23/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation
import Parse
import Bolts

class Event : PFObject {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    @NSManaged var title: String
    @NSManaged var eventDescription: String
    @NSManaged var date: NSDate
    @NSManaged var location: String
    @NSManaged var host: PFUser
    @NSManaged var comments: NSArray
    @NSManaged var attendees: NSArray
}
