//
//  Task.swift
//  PLC
//
//  Created by Connor Eschrich on 6/28/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class Task{
    //MARK: Properties
    var title: String
    var description: String
    var tag: String
    var time: String
    var location: String
    var timestamp: String
    var id: String
    
    //MARK: Initialization
    
    init?(title: String, description: String, tag: String, time: String, location: String, timestamp: String, id: String) {
        
        // The title must not be empty
        guard !title.isEmpty else {
            return nil
        }
        
        
        // Initialize stored properties.
        self.title = title
        self.description = description
        self.tag = tag
        self.location = location
        self.time = time
        self.timestamp = timestamp
        self.id = id
    }
}
