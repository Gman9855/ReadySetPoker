//
//  EventCreationController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 11/2/15.
//  Copyright © 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import Eureka
import Parse
import MBProgressHUD
import CoreData

protocol EventCreationControllerDelegate {
    func eventCreationControllerDidCreateEventInvite(invite: Invite)
}

class EventCreationController: FormViewController, InviteFriendsViewControllerDelegate {
    
    var invitedFriends = [FacebookFriend]()
    var delegate: EventCreationControllerDelegate?
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    var formFields: [AnyObject?] {
        get {
            return [gameTitle, streetAddress, city, state, zipCode, startTime, endTime, gameDescription, gameFormat, cashMinBuyIn, cashMaxBuyIn, cashSmallBlind, cashBigBlind, gameType, maximumSeats]
        }
    }
    
    var nextBarButton: UIBarButtonItem!
    var gameTitle: String?
    var streetAddress: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var startTime: NSDate?
    var endTime: NSDate?
    var gameDescription: String?
    var gameFormat: String?
    var tournamentBuyIn: Float?
    var cashMinBuyIn: Float?
    var cashMaxBuyIn: Float?
    var cashSmallBlind: Float?
    var cashBigBlind: Float?
    var gameType: String?
    var maximumSeats: NSInteger?
    
    
    lazy var inviteFriendsVC: InviteFriendsViewController = {
        let storyboard = UIStoryboard(name: "LoggedInState", bundle: nil)
        let inviteFriendsNavController = storyboard.instantiateViewControllerWithIdentifier("inviteFriendsNavController") as! UINavigationController
        let inviteFriendsVC = inviteFriendsNavController.topViewController as! InviteFriendsViewController
        inviteFriendsVC.delegate = self
        return inviteFriendsVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBarButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.Plain, target: self, action: "createButtonTapped")
        navigationController?.visibleViewController?.navigationItem.rightBarButtonItem = nextBarButton
        
