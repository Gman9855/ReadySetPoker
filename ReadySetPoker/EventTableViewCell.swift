//
//  EventTableViewCell.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/24/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation
import Parse
import ParseUI

class EventTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var gameType: UIButton!
    @IBOutlet weak var gameFormat: UIButton!
    @IBOutlet weak var cashGameBlinds: UIButton!
    @IBOutlet weak var buyinAmount: UIButton!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var inviteStatus: UIButton!
    
    func configureWithInvite(invite: Invite) {
        var inviteStatus = invite.inviteStatus
        if PFUser.currentUser()!.objectId! == invite.event.host.objectId! {
            inviteStatus = Status.Hosting.rawValue
        }
        
        self.date.text = dateStringFromDate(invite.event.startDate)

        UIView.setAnimationsEnabled(false)  //fixes the problem of the labels animating while scrolling the tableView
        self.inviteStatus.setTitle(inviteStatus, forState: UIControlState.Normal)
        switch invite.inviteStatus {
        case Status.Going.rawValue:
            self.inviteStatus.backgroundColor = UIColor(red: 0.305, green: 0.713, blue: 0.417, alpha: 1.000)
        case Status.NotGoing.rawValue:
            self.inviteStatus.backgroundColor = UIColor.grayColor()
        default:
            self.inviteStatus.backgroundColor = UIColor(red: 1.000, green: 0.299, blue: 0.295, alpha: 1.000)
        }
        self.inviteStatus.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        
        self.title.text = invite.event.title
        self.eventImage.sd_setImageWithURL(NSURL(string: invite.event.hostProfilePictureURL), placeholderImage: UIImage(named: "placeholder.jpg"))
        self.gameType.setTitle(invite.event.gameType, forState: .Normal)
        self.gameFormat.setTitle(invite.event.gameFormat, forState: .Normal)
        self.cashGameBlinds.setTitle("\(String(invite.event.cashGameSmallBlind))/\(String(invite.event.cashGameBigBlind))", forState: .Normal)
    }
    
    //MARK: Helper methods
    
    func isGameCompleted(invite: Invite) -> Bool {
        return invite.event.startDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }
    
    func dateStringFromDate(date: NSDate) -> String {
        struct DateFormatter {
            static let formatter: NSDateFormatter = {
                let formatter = NSDateFormatter()
                return formatter
            }()
        }
        
        DateFormatter.formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        DateFormatter.formatter.timeStyle = NSDateFormatterStyle.NoStyle
        let dateString = DateFormatter.formatter.stringFromDate(date)
        DateFormatter.formatter.dateStyle = NSDateFormatterStyle.NoStyle
        DateFormatter.formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let timeString = DateFormatter.formatter.stringFromDate(date)
        return dateString + " at " + timeString
    }
}
