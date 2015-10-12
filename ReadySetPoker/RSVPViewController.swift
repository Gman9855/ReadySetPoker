//
//  RSVPViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/13/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import MBProgressHUD
import Parse

protocol RSVPViewControllerDelegate {
    func RSVPViewControllerDidUpdateInvite(invite: Invite?)
}

class RSVPViewController: UITableViewController {

    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var guestsJoining = 0
    var invite: Invite!
    var delegate: RSVPViewControllerDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if invite.event.host.objectId! == PFUser.currentUser()!.objectId { // If we're the host we can't choose 'Not Going'
            segmentedControl.enabled = false
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "BringingGuestsCell" {
            let array = ["0 Guests", "1 Guest", "2 Guests", "3 Guests"]
            let picker = ActionSheetStringPicker(title: nil, rows: array, initialSelection: 1, doneBlock: { (picker: ActionSheetStringPicker!, selectedIndex: Int, selectedValue: AnyObject!) -> Void in
                self.guestsLabel.text = selectedValue as? String
                self.guestsJoining = selectedIndex
                }, cancelBlock: { (picker: ActionSheetStringPicker!) -> Void in
            }, origin: self.view)
            picker.showActionSheetPicker()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func rsvpButtonTapped(sender: UIButton) {
        let segmentedControlIndex: Int = segmentedControl.selectedSegmentIndex
        let isGoing = segmentedControlIndex == 0
        if !isGoing { guestsJoining = 0 }
        var changedNumberOfGuests = false
        
        print("Invite before had a \(invite.inviteStatus) invite status with \(invite.numberOfGuests) guests, and \(invite.event.numberOfAttendees) people going with \(invite.event.numberOfSpotsLeft) spots left")
        var updatedPartiesCount = 0
        var shouldSave = true
        if isGoing {
            if invite.inviteStatus == "Going" {   //If previous status was "Going"
                if invite.numberOfGuests != guestsJoining {   //If the number of guests was changed from the previous status
                    changedNumberOfGuests = true
                    
                    if guestsJoining > invite.numberOfGuests {
                        updatedPartiesCount += guestsJoining - invite.numberOfGuests
                    } else {
                        updatedPartiesCount -= invite.numberOfGuests - guestsJoining
                    }
                } else {
                    shouldSave = false
                    self.delegate?.RSVPViewControllerDidUpdateInvite(nil)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else if invite.inviteStatus == "Not Going" || invite.inviteStatus == "Pending" {
                updatedPartiesCount += guestsJoining + 1
            }
        } else if invite.inviteStatus == "Going" {
            updatedPartiesCount -= invite.numberOfGuests + 1
        }
        
        if invite.event.numberOfSpotsLeft - updatedPartiesCount < 0 {
            UIAlertView(title: "Error", message: "Not enough seats left!", delegate: self, cancelButtonTitle: "Okay").show()
            shouldSave = false
        }
        
        if shouldSave {
            invite.event.incrementKey("numberOfAttendees", byAmount: updatedPartiesCount)
            invite.event.incrementKey("numberOfSpotsLeft", byAmount: -updatedPartiesCount)
            invite.inviteStatus = isGoing ? "Going" : "Not Going"
            invite.numberOfGuests = guestsJoining
            
            MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            invite.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
                if succeeded {
                    print("Successfully updated invite status")
                    print("Invite now has a \(self.invite.inviteStatus) invite status with \(self.invite.numberOfGuests) guests, and \(self.invite.event.numberOfAttendees) people going with \(self.invite.event.numberOfSpotsLeft) spots left")
                    
                    let invites = self.invite.event.relationForKey("invites")
                    let invitesQuery = invites.query()
                    invitesQuery?.whereKey("inviteStatus", notEqualTo: "Not Going")
                    invitesQuery?.whereKey("invitee", notEqualTo: PFUser.currentUser()!)
                    invitesQuery?.includeKey("invitee")
                    invitesQuery?.findObjectsInBackgroundWithBlock({ (invites: [AnyObject]?, error: NSError?) -> Void in
                        print(invites)
                        if invites?.count > 0 {
                            let inviteResults = invites as! [Invite]
                            let invitees = inviteResults.map({ (invite: Invite) -> PFUser in
                                return invite.invitee
                            })
                            
                            let pushQuery = PFInstallation.query()!
                            pushQuery.whereKey("user", containedIn: invitees)
                            
                            let push = PFPush()
                            push.setQuery(pushQuery)
                            let currentUserName = PFUser.currentUser()!.objectForKey("fullName") as! String
                            var pushString: String
                            if changedNumberOfGuests {
                                pushString = "\(currentUserName) updated the number of guests they're bringing for \(self.invite.event.title)"
                            } else {
                                pushString = "\(currentUserName) updated their status to '\(self.invite.inviteStatus)' for \(self.invite.event.title)"
                            }
                            let data = ["alert" : pushString, "eventObjectId" : self.invite.event.objectId!]
                            push.setData(data)
                            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                if success {
                                    print("Pushed notification successfully")
                                }
                                if error != nil {
                                    print("Failed to push notification")
                                }
                            })
                        }
                    })
                    self.delegate?.RSVPViewControllerDidUpdateInvite(self.invite)
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    print(error)
                    UIAlertView(title: "Error", message: "Could not save RSVP.  Please check your connection and try again.", delegate: self, cancelButtonTitle: "Okay").show()
                    // display error alert to user
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
                })
            }
        }
    }
}
