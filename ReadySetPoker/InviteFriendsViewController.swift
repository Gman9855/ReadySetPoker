//
//  InviteFriendsViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/28/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import SDWebImage
import Parse
import MBProgressHUD

class InviteFriendsViewController: UITableViewController {
    
    var friends = [FacebookFriend]()
    @IBOutlet weak var inviteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        inviteButton.enabled = false
        MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields":"id,name,picture.width(200).height(200)"])
        request.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if let friendArray = result.valueForKey("data") as? NSArray {
                for friend in friendArray {
                    if let name = friend["name"] as? String, let id = friend["id"] as? String {
                        var profilePicURL: NSURL?
                        if let profilePic = friend.valueForKeyPath("picture.data.url") as? String {
                            profilePicURL = NSURL(string: profilePic)
                        }
                        let fbFriend = FacebookFriend(name: name, userID: id, profilePictureURL: profilePicURL)
                        self.friends.append(fbFriend)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
                })
                
            }
        })
    }
    
    @IBAction func dismissButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! InviteFriendsTableViewCell!
        if cell == nil {
            cell = InviteFriendsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "FriendCell")
        }
        if indexPath.row < self.friends.count {
            let fbFriend = self.friends[indexPath.row]
            cell.name.text = fbFriend.name
            cell.profilePicture.sd_setImageWithURL(fbFriend.profilePictureURL, placeholderImage: UIImage(named: "placeholder"))
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.height / 2;
            cell.profilePicture.layer.masksToBounds = true;
            cell.profilePicture.layer.borderWidth = 0
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        switch selectedCell.accessoryType {
        case .Checkmark:
            selectedCell.accessoryType = UITableViewCellAccessoryType.None
            selectedCell.setSelected(false, animated: false)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            var indexPaths = self.tableView.indexPathsForSelectedRows()
            if indexPaths == nil {
                inviteButton.enabled = false
            }
        default:
            selectedCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            inviteButton.enabled = true
        }
    }
    
    @IBAction func inviteButtonTapped(sender: UIBarButtonItem) {
        let indexPaths = self.tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        for indexPath in indexPaths {
            let invitedFriend = friends[indexPath.row]
            
            let friendQuery = PFUser.query()!
            friendQuery.whereKey("facebookID", equalTo: invitedFriend.userID)
            
            var pushQuery = PFInstallation.query()!
            pushQuery.whereKey("user", matchesQuery: friendQuery)
            
            var push = PFPush()
            push.setQuery(pushQuery)
            push.setMessage("You've been invited to a home game!")
            MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                print("\(success), \(error)")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
                })
            })
        }
    }
}
