//
//  RSVPViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/13/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class RSVPViewController: UITableViewController {

    @IBOutlet weak var guestsLabel: UILabel!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "BringingGuestsCell" {
            let array = ["0 Guests", "1 Guest", "2 Guests", "3 Guests"]
            var picker = ActionSheetStringPicker(title: nil, rows: array, initialSelection: 0, doneBlock: { (picker: ActionSheetStringPicker!, selectedIndex: Int, selectedValue: AnyObject!) -> Void in
                self.guestsLabel.text = selectedValue as? String
                }, cancelBlock: { (picker: ActionSheetStringPicker!) -> Void in
                print("Block picker canceled")
            }, origin: self.view)
            picker.showActionSheetPicker()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
