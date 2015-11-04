//
//  EventDescriptionViewController.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 11/4/15.
//  Copyright © 2015 ReadySetPoker. All rights reserved.
//

import UIKit

class EventDescriptionViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var eventDescription: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "More Details"
        textView.text = eventDescription
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
