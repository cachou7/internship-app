//
//  LeaderboardTutorialViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 8/6/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class LeaderboardTutorialViewController: UIViewController {
    var segueFromController: String?
    
    @IBAction func doneButton(_ sender: UIButton) {
        if segueFromController == "ProfileViewController"{
             self.performSegue(withIdentifier: "unwindToProfile", sender: self)
        }
        else {
             self.performSegue(withIdentifier: "unwindToCreateNewAccount", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
