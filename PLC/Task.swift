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
    var timestamp: TimeInterval
    var id: String
    var createdBy: String
    var ranking: Int
    var timeMilliseconds: TimeInterval
    var type: String
    var amounts: Dictionary<String, Int>
    var users_liked = [String:Bool]()
    
    //MARK: Initialization
    
    init?(title: String, description: String, tag: String, time: String, location: String, timestamp: TimeInterval, id: String, createdBy: String, ranking: Int, timeMilliseconds: TimeInterval, type:String, amounts: Dictionary<String, Int>) {
        
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
        self.createdBy = createdBy
        self.ranking = ranking
        self.timeMilliseconds = timeMilliseconds
        self.type = type
        self.amounts = amounts
    }
}
