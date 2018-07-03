//
//  UserModel.swift
//  PLC
//
//  Created by Chris on 6/29/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

class User{
    //MARK: Properties
    let uid: String
    let tasks_liked = [String:Bool]()
    let tasks_created = [String:Bool]()
    let firstName: String
    let lastName: String
    let jobTitle: String
    let department: String
    let currentProjects: String
    let points: Int
    
    init(authData: Firebase.User, firstName: String, lastName: String, jobTitle: String, department: String, currentProjects: String, points: Int) {
        self.uid = authData.uid
        self.firstName = firstName
        self.lastName = lastName
        self.jobTitle = jobTitle
        self.department = department
        self.currentProjects = currentProjects
        self.points = points
    }
    
    //MARK: Initialization
    init?(uid: String, firstName: String, lastName: String, jobTitle: String, department: String, currentProjects: String, points: Int) {
        // Initialize stored properties.
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.jobTitle = jobTitle
        self.department = department
        self.currentProjects = currentProjects
        self.points = points
    }
}
