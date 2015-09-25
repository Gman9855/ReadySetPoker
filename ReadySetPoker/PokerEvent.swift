//
//  PokerEvent.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/23/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation
import Parse

class PokerEvent: Event, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "PokerEvent"
    }
    
    @NSManaged var gameType: String
    @NSManaged var gameFormat: String
    @NSManaged var cashGameBuyInMinimum: NSInteger
    @NSManaged var cashGameBuyInMaximum: NSInteger
    @NSManaged var tournamentBuyIn: NSInteger
    @NSManaged var maximumSeats: NSInteger
    
    @objc enum GameFormat: Int {
        case Cash
        case Tournament
    }
    
    
}
