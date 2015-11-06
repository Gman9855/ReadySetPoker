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

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var tableQuery: PFQuery!
    var noGamesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNoGamesLabel()
        noGamesLabel.hidden = true
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.labelText = "Loading"
        tableView.tableFooterView = UIView()     // hack to remove extraneous tableview separators
    }
    
    func setUpNoGamesLabel() {
        let frame = CGRectMake(0, 0, 100, 50)
        noGamesLabel = UILabel(frame: frame)
        let statusString = segmentedControl.selectedSegmentIndex == 0 ? "upcoming" : "completed"
        noGamesLabel.text = "No \(statusString) games yet."
        noGamesLabel.sizeToFit()
        noGamesLabel.center = self.navigationController!.view.center
        self.navigationController!.view.addSubview(noGamesLabel)
    }
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // Configure the PFQueryTableView
        self.parseClassName = "Invite"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.loadingViewEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
//        let inviteRelation = PFUser.currentUser()!.relationForKey("invites")
//        let inviteQuery = inviteRelation.query()!
//        inviteQuery.includeKey("event")
//        inviteQuery.orderByDescending("createdAt")
        
        let eventQuery = PokerEvent.query()!
        
        let inviteRelation = PFUser.currentUser()!.relationForKey("invites")
        let inviteQuery = inviteRelation.query()!
        inviteQuery.whereKey("event", matchesQuery: eventQuery)
        inviteQuery.includeKey("event")
        inviteQuery.orderByDescending("createdAt")
        
        if segmentedControl.selectedSegmentIndex == 1 {         // if we're on the completed game segment,
            eventQuery.whereKey("endDate", lessThan: NSDate())  // we get events that ended before the current time
        } else {
            eventQuery.whereKey("endDate", greaterThan: NSDate()) // otherwise we get events ending after current time
        }
        
        return inviteQuery
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
        
        if self.objects?.count == 0 {
            if let noGamesLabel = noGamesLabel {
                noGamesLabel.hidden = false
            }
        } else {
            noGamesLabel.hidden = true
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EventTableViewCell!
        
        if let invite = object as? Invite {
            cell.configureWithInvite(invite)
        }
    
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
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
    
    @IBAction func segmentedControlIndexChanged(sender: UISegmentedControl) {
        MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        noGamesLabel.hidden = true
        self.loadObjects()
        if self.objects?.count > 0 {
            let topIndex = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(topIndex, atScrollPosition: .Top, animated: true)
        }
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
