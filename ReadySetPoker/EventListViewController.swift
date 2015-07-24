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

class EventListViewController: PFQueryTableViewController {
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "PokerEvent"
    
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        return PFQuery(className: "PokerEvent")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EventTableViewCell!
        if cell == nil {
            cell = EventTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        // Extract values from the PFObject to display in the table cell
        if let title = object?.objectForKey("title") as? String {
            cell.title.text = title
        }
        if let gameVariant = object?.objectForKey("gameVariant") as? String {
            cell.gameVariant.text = gameVariant
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
//        var detailScene = segue.destinationViewController as YourDetailViewController
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let row = Int(indexPath.row)
//            detailScene.currentObject = objects[row] as? PFObject
        }
    }
//    @IBAction func createButtonTapped(sender: UIBarButtonItem) {
//        
//    }
//    
    @IBAction func savePokerEvent(sender: UIButton) {
//        var pEvent = PokerEvent()
//        pEvent.title = "Gershy's poker game"
//        pEvent.eventDescription = "This is going to be an awesome game.  I haven't played poker in a while!"
//        pEvent.host = PFUser.currentUser()!
//        pEvent.gameVariant = "No Limit Texas Hold'Em"
//        pEvent.location = "San Jose, CA"
//        pEvent.saveInBackgroundWithBlock { (didSave: Bool, error: NSError?) -> Void in
//            if didSave {
//                print("Saved event")
//            } else {
//                print(error)
//            }
//        }
    }
//
//    @IBAction func deleteAllPokerEvents(sender: UIButton) {
//        var query = PFQuery(className: "PokerEvent")
//        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
//            if objects?.count != nil {
//                PFObject.deleteAllInBackground(objects, block: { (success: Bool, error: NSError?) -> Void in
//                    if success {
//                        print("Deleted all poker events")
//                    } else {
//                        print(error)
//                    }
//                })
//            }
//        }
//    }
//    
//    @IBAction func getAllPokerEvents(sender: UIButton) {
//        var query = PFQuery(className: "PokerEvent")
//        query.findObjectsInBackgroundWithBlock { (pokerEvents: [AnyObject]?, error: NSError?) -> Void in
//            if pokerEvents != nil {
//                print("There are \(pokerEvents!.count) poker events")
//                print("The events are: \(pokerEvents!)")
//            } else {
//                print(error)
//            }
//        }
//    }
}
