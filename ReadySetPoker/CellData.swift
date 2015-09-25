//
//  CellData.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 9/14/15.
//  Copyright (c) 2015 ReadySetPoker. All rights reserved.
//

import Foundation

class CellData: NSObject {
    
    var type: UITableViewCell.Type!
    var height: CGFloat?
    
    init(type: UITableViewCell.Type, height: CGFloat?) {
        self.type = type
        self.height = height
    }
}