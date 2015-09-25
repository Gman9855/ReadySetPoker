//
//  EventLocationCell.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/12/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit

class EventLocationCell: EventDetailsCell {
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var cityStateZip: UILabel!
    
   override func configureWithInvite(invite: Invite) {
        self.streetAddress.text = invite.event.streetAddress
        self.cityStateZip.text = invite.event.cityName + ", " + invite.event.stateName + " " + invite.event.zipCode
    }
}
