//
//  EventTableViewCell.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/24/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation
import ParseUI

class EventTableViewCell: PFTableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var gameType: UILabel!
    @IBOutlet weak var location: UILabel!
}
