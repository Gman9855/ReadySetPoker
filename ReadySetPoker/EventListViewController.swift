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

class EventListViewController: PFQueryTableViewController, EventCreationViewControllerDelegate, EventDetailViewControllerDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var tableQuery: PFQuery!
    var noGamesLabel: UILabel!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    var hasUpcomingGames = false
    var hasCompletedGames = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inviteRelation = PFUser.currentUser()!.relationForKey("invites")
        let inviteQuery = inviteRelation.query()!
        
//        inviteQuery.fromLocalDatastore()
        let fetchRequest = NSFetchRequest(entityName: "CDInvite")
        if let result = (try! self.sharedContext.executeFetchRequest(fetchRequest)) as? [CDInvite] {
            let objectIDs = result.map { (invite: CDInvite) -> String in
                return invite.parseObjectID
            }
            inviteQuery.whereKey("objectId", containedIn: objectIDs)
        }
        
        let eventQuery = PokerEvent.query()!
        if segmentedControl.selectedSegmentIndex == 0 {         // if we're on the completed game segment,
            eventQuery.whereKey("endDate", lessThan: NSDate())  // we get events that ended before the current time
        } else {
            eventQuery.whereKey("endDate", greaterThan: NSDate()) // otherwise we get events ending after current time
        }
        
        inviteQuery.whereKey("event", matchesQuery: eventQuery)
        inviteQuery.includeKey("event")
        inviteQuery.orderByDescending("createdAt")
        inviteQuery.findObjectsInBackgroundWithBlock { (obj: [AnyObject]?, error: NSError?) -> Void in
            print(error)
            print(obj)
        }

        setUpNoGamesLabel()
        noGamesLabel.hidden = true
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.labelText = "Loading"
        tableView.tableFooterView = UIView()     // hack to remove extraneous tableview separators
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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
        
        if !isConnectedToNetwork() || segmentedControl.selectedSegmentIndex == 1 {
            if (segmentedControl.selectedSegmentIndex == 1 && hasCompletedGames) || (segmentedControl.selectedSegmentIndex == 1 && hasUpcomingGames) {
                return inviteQuery
            }
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
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
        if self.objects?.count == 0 {
            noGamesLabel.hidden = false
            let statusString = segmentedControl.selectedSegmentIndex == 0 ? "upcoming" : "completed"
            noGamesLabel.text = "No \(statusString) games yet."
            noGamesLabel.sizeToFit()
        } else {
            hasUpcomingGames = segmentedControl.selectedSegmentIndex == 0 && self.objects?.count > 0
            hasCompletedGames = segmentedControl.selectedSegmentIndex == 1 && self.objects?.count > 0
            
            PFObject.pinAllInBackground(self.objects)
            noGamesLabel.hidden = true
            for invite: Invite in self.objects as! [Invite] {
                let fetchRequest = NSFetchRequest(entityName: "CDInvite")
                let predicate = NSPredicate(format: "parseObjectID == %@", invite.objectId!)
                fetchRequest.predicate = predicate
                let result = (try! sharedContext.executeFetchRequest(fetchRequest)) as! [CDInvite]
                if let savedInvite = result.first {
                    print("updated")
                    savedInvite.parseObjectID = invite.objectId!
                } else {
                    print("created new")
                    CDInvite(parseObjectID: invite.objectId!, context: sharedContext)
                }
            }
            CoreDataStackManager.sharedInstance().saveContext()
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
        noGamesLabel.hidden = true
        // if we're going to completed games index
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
