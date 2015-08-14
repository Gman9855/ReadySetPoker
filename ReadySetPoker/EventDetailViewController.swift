//
//  EventDetailViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 8/11/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import UIKit

class EventDetailViewController: UITableViewController {
    
    var pokerEvent: PokerEvent!
    let defaultHeight: CGFloat = UITableViewAutomaticDimension
    let cellData: [(CGFloat?, UITableViewCell.Type)]! = [(54, EventTitleCell.self), (nil, EventDateCell.self), (64, EventLocationCell.self), (nil, EventCommentsCell.self), (nil, EventDetailsCell.self), (64, EventRSVPCell.self)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Event Details"
        self.tableView.estimatedRowHeight = 50.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let (height, cellType) = cellData[indexPath.row]
        let cellReuseIdentifier = reflect(cellType).summary
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as? UITableViewCell
        if let cell = cell {
            return cell
        }
        
        return cellType(style: UITableViewCellStyle.Default, reuseIdentifier: cellReuseIdentifier)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    @IBAction func rsvpButtonTapped(sender: UIButton) {
        let rsvpVC = storyboard?.instantiateViewControllerWithIdentifier("rsvpVC") as! UINavigationController
        presentViewController(rsvpVC, animated: true, completion: nil)
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let (height, cellType) = cellData[indexPath.row]
        return height != nil ? height! : defaultHeight
    }
}
