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

class Event {
    var title: String!
    var description: String!
    var date: NSDate!
    var location: String!
    var host: PFUser!
    var comments: NSArray!
    var attendees: NSArray!
}
