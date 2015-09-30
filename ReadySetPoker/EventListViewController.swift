//
//  EventListViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/23/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Bolts
import MBProgressHUD

class EventListViewController: PFQueryTableViewController, EventCreationViewControllerDelegate, EventDetailViewControllerDelegate {
    
    var invites = [Invite]()
    var events = [PokerEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.labelText = "Loading"
        tableView.tableFooterView = UIView()     // hack to remove extraneous tableview separators
    }
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "Invite"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.loadingViewEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        var inviteRelation = PFUser.currentUser()!.relationForKey("invites")
        var inviteQuery = inviteRelation.query()!
        inviteQuery.includeKey("event")
        inviteQuery.orderByDescending("createdAt")
        return inviteQuery
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EventTableViewCell!
        
        if let invite = object as? Invite {
            UIView.setAnimationsEnabled(false)
            var inviteStatus = invite.inviteStatus
            if PFUser.currentUser()!.objectId! == invite.event.host.objectId! {
                inviteStatus = "Hosting"
            }
            cell.inviteStatus.setTitle(inviteStatus, forState: UIControlState.Normal)
            switch invite.inviteStatus {
            case "Going":
                cell.inviteStatus.backgroundColor = UIColor(red: 0.305, green: 0.713, blue: 0.417, alpha: 1.000)
            case "Not Going":
                cell.inviteStatus.backgroundColor = UIColor.grayColor()
            default:
                cell.inviteStatus.backgroundColor = UIColor(red: 1.000, green: 0.299, blue: 0.295, alpha: 1.000)
            }
            cell.inviteStatus.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            cell.title.text = invite.event.title
            cell.eventImage.sd_setImageWithURL(NSURL(string: invite.event.hostProfilePictureURL), placeholderImage: UIImage(named: "placeholder.jpg"))
            cell.gameType.setTitle(invite.event.gameType, forState: UIControlState.Normal)
            cell.gameFormat.setTitle(invite.event.gameFormat, forState: UIControlState.Normal)
        }
    
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let eventDetailVC = segue.destinationViewController as! EventDetailViewController
            let invite = objectAtIndexPath(indexPath) as! Invite
            eventDetailVC.invite = invite
            eventDetailVC.delegate = self
        }
    }
    
    //MARK: Action Methods
    
    @IBAction func plusButtonTapped(sender: UIBarButtonItem) {
        let eventCreationNavController = storyboard?.instantiateViewControllerWithIdentifier("eventCreationNavController") as! UINavigationController
        let eventCreationVC = eventCreationNavController.topViewController as! EventCreationViewController
        eventCreationVC.delegate = self
        presentViewController(eventCreationNavController, animated: true, completion: nil)
    }
    
    //MARK: EventCreationViewControllerDelegate
    
    func eventCreationViewControllerDidCreateEventInvite(invite: Invite) {
        let eventDetailVC = storyboard?.instantiateViewControllerWithIdentifier("eventDetailVC") as! EventDetailViewController
        eventDetailVC.invite = invite
        navigationController?.pushViewController(eventDetailVC, animated: true)
        self.loadObjects()
    }
    
    //MARK: EventDetailViewControllerDelegate
    
    func eventDetailViewControllerDidUpdateEvent() {
        self.loadObjects()
    }
}
