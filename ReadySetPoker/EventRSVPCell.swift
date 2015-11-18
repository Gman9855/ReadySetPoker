//
//  EventRSVPCell.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/12/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import Parse

class EventRSVPCell: EventDetailsCell {
    @IBOutlet weak var rsvpButton: UIButton!
    var invite: Invite!
    var seats: String {
        return invite.event.numberOfSpotsLeft == 1 ? "seat" : "seats"
    }
    var buttonTitle: String!
    var buttonColor = UIColor()

    override func configureWithInvite(invite: Invite) {
        if invite.event.endDate.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            buttonTitle = "Game completed"
            buttonColor = UIColor.grayColor()
            self.rsvpButton.enabled = false
        } else {
            self.invite = invite
            switch invite.inviteStatus {
            case Status.Going.rawValue:
                configureButtonForGoingStatus()
            case Status.NotGoing.rawValue:
                configureButtonForNotGoingStatus()
            default:
                configureButtonForPendingStatus()
            }
        }
        
        self.rsvpButton.backgroundColor = buttonColor
        self.rsvpButton.setTitle(buttonTitle, forState: .Normal)
    }
    
    func configureButtonForGoingStatus() {
        buttonTitle = "\(Status.Going.rawValue) - \(invite.event.numberOfSpotsLeft) \(seats) left"
        buttonColor = UIColor(red: 0.305, green: 0.713, blue: 0.417, alpha: 1.000)
    }
    
    func configureButtonForNotGoingStatus() {
        buttonTitle = Status.NotGoing.rawValue
        buttonColor = UIColor.grayColor()
    }
    
    func configureButtonForPendingStatus() {
        if invite.event.numberOfSpotsLeft == 0 {
            buttonTitle = "No seats left"
            buttonColor = UIColor.grayColor()
            self.rsvpButton.enabled = false
        } else {
            self.rsvpButton.enabled = true
            buttonTitle = "RSVP - \(invite.event.numberOfSpotsLeft) \(seats) left"
            buttonColor = UIColor(red: 1.000, green: 0.299, blue: 0.295, alpha: 1.000)
        }
    }
}
