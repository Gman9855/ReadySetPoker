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
    @NSManaged var location: CLLocationCoordinate2D
    @NSManaged var address: String
    @NSManaged var streetAddress: String
    @NSManaged var cityName: String
    @NSManaged var stateName: String
    @NSManaged var zipCode: String
    @NSManaged var host: PFUser
    @NSManaged var hostProfilePictureURL: String
    @NSManaged var comments: NSArray
    @NSManaged var invitedGuests: [PFUser]
    @NSManaged var attendingGuests: [PFUser]
    
    
    
    
    @NSManaged var guestsJoining: Int
    
//    enum eventStatus: String {
//        case PendingInvite = "Pending Invite",
//             Going = "Going",
//             NotGoing = "Not going"
//    }
}
