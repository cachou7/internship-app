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
    let tasks_liked: [String] = []
    let tasks_created: [String] = []
    let firstName: String
    let lastName: String
    let jobTitle: String
    let department: String
    let currentProjects: String
    init(authData: Firebase.User, firstName: String, lastName: String, jobTitle: String, department: String, currentProjects: String) {
        self.uid = authData.uid
        self.firstName = firstName
        self.lastName = lastName
        self.jobTitle = jobTitle
        self.department = department
        self.currentProjects = currentProjects
    }
    
    //MARK: Initialization
    init?(uid: String, firstName: String, lastName: String, jobTitle: String, department: String, currentProjects: String) {
        // Initialize stored properties.
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.jobTitle = jobTitle
        self.department = department
        self.currentProjects = currentProjects
    }
}
