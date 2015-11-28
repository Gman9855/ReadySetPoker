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
import CoreData
import SystemConfiguration

class EventListViewController: UITableViewController, EventCreationControllerDelegate, EventDetailViewControllerDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var noGamesLabel: UILabel!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    var upcomingInvites: [Invite]!
    var pastInvites: [Invite]!
    var invitesForSelectedSegment = [Invite]() {
        didSet {
            if invitesForSelectedSegment.count == 0 {
                self.noGamesLabel.hidden = false
                let statusString = self.segmentedControl.selectedSegmentIndex == 0 ? "upcoming" : "completed"
                self.noGamesLabel.text = "No \(statusString) games yet."
                self.noGamesLabel.sizeToFit()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchInvites()
        setUpNoGamesLabel()
        noGamesLabel.hidden = true
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.labelText = "Loading"
        tableView.tableFooterView = UIView()     // hack to remove extraneous tableview separators
    }
    
    override func viewDidAppear(animated: Bool) {
        if invitesForSelectedSegment.count == 0 {
            noGamesLabel.hidden = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        noGamesLabel.hidden = true
    }
    
    func setUpNoGamesLabel() {
        let frame = CGRectMake(0, 0, 300, 50)
        noGamesLabel = UILabel(frame: frame)
        let statusString = segmentedControl.selectedSegmentIndex == 0 ? "upcoming" : "completed"
        noGamesLabel.text = "No \(statusString) games yet."
        noGamesLabel.sizeToFit()
        noGamesLabel.center = self.navigationController!.view.center
        self.navigationController!.view.addSubview(noGamesLabel)
    }
    
    // Define the query that will provide the data for the table view
    func queryForTable() -> PFQuery {
        
        // check if we're connected to the internet.
        // if we are, construct a query to the cloud.
        // if not, query the local datastore and use objectID's stored in core data
        
        let inviteRelation = PFUser.currentUser()!.relationForKey("invites")
        let inviteQuery = inviteRelation.query()!
        let eventQuery = PokerEvent.query()!
        if segmentedControl.selectedSegmentIndex == 1 {         // if we're on the completed game segment,
            eventQuery.whereKey("endDate", lessThan: NSDate())  // we get events that ended before the current time
        } else {
            eventQuery.whereKey("endDate", greaterThan: NSDate()) // otherwise we get events ending after current time
        }
        
        inviteQuery.whereKey("event", matchesQuery: eventQuery)
        inviteQuery.includeKey("event")
        inviteQuery.orderByDescending("createdAt")
        
        if !isConnectedToNetwork() {
            inviteQuery.fromLocalDatastore()
            let fetchRequest = NSFetchRequest(entityName: "CDInvite")
            if let result = (try! self.sharedContext.executeFetchRequest(fetchRequest)) as? [CDInvite] {
                let objectIDs = result.map { (invite: CDInvite) -> String in
                    return invite.parseObjectID
                }
                inviteQuery.whereKey("objectId", containedIn: objectIDs)
            }
        }
        
        return inviteQuery
    }
    
    func fetchInvites() {
        if !isConnectedToNetwork() { // if we're offline don't bother trying to refresh, our datastore objects are never more
            if invitesForSelectedSegment.count != 0 {  // current than the objects currently displayed
                self.refreshControl?.endRefreshing()
                return
            }
        }
        let query = self.queryForTable()
        query.findObjectsInBackgroundWithBlock { (invites: [AnyObject]?, error: NSError?) -> Void in
            print("Found \(invites?.count) objects with error: \(error)")
            MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
            self.refreshControl?.endRefreshing()
            if error != nil {
                self.invitesForSelectedSegment.removeAll()
                self.tableView.reloadData()
                self.noGamesLabel.hidden = false
                self.noGamesLabel.text = "Something went wrong.  Please check your connection."
                self.noGamesLabel.sizeToFit()
            } else {
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    self.upcomingInvites = invites as! [Invite]
                } else {
                    self.pastInvites = invites as! [Invite]
                }
                self.invitesForSelectedSegment = invites as! [Invite]
                PFObject.pinAllInBackground(invites as! [Invite])
                self.noGamesLabel.hidden = true
                self.tableView.reloadData()
                
                if invites?.count == 0 {
                    self.noGamesLabel.hidden = false
                    let statusString = self.segmentedControl.selectedSegmentIndex == 0 ? "upcoming" : "completed"
                    self.noGamesLabel.text = "No \(statusString) games yet."
                    self.noGamesLabel.sizeToFit()
                }
                if self.isConnectedToNetwork() {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        for invite in invites as! [Invite] {
                            let fetchRequest = NSFetchRequest(entityName: "CDInvite")
                            let predicate = NSPredicate(format: "parseObjectID == %@", invite.objectId!)
                            fetchRequest.predicate = predicate
                            let result = (try! self.sharedContext.executeFetchRequest(fetchRequest)) as! [CDInvite]
                            if let savedInvite = result.first {
                                savedInvite.parseObjectID = invite.objectId!
                                print("Updated CDInvite")
                            } else {
                                CDInvite(parseObjectID: invite.objectId!, context: self.sharedContext)
                                print("Created new CDInvite")
                            }
                        }
                        CoreDataStackManager.sharedInstance().saveContext()
                    })
                    
                }
            }
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.invitesForSelectedSegment.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EventTableViewCell!
        let invite = self.invitesForSelectedSegment[indexPath.row]
        cell.configureWithInvite(invite)
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let eventDetailVC = segue.destinationViewController as! EventDetailViewController
            let invite = self.invitesForSelectedSegment[indexPath.row]
            eventDetailVC.invite = invite
            eventDetailVC.delegate = self
        }
    }
    
    //MARK: Action Methods
    
    @IBAction func plusButtonTapped(sender: UIBarButtonItem) {
//        let eventCreationNavController = storyboard?.instantiateViewControllerWithIdentifier("eventCreationNavController") as! UINavigationController
//        let eventCreationVC = eventCreationNavController.topViewController as! EventCreationViewController
//        eventCreationVC.delegate = self
        let eventCreationController = EventCreationController()
        eventCreationController.delegate = self
        self.navigationController?.pushViewController(eventCreationController, animated: true);
//        presentViewController(eventCreationController, animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlIndexChanged(sender: UISegmentedControl) {
        noGamesLabel.hidden = true
        if sender.selectedSegmentIndex == 0 {
            if self.upcomingInvites != nil {
                self.invitesForSelectedSegment = self.upcomingInvites
            } else {
                fetchInvites()
            }
        } else {
            if self.pastInvites != nil {
                self.invitesForSelectedSegment = self.pastInvites
            } else {
                fetchInvites()
            }
        }
        self.tableView.reloadData()
        if self.invitesForSelectedSegment.count > 0 {
            let topIndex = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(topIndex, atScrollPosition: .Top, animated: true)
        }
    }
    
    @IBAction func didPullToRefresh(sender: UIRefreshControl) {
        fetchInvites()
    }
    //MARK: EventCreationViewControllerDelegate
    
    func eventCreationControllerDidCreateEventInvite(invite: Invite) {
        let eventDetailVC = storyboard?.instantiateViewControllerWithIdentifier("eventDetailVC") as! EventDetailViewController
        eventDetailVC.invite = invite
        navigationController?.pushViewController(eventDetailVC, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        fetchInvites()
    }
    
    //MARK: EventDetailViewControllerDelegate
    
    func eventDetailViewControllerDidUpdateEvent() {
        fetchInvites()
    }
    
    //MARK: Helper Methods
    
    private func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
