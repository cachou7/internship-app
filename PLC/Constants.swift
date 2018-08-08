//
//  Constants.swift
//  PLC
//
//  Created by Connor Eschrich on 6/29/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import Firebase

struct Constants
{
    
    struct refs
    {
        // Database root
        static let databaseRoot = Database.database().reference()
        // Access tasks branch in database
        static let databaseTasks = databaseRoot.child("tasks")
        // Access users branch in database
        static let databaseUsers = databaseRoot.child("users")
        
        // Access departments in database
        static let databaseEngineering = databaseRoot.child("Engineering")
        static let databaseStrategy = databaseRoot.child("Strategy")
        static let databaseMarketing = databaseRoot.child("Marketing")
        
        // Access different status of tasks (upcoming, current, past, pending)
        static let databaseUpcomingTasks = databaseRoot.child("upcomingTasks")
        static let databaseCurrentTasks = databaseRoot.child("currentTasks")
        static let databasePastTasks = databaseRoot.child("pastTasks")
        static let databasePendingTasks = databaseRoot.child("pendingTasks")
        
        // Access date user has selected on calendar view
        static let databaseUserSelectedDate = databaseRoot.child("userDate")
        
        // Set up Firebase Storage ref
        static let storage = Storage.storage().reference()
    }
}
