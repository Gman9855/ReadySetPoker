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

protocol InviteFriendsViewControllerDelegate {
    func inviteFriendsViewControllerDidSelectFriendsToInvite(invitedFriends: [FacebookFriend])
}

class InviteFriendsViewController: UITableViewController {
    
    var friends = [FacebookFriend]()
    var delegate: InviteFriendsViewControllerDelegate?
    
    lazy var noFriendsLabel: UILabel = {
        let frame = CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)
        var noFriendsLabel = UILabel(frame: frame)
        noFriendsLabel.text = "Oops!  No friends yet."
        noFriendsLabel.sizeToFit()
        noFriendsLabel.font = UIFont(name: "Arial", size: 12.0)
        noFriendsLabel.center = self.navigationController!.view.center
        self.tableView.backgroundView = noFriendsLabel
        return noFriendsLabel
    }()
    
    lazy var noConnectionLabel: UILabel = {
        let frame = CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)
        var noConnectionLabel = UILabel(frame: frame)
        noConnectionLabel.text = "Connection unavailable.  Please pull to refresh."
        noConnectionLabel.sizeToFit()
        noConnectionLabel.textAlignment = .Center
        noConnectionLabel.font = UIFont(name: "Arial", size: 12.0)
        self.tableView.backgroundView = noConnectionLabel
        return noConnectionLabel
    }()
    
    // View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noFriendsLabel.hidden = true
        noConnectionLabel.hidden = true
        tableView.tableFooterView = UIView()
        fetchFacebookFriends()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPaths = self.tableView.indexPathsForSelectedRows as [NSIndexPath]! {
            var selectedFriendsToInvite = [FacebookFriend]()
            for indexPath in indexPaths {
                selectedFriendsToInvite.append(friends[indexPath.row])
            }
            
            delegate?.inviteFriendsViewControllerDidSelectFriendsToInvite(selectedFriendsToInvite)
        }
    }
    
    func fetchFacebookFriends() {
        MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields":"id,name,picture.width(200).height(200)"])
        request.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error != nil {
                print(error, terminator: "")
                //show error message to user
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
                    
                    self.noConnectionLabel.hidden = false
                })
                return
            }
            if let friendArray = result.valueForKey("data") as? NSArray {
                if friendArray.count == 0 {
                    self.noFriendsLabel.hidden = false
                }
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
            } else {
                self.noFriendsLabel.hidden = false
            }
        })

    }
    
    @IBAction func dismissButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pulledToRefresh(sender: UIRefreshControl) {
        fetchFacebookFriends()
        sender.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! InviteFriendsTableViewCell!
        if cell == nil {
            cell = InviteFriendsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "FriendCell")
        }
        if indexPath.row < self.friends.count {
            let fbFriend = self.friends[indexPath.row]
            cell.name.text = fbFriend.name
            cell.profilePicture.sd_setImageWithURL(fbFriend.profilePictureURL, placeholderImage: UIImage(named: "placeholder.jpg"))
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.accessoryType = UITableViewCellAccessoryType.Checkmark
//        if !inviteButton.enabled {
//            inviteButton.enabled = true
//        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.accessoryType = UITableViewCellAccessoryType.None
        let indexPaths = self.tableView.indexPathsForSelectedRows
        if indexPaths == nil {
//            inviteButton.enabled = false
        }
    }
}