        self.title = "Create a game"
        setUpCreationForm()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpCreationForm() {
        form +++ Section("Game Title")
            <<< TextRow() {
                $0.placeholder = "Write a title..."
                $0.value = "Gersh's Poker Game"
                }.onChange({ (TextRow) -> () in
                    if let title = TextRow.value {
                        self.gameTitle = title
                    }
                })
            
            +++ Section("Location")
            <<< TextRow() {
                $0.placeholder = "Street address"
                $0.value = "123 Fake St"
                }.onChange({ (TextRow) -> () in
                    if let streetAddress = TextRow.value {
                        self.streetAddress = streetAddress
                    }
                })
            
            <<< TextRow() {
                $0.placeholder = "City"
                $0.value = "Somewhere"
                }.onChange({ (TextRow) -> () in
                    if let city = TextRow.value {
                        self.city = city
                    }
                })
            
            <<< TextRow() {
                $0.placeholder = "State"
                $0.value = "CA"
                }.onChange({ (TextRow) -> () in
                    if let state = TextRow.value {
                        self.state = state
                    }
                })
            
            <<< TextRow() {
                $0.placeholder = "Zip Code"
                $0.value = "09586"
            }.onChange({ (TextRow) -> () in
                if let zipCode = TextRow.value {
                    self.zipCode = zipCode
                }
            })
            
            +++ Section()
            <<< DateTimeInlineRow() {
                $0.title = "Start Time"
                }.onChange({ (DateTimeInlineRow) -> () in
                    if let startTime = DateTimeInlineRow.value {
                        self.startTime = startTime
                    }
                })
            
            <<< DateTimeInlineRow() {
                $0.title = "End Time"
                }.onChange({ (DateTimeInlineRow) -> () in
                    if let endTime = DateTimeInlineRow.value {
                        self.endTime = endTime
                    }
                })
            
            +++ Section("Game Description")
            <<< TextAreaRow() {
                $0.placeholder = "Write a brief description..."
                $0.value = "Going to be a good one!"
                }.onChange({ (TextAreaRow) -> () in
                    if let gameDescription = TextAreaRow.value {
                        self.gameDescription = gameDescription
                    }
                })
            
            +++ Section("Game Info")
            <<< SegmentedRow<String>("GameFormat") {
                $0.options = [GameFormat.CashGame.rawValue, GameFormat.Tournament.rawValue]
                $0.value = GameFormat.CashGame.rawValue
                self.gameFormat = GameFormat.CashGame.rawValue
                }.onChange({ (SegmentedRow) -> () in
                    if let gameFormat = SegmentedRow.value {
                        self.gameFormat = gameFormat
                    }
                })
            
            <<< DecimalRow() {
                $0.title = "Buy-In Amount"
                $0.hidden = Condition.Function(["GameFormat"], { (form) -> Bool in
                    if let segmentedIndex: SegmentedRow<String> = form.rowByTag("GameFormat") {
                        return segmentedIndex.value == "Cash Game"
                    }
                    return true
                })
                }.onChange({ (DecimalRow) -> () in
                    if let buyInAmount = DecimalRow.value {
                        self.tournamentBuyIn = buyInAmount
                    }
                })
            
            <<< DecimalRow() {
                $0.title = "Minimum Buy-In"
                $0.value = 100
                $0.hidden = Condition.Function(["GameFormat"], { (form) -> Bool in
                    if let segmentedIndex: SegmentedRow<String> = form.rowByTag("GameFormat") {
                        return segmentedIndex.value == "Tournament"
                    }
                    return true
                })
                }.onChange({ (DecimalRow) -> () in
                    if let minBuyIn = DecimalRow.value {
                        self.cashMinBuyIn = minBuyIn
                    }
                })
            
            <<< DecimalRow() {
                $0.title = "Maximum Buy-In"
                $0.value = 200
                $0.hidden = Condition.Function(["GameFormat"], { (form) -> Bool in
                    if let segmentedIndex: SegmentedRow<String> = form.rowByTag("GameFormat") {
                        return segmentedIndex.value == "Tournament"
                    }
                    return true
                })
                }.onChange({ (DecimalRow) -> () in
                    if let maxBuyIn = DecimalRow.value {
                        self.cashMaxBuyIn = maxBuyIn
                    }
                })
            
            <<< DecimalRow() {
                $0.title = "Small Blind"
                $0.value = 1
                $0.hidden = Condition.Function(["GameFormat"], { (form) -> Bool in
                    if let segmentedIndex: SegmentedRow<String> = form.rowByTag("GameFormat") {
                        return segmentedIndex.value == "Tournament"
                    }
                    return true
                })
                }.onChange({ (DecimalRow) -> () in
                    if let smallBlind = DecimalRow.value {
                        self.cashSmallBlind = smallBlind
                    }
                })
            
            <<< DecimalRow() {
                $0.title = "Big Blind"
                $0.value = 2
                $0.hidden = Condition.Function(["GameFormat"], { (form) -> Bool in
                    if let segmentedIndex: SegmentedRow<String> = form.rowByTag("GameFormat") {
                        return segmentedIndex.value == "Tournament"
                    }
                    return true
                })
                }.onChange({ (DecimalRow) -> () in
                    if let bigBlind = DecimalRow.value {
                        self.cashBigBlind = bigBlind
                    }
                })
            
            +++ Section()
            <<< TextRow() {
                $0.title = "Game Type"
                $0.value = "PLO"
                $0.placeholder = "NLHE, PLO, Stud, etc."
                }.onChange({ (TextRow) -> () in
                    if let gameType = TextRow.value {
                        self.gameType = gameType
                    }
                })
            
            <<< IntRow() {
                $0.title = "Number of seats"
                $0.value = 9
                }.onChange({ (IntRow) -> () in
                    if let numberOfSeats = IntRow.value {
                        self.maximumSeats = numberOfSeats
                    }
                })
            
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Invite Friends"
                }.onCellSelection({ (cell, row) -> () in
                    self.navigationController?.pushViewController(self.inviteFriendsVC, animated: true)
                })
        
    }
    
    func createButtonTapped() {
        if let startTime = startTime, endTime = endTime {
            if startTime.compare(endTime) == NSComparisonResult.OrderedDescending {
                let alertController = UIAlertController(title: "Invalid Dates", message: "Oops!  Your game ends before it starts.", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
        }
        
        for field in formFields {
            if field == nil {
                print("no value for field")
                // one of the rows doesn't have a value.  Present an alert to the user.
                let alertController = UIAlertController(title: "Error", message: "Please enter missing fields.", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
        }
        
        // Proceed with game creation
        
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
                
                if succeeded {
                    print("Saved event")
                    
                    let hostInvite = self.hostInviteForCreatedEvent(newPokerEvent)
                    hostInvite.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                        let relation = PFUser.currentUser()!.relationForKey("invites")
                        relation.addObject(hostInvite)
                        
                        let eventInvitesRelation = newPokerEvent.relationForKey("invites")
                        eventInvitesRelation.addObject(hostInvite)
                        
                        PFObject.saveAllInBackground([PFUser.currentUser()!, newPokerEvent])
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            CDInvite(parseObjectID: hostInvite.objectId!, context: self.sharedContext)
                            CoreDataStackManager.sharedInstance().saveContext()
                        })
                        
                        hostInvite.pinInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                            if succeeded {
                                print("Pinned host invite")
                                self.navigationController?.popViewControllerAnimated(true)
                                self.delegate?.eventCreationControllerDidCreateEventInvite(hostInvite)
                            } else {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    let alertView = UIAlertView(title: "Error", message: "Could not create a new home game.  Please check your connection and try again.", delegate: self, cancelButtonTitle: "Okay")
                                    alertView.show()
                                })
                                return
                            }
                        })
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
    
    func pokerEventFromUserInput() -> PokerEvent {
        let newPokerEvent = PokerEvent()
        newPokerEvent.title = self.gameTitle!
        newPokerEvent.eventDescription = self.gameDescription!
        newPokerEvent.host = PFUser.currentUser()!
        if let profilePic = PFUser.currentUser()!.objectForKey("fbProfilePictureURL") as? String {
            newPokerEvent.hostProfilePictureURL = profilePic
        }
        newPokerEvent.startDate = self.startTime!
        newPokerEvent.endDate = self.endTime!
        newPokerEvent.gameType = self.gameType!
        newPokerEvent.gameFormat = self.gameFormat!
        newPokerEvent.streetAddress = self.streetAddress!
        newPokerEvent.cityName = self.city!
        newPokerEvent.stateName = self.state!
        newPokerEvent.zipCode = self.zipCode!
        newPokerEvent.cashGameBuyInMinimum = self.cashMinBuyIn!
        newPokerEvent.cashGameBuyInMaximum = self.cashMaxBuyIn!
        newPokerEvent.cashGameSmallBlind = self.cashSmallBlind!
        newPokerEvent.cashGameBigBlind = self.cashBigBlind!
        newPokerEvent.maximumSeats = self.maximumSeats!
        newPokerEvent.numberOfAttendees = 1
        newPokerEvent.numberOfSpotsLeft = self.maximumSeats! - 1
        
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
    
    //MARK: InviteFriendsViewControllerDelegate
    
    func inviteFriendsViewControllerDidSelectFriendsToInvite(invitedFriends: [FacebookFriend]) {
        self.invitedFriends = invitedFriends
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
