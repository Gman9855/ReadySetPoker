//
//  Invite.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/23/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation
import Parse

struct Status {
    var PendingInvite = "Pending Invite"
    var Going = "Going"
    var NotGoing = "Not Going"
}

class Invite: PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Invite"
    }
    
    @NSManaged var event: PokerEvent
    @NSManaged var numberOfGuests: Int
    @NSManaged var inviteStatus: String
    @NSManaged var invitee: PFUser
}
