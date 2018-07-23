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
        static let databaseRoot = Database.database().reference()
        static let databaseTasks = databaseRoot.child("tasks")
        static let databaseUsers = databaseRoot.child("users")
        static let databaseEngineering = databaseRoot.child("Engineering")
        static let databaseStrategy = databaseRoot.child("Strategy")
        static let databaseMarketing = databaseRoot.child("Marketing")
        static let databaseUpcomingTasks = databaseRoot.child("upcomingTasks")
        static let databaseCurrentTasks = databaseRoot.child("currentTasks")
        static let databasePastTasks = databaseRoot.child("pastTasks")
        static let databaseUserSelectedDate = databaseRoot.child("userDate")
        static let storage = Storage.storage().reference()
    }
}
