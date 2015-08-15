//
//  RSVPViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/13/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

protocol RSVPViewControllerDelegate {
    func RSVPViewControllerDidRespondToRSVP(isGoing: Bool, withGuests: Int)
}

class RSVPViewController: UITableViewController {

    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var guestsJoining: Int = 0
    var delegate: RSVPViewControllerDelegate?
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "BringingGuestsCell" {
            let array = ["0 Guests", "1 Guest", "2 Guests", "3 Guests"]
            var picker = ActionSheetStringPicker(title: nil, rows: array, initialSelection: 1, doneBlock: { (picker: ActionSheetStringPicker!, selectedIndex: Int, selectedValue: AnyObject!) -> Void in
                self.guestsLabel.text = selectedValue as? String
                self.guestsJoining = selectedIndex
                }, cancelBlock: { (picker: ActionSheetStringPicker!) -> Void in
                print("Block picker canceled")
            }, origin: self.view)
            picker.showActionSheetPicker()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func rsvpButtonTapped(sender: UIButton) {
        var segmentedControlIndex: Int = segmentedControl.selectedSegmentIndex
        var isGoing = segmentedControlIndex == 0
        
        // update model on parse
        
        delegate?.RSVPViewControllerDidRespondToRSVP(isGoing, withGuests: guestsJoining)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
