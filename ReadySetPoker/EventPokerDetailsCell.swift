//
//  EventPokerDetailsCell.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 11/4/15.
//  Copyright © 2015 ReadySetPoker. All rights reserved.
//

import UIKit

class EventPokerDetailsCell: EventDetailsCell {
    
    @IBOutlet weak var gameTypeAndGameFormat: UILabel!
    @IBOutlet weak var gameBlindsOrTournamentBuyin: UILabel!
    
    override func configureWithInvite(invite: Invite) {
        gameTypeAndGameFormat.text = invite.event.gameType + " " + invite.event.gameFormat
        let cashGameBlindsString = String(invite.event.cashGameSmallBlind) + "/" + String(invite.event.cashGameBigBlind)
        gameBlindsOrTournamentBuyin.text = invite.event.gameFormat == "Cash Game" ? "Blinds:  $\(cashGameBlindsString)" : "Tournament Buy-In:  $\(Int(invite.event.tournamentBuyIn))"
    }
    

}
