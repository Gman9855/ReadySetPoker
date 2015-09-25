//
//  EventTitleCell.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/12/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit

class EventTitleCell: EventDetailsCell {

    @IBOutlet weak var title: UILabel!
    
    override func configureWithInvite(invite: Invite) {
        self.title.text = invite.event.title
    }
}
