//
//  PokerEvent.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 7/23/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation

class PokerEvent: Event {
    var gameVariant: String!
    var gameFormat: GameFormat!
    var cashGameBuyInMinimum: String!
    var cashGameBuyInMaximum: String!
    var tournamentBuyIn: String!
    
    enum GameFormat {
        case cash
        case tournament
    }
}
