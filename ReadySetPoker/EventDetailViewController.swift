//
//  EventDetailViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/11/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import MBProgressHUD
import Parse

protocol EventDetailViewControllerDelegate {
    func eventDetailViewControllerDidUpdateEvent()
}

class EventDetailViewController: UITableViewController, RSVPViewControllerDelegate {
    
    var invite: Invite!
    var delegate: EventDetailViewControllerDelegate?
    private var tableViewData = [AnyObject]()
    private let defaultHeight: CGFloat = UITableViewAutomaticDimension
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Event Details"
        MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        tableView.tableFooterView = UIView()
        let inviteQuery = Invite.query()
        inviteQuery?.includeKey("event")
        // Grab the invite from parse.  This way we always have the most updated version of the event
        inviteQuery?.getObjectInBackgroundWithId(self.invite.objectId!, block: { (refreshedInvite: PFObject?, error: NSError?) -> Void in
            self.tableViewData.append(self.arrayWithCellData())
            MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
            self.tableView.reloadData()
            self.updatePlayerStatusesInBackgroundWithBlock { (succeeded, error) -> () in
                if succeeded {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
        })
    }
        
    func updatePlayerStatusesInBackgroundWithBlock(block: (succeeded: Bool, error: NSError?) -> ()) {
        while self.tableViewData.count > 1 {    // if we have player status sections, remove all
            self.tableViewData.removeLast()     // of them except our static section
        }
        let inviteRelation = invite.event.relationForKey("invites")    // the invites for the event
        let query = inviteRelation.query()!
        query.includeKey("invitee")
        query.findObjectsInBackgroundWithBlock { (results: [AnyObject]?, error: NSError?) -> Void in
            if error != nil {
                block(succeeded: false, error: error)
            }
            if let invites = results as? [Invite] {
                var playersGoing = [Invite]()
                var playersNotGoing = [Invite]()
                var playersPending = [Invite]()
                for invite: Invite in invites {
                    if invite.inviteStatus == Status.Going.rawValue {
                        playersGoing.append(invite)
                    } else if invite.inviteStatus == Status.NotGoing.rawValue {
                        playersNotGoing.append(invite)
                    } else if invite.inviteStatus == Status.Pending.rawValue {
                        playersPending.append(invite)
                    }
                }
                let playerStatuses = [playersGoing, playersNotGoing, playersPending]
                for playerStatus in playerStatuses {
                    if playerStatus.count > 0 {
                        self.tableViewData.append(playerStatus)
                    }
                }
                block(succeeded: true, error: nil)
            }
        }
    }
    
    func arrayWithCellData() -> [EventDetailCellData] {
        let titleCell = EventDetailCellData(type: EventTitleCell.self, height: 54)
        let dateCell = EventDetailCellData(type: EventDateCell.self, height: nil)
        let locationCell = EventDetailCellData(type: EventLocationCell.self, height: 64)
//        let commentsCell = EventDetailCellData(type: EventCommentsCell.self, height: nil)
        let moreDetailsCell = EventDetailCellData(type: EventMoreDetailsCell.self, height: nil)
        let rsvpCell = EventDetailCellData(type: EventRSVPCell.self, height: 64)
        return [titleCell, dateCell, locationCell, moreDetailsCell, rsvpCell]
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let object = self.tableViewData[section] as! [AnyObject]
        return object.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let cellArray = self.tableViewData[indexPath.section] as! [EventDetailCellData]
            let cellData = cellArray[indexPath.row]
            return cellData.height != nil ? cellData.height! : defaultHeight
        }
        return 64
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var string: String?
        if section > 0 {
            let playerInvitesFromSection = self.tableViewData[section] as! [Invite]
            let invite = playerInvitesFromSection.first!
            string = "Players " + invite.inviteStatus
        }
        return string
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section > 0 ? 50.0 : 0.0
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellData = self.arrayWithCellData()[indexPath.row]
            let cellReuseIdentifier = cellTypeToIdentifierString(cellData.type)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! EventDetailsCell
            cell.configureWithInvite(self.invite)
            return cell
        }
        
        let playerInvitesFromSection = self.tableViewData[indexPath.section] as! [Invite]
        let invite = playerInvitesFromSection[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as! InviteFriendsTableViewCell
        let playerFullName = invite.invitee.objectForKey("fullName") as? String
        cell.name.text = invite.numberOfGuests > 0 ? playerFullName! + " + \(invite.numberOfGuests)" : playerFullName!
        if let profilePictureString = invite.invitee.objectForKey("fbProfilePictureURL") as? String {
            let url = NSURL(string: profilePictureString)
            cell.profilePicture.sd_setImageWithURL(url, placeholderImage: UIImage(named: "placeholder.jpg"))
        }
        return cell
    }

    @IBAction func rsvpButtonTapped(sender: UIButton) {
        let rsvpNavigationVC = storyboard?.instantiateViewControllerWithIdentifier("rsvpVC") as! UINavigationController
        let rsvpVC = rsvpNavigationVC.topViewController as! RSVPViewController
        rsvpVC.delegate = self
        rsvpVC.invite = self.invite
        presentViewController(rsvpNavigationVC, animated: true, completion: nil)
    }
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MoreDetailsSegue" {
            let eventDescriptionVC = segue.destinationViewController as! EventDescriptionViewController
            eventDescriptionVC.eventDescription = invite.event.eventDescription
        }
    }
    
    //MARK: RSVP View Controller Delegate
    
    func RSVPViewControllerDidUpdateInvite(invite: Invite?) {
        // We update the RSVP button status as well as the player statuses to reflect the RSVP change
        if let updatedInvite = invite {
            let indexPath = NSIndexPath(forRow: 5, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! EventRSVPCell
            cell.configureWithInvite(updatedInvite)
            self.updatePlayerStatusesInBackgroundWithBlock({ (succeeded, error) -> () in
                if succeeded {
                    self.tableView.reloadData()
                }
            })
            delegate?.eventDetailViewControllerDidUpdateEvent()
        }
    }
    
    @IBAction func didPullToRefresh(sender: UIRefreshControl) {
        print("Before fetch: \(self.invite.event.numberOfSpotsLeft)")
        
        let inviteQuery = Invite.query()
        inviteQuery?.includeKey("event")
        inviteQuery?.getObjectInBackgroundWithId(self.invite.objectId!, block: { (refreshedInvite: PFObject?, error: NSError?) -> Void in
            if let refreshedInvite = refreshedInvite as? Invite {
                print("After fetch: \(refreshedInvite.event.numberOfSpotsLeft)")
                self.updatePlayerStatusesInBackgroundWithBlock({ (succeeded, error) -> () in
                    if succeeded {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                            sender.endRefreshing()
                        })
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    sender.endRefreshing()
                })
            }
        })
    }
    
    //MARK: Helper Methods
    
    func cellTypeToIdentifierString(cellType: UITableViewCell.Type) -> String {
        let cellTypeDescription = Mirror(reflecting: (cellType)).description
        let stringComponents = cellTypeDescription.componentsSeparatedByString(" ")
        let lastComponent = stringComponents.last!
        return "ReadySetPoker." + lastComponent.componentsSeparatedByString(".").first!
    }
}
