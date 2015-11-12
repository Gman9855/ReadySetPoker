//
//  CDInvite.swift
//  ReadySetPoker
//
//  Created by Gershy Lev on 11/11/15.
//  Copyright © 2015 ReadySetPoker. All rights reserved.
//

import UIKit
import CoreData

@objc(CDInvite)

class CDInvite: NSManagedObject {
    
    @NSManaged var parseObjectID: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(parseObjectID: String, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("CDInvite", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.parseObjectID = parseObjectID
    }
}
