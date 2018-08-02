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
    let funFact: String
    var points: Int
    let email: String
    
    init(authData: Firebase.User, firstName: String, lastName: String, jobTitle: String, department: String, funFact: String, points: Int) {
        self.uid = authData.uid
        self.firstName = firstName
        self.lastName = lastName
        self.jobTitle = jobTitle
        self.department = department
        self.funFact = funFact
        self.points = points
        self.email = authData.email!
    }
    
    //MARK: Initialization
    init?(uid: String, firstName: String, lastName: String, jobTitle: String, department: String, funFact: String, points: Int, email: String) {
        // Initialize stored properties.
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.jobTitle = jobTitle
        self.department = department
        self.funFact = funFact
        self.points = points
        self.email = email
    }
}
