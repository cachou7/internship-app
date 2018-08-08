//
//  LeaderboardTutorialViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 8/6/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class LeaderboardTutorialViewController: UIViewController {
    //MARK: Properties
    var segueFromController: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Actions
    @IBAction func doneButton(_ sender: UIButton) {
        //Unwind segue to its parent view
        if segueFromController == "ProfileViewController"{
            self.performSegue(withIdentifier: "unwindToProfile", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "unwindToCreateNewAccount", sender: self)
        }
    }

}
