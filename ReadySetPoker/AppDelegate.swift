//
//  AppDelegate.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/22/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let userNotificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound)
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        PokerEvent.registerSubclass()
        Invite.registerSubclass()
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        // Initialize Parse.
        Parse.setApplicationId("evBPAta2oDPYkyo9nWjyE3lsEy745R6JUCnDjyzn",
            clientKey: "WRL99ZE53pTzlTDPAwUFiAYSEIziDOazZ1rgOfpD")
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)

        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        var storyboardName = "LoggedOutState"

        if let currentUser = PFUser.currentUser() {
            var fullName = currentUser["fullName"] as! String
            println("Signed in as \(fullName)")
            storyboardName = "LoggedInState"
        }
        
        let initialStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        let viewController = initialStoryboard.instantiateInitialViewController() as! UIViewController
        
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
            if let eventId = userInfo["eventObjectId"] as? String {
                var inviteRelation = PFUser.currentUser()!.relationForKey("invites")
                var inviteQuery = inviteRelation.query()!
                var event = PFObject(withoutDataWithClassName: "PokerEvent", objectId: eventId)
                inviteQuery.whereKey("event", equalTo: event)
                inviteQuery.includeKey("event")
                inviteQuery.findObjectsInBackgroundWithBlock({ (result: [AnyObject]?, error: NSError?) -> Void in
                    if let result = result {
                        let invite = result.first as! Invite
                        let storyboard = UIStoryboard(name: "LoggedInState", bundle: nil)
                        
                        let rootVC = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                        if PFUser.currentUser() != nil {
                            rootVC.selectedIndex = 0
                            self.window!.rootViewController = rootVC
                            let navController = rootVC.viewControllers?.first as! UINavigationController
                            let eventListVC = navController.topViewController as! EventListViewController
                            let eventDetailVC = storyboard.instantiateViewControllerWithIdentifier("eventDetailVC") as! EventDetailViewController
                            eventDetailVC.invite = invite
                            eventListVC.navigationController?.pushViewController(eventDetailVC, animated: false)
                        }
                    }
                })
            }
        } else {
//            let message = userInfo["alert"] as! String
//            let alertController = UIAlertController(title: "ReadySetPoker", message: message, preferredStyle: .Alert)
//            let dismissButton = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
//            alertController.addAction(dismissButton)
//            let viewButton = UIAlertAction(title: "View", style: .Default, handler: { (action: UIAlertAction!) -> Void in
//                let storyboard = UIStoryboard(name: "LoggedInState", bundle: nil)
//                let rootVC = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
//                if PFUser.currentUser() != nil {
//                    rootVC.selectedIndex = 0
//                    self.window!.rootViewController = rootVC
//                    let navController = rootVC.viewControllers?.first as! UINavigationController
//                    let eventListVC = navController.topViewController as! EventListViewController
//                    let eventDetailVC = storyboard.instantiateViewControllerWithIdentifier("eventDetailVC") as! EventDetailViewController
//                    eventDetailVC.invite = invite
//                    eventListVC.navigationController?.pushViewController(eventDetailVC, animated: false)
//                }
//            })
        }
    }
}
