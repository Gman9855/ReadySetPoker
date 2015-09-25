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

    override func configureWithInvite(invite: Invite) {
        updateButtonTitleWithInvite(invite)
    }
    
    func updateButtonTitleWithInvite(invite: Invite) {
        var buttonTitle: String
        var buttonColor = UIColor()
        var seats = invite.event.numberOfSpotsLeft == 1 ? "seat" : "seats"

        switch invite.inviteStatus {
        case "Going":
            buttonTitle = "Going - \(invite.event.numberOfSpotsLeft) \(seats) left"
            buttonColor = UIColor(red: 0.305, green: 0.713, blue: 0.417, alpha: 1.000)
        case "Not Going":
            buttonTitle = "Not Going"
            buttonColor = UIColor.grayColor()
        default:
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
        self.rsvpButton.backgroundColor = buttonColor
        self.rsvpButton.setTitle(buttonTitle, forState: UIControlState.Normal)
    }
}
