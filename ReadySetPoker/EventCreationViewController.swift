//
//  EventCreationViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/15/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

protocol EventCreationViewControllerDelegate {
    func eventCreationViewControllerDidCreateEvent(event: PokerEvent)
}

class EventCreationViewController: UITableViewController, InviteFriendsViewControllerDelegate {
    
    var invitedFriends = [FacebookFriend]()
    var delegate: EventCreationViewControllerDelegate?

    @IBAction func createNewGame(sender: UIBarButtonItem) {
//        var pEvent = PokerEvent()
//        pEvent.title = "New poker game 8/15"
//        pEvent.eventDescription = "This is going to be an awesome game.  I haven't played poker in a while!"
//        pEvent.host = PFUser.currentUser()!
//        pEvent.date = NSDate()
//        pEvent.gameType = "No Limit Texas Hold'Em"
//        pEvent.gameFormat = .Cash
//        pEvent.streetAddress = "1560 Southwest Expy Unit 352"
//        pEvent.city = "San Jose"
//        pEvent.state = "CA"
//        pEvent.zipCode = "95126"
//        
//        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//        pEvent.saveInBackgroundWithBlock { (didSave: Bool, error: NSError?) -> Void in
//            if didSave {
//                print("Saved event")
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    MBProgressHUD.hideHUDForView(self.view, animated: true)
//                })
//            } else {
//                print(error)
//                //show alert to user
//            }
//        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func inviteFacebookFriendsButtonTapped(sender: UIButton) {
        let inviteFriendsNavController = storyboard?.instantiateViewControllerWithIdentifier("inviteFriendsNavController") as! UINavigationController
        let inviteFriendsVC = inviteFriendsNavController.topViewController as! InviteFriendsViewController
        inviteFriendsVC.delegate = self
        presentViewController(inviteFriendsNavController, animated: true, completion: nil)
        
    }
    
    func inviteFriendsViewControllerDidSelectFriendsToInvite(invitedFriends: [FacebookFriend]) {
        self.invitedFriends = invitedFriends
    }
    
    @IBAction func createGameButtonTapped(sender: UIButton) {
        var pEvent = PokerEvent()
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let timeNow = formatter.stringFromDate(date)
        pEvent.title = "New poker game 8/17 at \(timeNow)"
        pEvent.eventDescription = "This is going to be an awesome game.  I haven't played poker in a while!"
        pEvent.host = PFUser.currentUser()!
        if let profilePic = PFUser.currentUser()!.objectForKey("fbProfilePictureURL") as? String {
            pEvent.hostProfilePictureURL = profilePic
        }
        pEvent.date = NSDate()
        pEvent.gameType = "PLO"
        pEvent.gameFormat = "Cash Game"
        pEvent.streetAddress = "1560 Southwest Expy"
        pEvent.cityName = "San Jose"
        pEvent.stateName = "CA"
        pEvent.zipCode = "95126"
        pEvent.cashGameBuyInMinimum = 40
        pEvent.cashGameBuyInMaximum = 200
        
        MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        pEvent.saveInBackgroundWithBlock { (didSave: Bool, error: NSError?) -> Void in
            if didSave {
                print("Saved event")
                let facebookIDs = self.facebookIDsFromFacebookFriends(self.invitedFriends)
                let friendQuery = PFUser.query()!
                //        friendQuery.whereKey("facebookID", equalTo: invitedFriend.userID)
                friendQuery.whereKey("facebookID", containedIn: facebookIDs)
                
                var pushQuery = PFInstallation.query()!
                pushQuery.whereKey("user", matchesQuery: friendQuery)
                
                var push = PFPush()
                push.setQuery(pushQuery)
                push.setMessage("You've been invited to \(pEvent.title)!")
                MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
                push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    print("\(success), \(error)")
                    if success {
                        print("Pushed notification successfully")
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate?.eventCreationViewControllerDidCreateEvent(pEvent)
                        })
                    }
                    if error != nil {
                        print("Failed to push notification")
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
                    })
                })
            } else {
                print(error)
                //show alert to user
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("inviteFBFriendsCell") as! InviteFriendsCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("createGameCell") as! CreatePokerGameCell
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func facebookIDsFromFacebookFriends([FacebookFriend]) -> [String] {
        var facebookIDs = [String]()
        for facebookFriend: FacebookFriend in self.invitedFriends {
            facebookIDs.append(facebookFriend.userID)
        }
        return facebookIDs
    }
}
