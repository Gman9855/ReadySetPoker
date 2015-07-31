//
//  FacebookFriend.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/29/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation

class FacebookFriend {
    var name: String!
    var userID: String!
    var profilePictureURL: NSURL?
    
    
    init(name: String, userID: String, profilePictureURL: NSURL?) {
        self.name = name
        self.userID = userID
        self.profilePictureURL = profilePictureURL
    }
}