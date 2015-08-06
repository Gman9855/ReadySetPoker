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
    
    override func viewDidLoad() {
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields":"id,name,picture.width(200).height(200)"])
        request.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            print(result)
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
                self.tableView.reloadData()
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
        if self.friends.count > 0 {
            let fbFriend = self.friends[indexPath.row]
            cell.name.text = fbFriend.name
            cell.profilePicture.sd_setImageWithURL(fbFriend.profilePictureURL, placeholderImage: UIImage(named: "placeholder"))
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.height / 2;
            cell.profilePicture.layer.masksToBounds = true;
            cell.profilePicture.layer.borderWidth = 0
        }
        
        return cell
    }
    
}
