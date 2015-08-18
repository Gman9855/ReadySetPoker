//
//  EventDateCell.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/12/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit

class EventDateCell: EventDetailsCell {
    @IBOutlet weak var dateLabel: UILabel!
    
    override func configureWithPokerEvent(event: PokerEvent) {
        struct DateFormatter {
            static let formatter: NSDateFormatter = {
                let formatter = NSDateFormatter()
                return formatter
                }()
        }
        
        DateFormatter.formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        DateFormatter.formatter.timeStyle = NSDateFormatterStyle.NoStyle
        let dateString = DateFormatter.formatter.stringFromDate(event.date)
        DateFormatter.formatter.dateStyle = NSDateFormatterStyle.NoStyle
        DateFormatter.formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let timeString = DateFormatter.formatter.stringFromDate(event.date)
        dateLabel.text = dateString + " at " + timeString
    }
}
