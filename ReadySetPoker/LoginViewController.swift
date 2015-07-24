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

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view, typically from a nib.
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
                } else {
                    println("User logged in through Facebook!")
                }
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
}

