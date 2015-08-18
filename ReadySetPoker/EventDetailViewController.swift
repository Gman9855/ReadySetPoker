//
//  EventDetailViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/11/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit

class EventDetailViewController: UITableViewController, RSVPViewControllerDelegate {
    
    var pokerEvent: PokerEvent!
    let defaultHeight: CGFloat = UITableViewAutomaticDimension
    let cellData: [(CGFloat?, UITableViewCell.Type)]! = [(54, EventTitleCell.self), (nil, EventDateCell.self), (64, EventLocationCell.self), (nil, EventCommentsCell.self), (nil, EventMoreDetailsCell.self), (64, EventRSVPCell.self)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Event Details"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let (height, cellType) = cellData[indexPath.row]
        let cellReuseIdentifier = reflect(cellType).summary
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as? EventDetailsCell
        cell?.configureWithPokerEvent(pokerEvent)
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    @IBAction func rsvpButtonTapped(sender: UIButton) {
        let rsvpNavigationVC = storyboard?.instantiateViewControllerWithIdentifier("rsvpVC") as! UINavigationController
        let rsvpVC = rsvpNavigationVC.topViewController as! RSVPViewController
        rsvpVC.delegate = self
        presentViewController(rsvpNavigationVC, animated: true, completion: nil)
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let (height, cellType) = cellData[indexPath.row]
        return height != nil ? height! : defaultHeight
    }
    
    func RSVPViewControllerDidRespondToRSVP(isGoing: Bool, withGuests: Int) {
        let indexPath = NSIndexPath(forRow: 5, inSection: 0)
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! EventRSVPCell
        let spotsLeft: Int = 8 - 1 - withGuests
        var buttonTitle = isGoing ? "RSVP - \(spotsLeft) spots left" : "Not going"
        
        cell.rsvpButton.setTitle(buttonTitle, forState: UIControlState.Normal)
    }
}
