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
        static let databaseUpcomingTasks = databaseRoot.child("upcomingTasks")
        static let databaseUserSelectedDate = databaseRoot.child("userDate")
        static let storage = Storage.storage().reference()
    }
}
