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
import CoreData

protocol EventCreationViewControllerDelegate {
    func eventCreationViewControllerDidCreateEventInvite(invite: Invite)
}

class EventCreationViewController: UITableViewController, InviteFriendsViewControllerDelegate {
    
    var invitedFriends = [FacebookFriend]()
    var delegate: EventCreationViewControllerDelegate?
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    //MARK: InviteFriendsViewControllerDelegate
    
    func inviteFriendsViewControllerDidSelectFriendsToInvite(invitedFriends: [FacebookFriend]) {
        self.invitedFriends = invitedFriends
    }
    
    //MARK: Action Methods
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func inviteFacebookFriendsButtonTapped(sender: UIButton) {
        let inviteFriendsNavController = storyboard?.instantiateViewControllerWithIdentifier("inviteFriendsNavController") as! UINavigationController
        let inviteFriendsVC = inviteFriendsNavController.topViewController as! InviteFriendsViewController
        inviteFriendsVC.delegate = self
        presentViewController(inviteFriendsNavController, animated: true, completion: nil)
    }
    
    @IBAction func createGameButtonTapped(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)

        //map array of FacebookFriend to array of FacebookFriend userID strings
        let facebookIDs = self.invitedFriends.map { (facebookFriend: FacebookFriend) -> String in
            return facebookFriend.userID
        }
        let userQuery = PFUser.query()
        userQuery?.whereKey("facebookID", containedIn: facebookIDs)
        userQuery?.findObjectsInBackgroundWithBlock({ (result: [AnyObject]?, error: NSError?) -> Void in
            if error != nil {
                print(error, terminator: "")
                    //display error message to user
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
                })
                return
            }
            
            let newPokerEvent = self.pokerEventFromUserInput()
            
            newPokerEvent.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
                newPokerEvent.pinInBackground()
                
                if succeeded {
                    print("Saved event")
                    
                    let hostInvite = self.hostInviteForCreatedEvent(newPokerEvent)
                    hostInvite.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate?.eventCreationViewControllerDidCreateEventInvite(hostInvite)
                        })
                        
                        let relation = PFUser.currentUser()!.relationForKey("invites")
                        relation.addObject(hostInvite)
                        
                        let eventInvitesRelation = newPokerEvent.relationForKey("invites")
                        eventInvitesRelation.addObject(hostInvite)
                        
                        PFObject.saveAllInBackground([PFUser.currentUser()!, newPokerEvent])
                        CDInvite(parseObjectID: hostInvite.objectId!, context: self.sharedContext)
                        CoreDataStackManager.sharedInstance().saveContext()
                    })
                    
                    let invitedFriends = result as! [PFUser]
                    
                    for friend: PFUser in invitedFriends {
                        let invite = self.friendInviteForCreatedEvent(friend, createdEvent: newPokerEvent)
                        invite.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                            PFCloud.callFunctionInBackground("addInviteToUser", withParameters: ["friendID":"\(friend.objectId!)", "inviteID":"\(invite.objectId!)"], block: { (result: AnyObject?, error: NSError?) -> Void in
                                let eventInvitesRelation = newPokerEvent.relationForKey("invites")
                                eventInvitesRelation.addObject(invite)
                                newPokerEvent.saveInBackground()
                            })
                        })
                    }
                    
                    let pushQuery = PFInstallation.query()!
                    pushQuery.whereKey("user", containedIn: invitedFriends)
                    
                    let push = PFPush()
                    push.setQuery(pushQuery)
                    let data = ["alert" : "You've been invited to \(newPokerEvent.title)!", "eventObjectId" : newPokerEvent.objectId!]
                    push.setData(data)
                    push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if success {
                            print("Pushed notification successfully")
                        }
                        if error != nil {
                            print("Failed to push notification", terminator: "")
                        }
                    })
                } else {
                    // did not save.  show alert to user
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alertView = UIAlertView(title: "Error", message: "Could not create a new home game.  Please check your connection and try again.", delegate: self, cancelButtonTitle: "Okay")
                        alertView.show()
                    })
                }
            }
        })
    }
    
    //MARK: TableView Data Source/Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
    
    //MARK: Helper Methods
    
    func pokerEventFromUserInput() -> PokerEvent {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let timeNow = formatter.stringFromDate(date)
        let newPokerEvent = PokerEvent()
        newPokerEvent.title = "New poker game at \(timeNow)"
        newPokerEvent.eventDescription = "This is going to be an awesome game.  I haven't played poker in a while!"
        newPokerEvent.host = PFUser.currentUser()!
        if let profilePic = PFUser.currentUser()!.objectForKey("fbProfilePictureURL") as? String {
            newPokerEvent.hostProfilePictureURL = profilePic
        }
        newPokerEvent.startDate = NSDate()
        newPokerEvent.endDate = NSDate(timeIntervalSinceNow: 3000)
        newPokerEvent.gameType = "PLO"
        newPokerEvent.gameFormat = "Cash Game"
        newPokerEvent.streetAddress = "1560 Southwest Expy"
        newPokerEvent.cityName = "San Jose"
        newPokerEvent.stateName = "CA"
        newPokerEvent.zipCode = "95126"
        newPokerEvent.cashGameBuyInMinimum = 40
        newPokerEvent.cashGameBuyInMaximum = 200
        newPokerEvent.maximumSeats = 9
        newPokerEvent.numberOfAttendees = 1
        newPokerEvent.numberOfSpotsLeft = 8
        
        return newPokerEvent
    }
    
    func hostInviteForCreatedEvent(createdEvent: PokerEvent) -> Invite {
        let hostInvite = Invite()
        hostInvite.invitee = PFUser.currentUser()!
        hostInvite.event = createdEvent
        hostInvite.inviteStatus = Status.Going.rawValue
        hostInvite.numberOfGuests = 0
        
        return hostInvite
    }
    
    func friendInviteForCreatedEvent(friend: PFUser, createdEvent: PokerEvent) -> Invite {
        let invite = Invite()
        invite.invitee = friend
        invite.event = createdEvent
        invite.inviteStatus = Status.Pending.rawValue
        invite.numberOfGuests = 0
        
        return invite
    }
}
