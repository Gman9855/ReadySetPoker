//
//  LoginViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/22/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var imageView = UIImageView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginWithFacebookButtonTapped(sender: UIButton) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email", "user_friends"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    println("User signed up and logged in through Facebook!")

                    let request = FBSDKGraphRequest(graphPath: "\(FBSDKAccessToken.currentAccessToken().userID)", parameters: nil, HTTPMethod: "GET")
                    request.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                        let resultDict = result as! [String: String]
                        user["facebookID"] = resultDict["id"]
                        user["fullName"] = resultDict["name"]
                        user.saveInBackground()
                    })
                }
                FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
                
                let installation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackground()
                
                let loggedInStoryboard = UIStoryboard(name: "LoggedInState", bundle: nil)
                let viewController = loggedInStoryboard.instantiateInitialViewController() as! UITabBarController
                self.presentViewController(viewController, animated: true, completion: nil)
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
                print(error)
            }
        }
    }
}

