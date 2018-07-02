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
    
    init(authData: Firebase.User) {
        uid = authData.uid
    }
    
    //MARK: Initialization
    init?(uid: String) {
        
        // Initialize stored properties.
        self.uid = uid
    }
}
