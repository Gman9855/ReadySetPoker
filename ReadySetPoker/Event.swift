//
//  Event.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/23/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation
import Parse

class Event : PFObject {
    @NSManaged var title: String
    @NSManaged var eventDescription: String
    @NSManaged var date: NSDate
    @NSManaged var location: String
    @NSManaged var host: PFUser
    @NSManaged var comments: NSArray
    @NSManaged var attendees: NSArray
}
