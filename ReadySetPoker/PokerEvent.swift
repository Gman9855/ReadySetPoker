//
//  PokerEvent.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/23/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation
import Parse

enum GameFormat: String {
    case CashGame = "Cash Game"
    case Tournament = "Tournament"
}

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
    @NSManaged var cashGameSmallBlind: Float
    @NSManaged var cashGameBigBlind: Float
    @NSManaged var cashGameBuyInMinimum: Float
    @NSManaged var cashGameBuyInMaximum: Float
    @NSManaged var tournamentBuyIn: Float
    @NSManaged var maximumSeats: NSInteger
}
