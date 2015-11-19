//
//  EventCreationController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 11/2/15.
//  Copyright © 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import Eureka

class EventCreationController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create a game"
        form +++ Section("Game Title")
            <<< TextRow() {
                $0.title = "Game Title"
                $0.placeholder = "Write a title..."
            }
        
        +++ Section()
            <<< DateTimeInlineRow() {
                $0.title = "Start Time"
            }
            
            <<< DateTimeInlineRow() {
                $0.title = "End Time"
            }
        
        +++ Section("Game Description")
            <<< TextAreaRow() {
                $0.placeholder = "Write a brief description..."
            }
            
        +++ Section("Game Info")
            <<< SegmentedRow<String>("GameFormat") {
                $0.options = ["Cash Game", "Tournament"]
                $0.value = "Cash Game"
            }
            
            <<< DecimalRow() {
                $0.title = "Small Blind"
                $0.hidden = Condition.Function(["GameFormat"], { (form) -> Bool in
                    if let segmentedIndex: SegmentedRow<String> = form.rowByTag("GameFormat") {
                        return segmentedIndex.value == "Tournament"
                    }
                    return true
                })
            }
            
            <<< DecimalRow() {
                $0.title = "Big Blind"
                $0.hidden = Condition.Function(["GameFormat"], { (form) -> Bool in
                    if let segmentedIndex: SegmentedRow<String> = form.rowByTag("GameFormat") {
                        return segmentedIndex.value == "Tournament"
                    }
                    return true
                })
            }
            
            <<< DecimalRow() {
                $0.title = "Buy-In Amount"
                $0.hidden = Condition.Function(["GameFormat"], { (form) -> Bool in
                    if let segmentedIndex: SegmentedRow<String> = form.rowByTag("GameFormat") {
                        return segmentedIndex.value == "Cash Game"
                    }
                    return true
                })
            }
            
        +++ Section()
            <<< TextRow() {
                $0.title = "Game Type"
                $0.placeholder = "NLHE, PLO, Stud"
            }
        
            <<< IntRow() {
                $0.title = "Number of seats"
            }
            
        +++ Section()
            <<< MultipleSelectorRow<String> {
                $0.title = "Invite Friends"
                $0.options = ["Yuval", "Ben", "Jacob", "Sim", "Rachel", "Anjali"]
            }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
