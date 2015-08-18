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

class EventListViewController: PFQueryTableViewController, EventCreationViewControllerDelegate {

    override func viewWillAppear(animated: Bool) {
        self.loadObjects()
    }
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "PokerEvent"
    
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        var query = PFQuery(className: "PokerEvent")
        query.orderByDescending("date")
        return query
    }
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 20
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10
//    }
//    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clearColor()
//        return headerView
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EventTableViewCell!
        
        if let hostProfilePicURL = object?.objectForKey("hostProfilePictureURL") as? String {
            cell.eventImage.sd_setImageWithURL(NSURL(string: hostProfilePicURL), placeholderImage: UIImage(named: "placeholder.jpg"))
        } else {
            cell.eventImage.image = UIImage(named: "me.jpg")
        }
        // Extract values from the PFObject to display in the table cell
        if let title = object?.objectForKey("title") as? String {
            cell.title.text = title
        }
        
        if let gameType = object?.objectForKey("gameType") as? String {
            cell.gameType.setTitle(gameType, forState: UIControlState.Normal)
        }
        
        if let gameFormat = object?.objectForKey("gameFormat") as? String {
            cell.gameFormat.setTitle(gameFormat, forState: UIControlState.Normal)
        }
        
        // Date for cell subtitle
//        var dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let dateForText = object["date"] as! NSDate
//        cell.date.text = dateFormatter.stringFromDate(dateForText)
        return cell
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using [segue destinationViewController].
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let eventDetailVC = segue.destinationViewController as! EventDetailViewController
            let pokerEvent = objectAtIndexPath(indexPath) as! PokerEvent
            eventDetailVC.pokerEvent = pokerEvent
        }
    }
    
    @IBAction func plusButtonTapped(sender: UIBarButtonItem) {
        let eventCreationNavController = storyboard?.instantiateViewControllerWithIdentifier("eventCreationNavController") as! UINavigationController
        let eventCreationVC = eventCreationNavController.topViewController as! EventCreationViewController
        eventCreationVC.delegate = self
        presentViewController(eventCreationNavController, animated: true, completion: nil)
    }
    
    func eventCreationViewControllerDidCreateEvent(event: PokerEvent) {
        let eventDetailVC = storyboard?.instantiateViewControllerWithIdentifier("eventDetailVC") as! EventDetailViewController
        eventDetailVC.pokerEvent = event
        navigationController?.pushViewController(eventDetailVC, animated: true)
    }
}
