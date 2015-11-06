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
    @NSManaged var startDate: NSDate
    @NSManaged var endDate: NSDate
    @NSManaged var location: CLLocationCoordinate2D
    @NSManaged var address: String
    @NSManaged var streetAddress: String
    @NSManaged var cityName: String
    @NSManaged var stateName: String
    @NSManaged var zipCode: String
    @NSManaged var host: PFUser
    @NSManaged var hostProfilePictureURL: String
    @NSManaged var numberOfAttendees: NSInteger
    @NSManaged var comments: PFRelation
    @NSManaged var invites: PFRelation
    @NSManaged var numberOfSpotsLeft: NSInteger
}
