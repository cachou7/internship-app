//
//  CheckInViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/18/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

protocol CheckInViewControllerDelegate
{
    func setCheckInCurrentTask()
    
}

class CheckInViewController: UIViewController {
    var delegate: CheckInViewControllerDelegate?
    @IBOutlet weak var checkInButton: UIButton!
    var task: Task?
    var usersCheckedIn: [String] = []
    @IBOutlet weak var alreadyCheckedInLabel: UILabel!

    @IBOutlet weak var usersCheckedInLabel: UILabel!
    @IBAction func checkInButton(_ sender: UIButton) {
        Constants.refs.databaseTasks.child((task?.id)!).child("taskCheckIn").child(currentUser.uid).child("userID").setValue(currentUser.uid)
        
        Constants.refs.databaseTasks.child(task!.id).child("ranking").setValue(task!.ranking + 3)
        
        Constants.refs.databaseUsers.child(currentUser.uid ).child("tasks_participated").child(task!.id).setValue(true)
        let point = Points.init()
        
        
        let addedPoints = point.getPoints(type: "Participant", category: task!.category, thisTask: task!)
        
        Constants.refs.databaseUsers.child(currentUser.uid).child("points").setValue(currentUser.points + addedPoints)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(task!.id)
        alreadyCheckedInLabel.isHidden = true
        configurePage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func userAlreadyCheckedIn(){
        //signUpLeaderButton.isEnabled = false
        alreadyCheckedInLabel.isHidden = false
        return
    }
    
    private func configurePage(){
        //Getting users that are already checked in
        Constants.refs.databaseTasks.child(task!.id).child("taskCheckIn").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let checkedInInfo = snapshot.value as! [String : String ]
                        if !self.usersCheckedIn.contains(checkedInInfo["userID"]!){
                            self.usersCheckedIn.append(checkedInInfo["userID"]!)
                        }
                    
                        if (checkedInInfo["userID"]! == currentUser.uid){
                            self.alreadyCheckedInLabel.isHidden = false
                            self.checkInButton.isEnabled = false
                        }
                    }
                }
                  self.usersCheckedInLabel.text = "\(String(describing: self.usersCheckedIn.count)) people already checked in"
            }
            else{
                self.usersCheckedInLabel.text = "\(String(describing: self.usersCheckedIn.count)) people already checked in"
            }
        })
        return
    }
    
}
