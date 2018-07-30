//
//  RSVPViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/16/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

protocol RSVPViewControllerDelegate
{
    func setRSVPCurrentTask()
    
}

class RSVPViewController: UIViewController {
    var delegate: RSVPViewControllerDelegate?
    var task: Task?
    var leadersRSVP: [String] = []
    var participantsRSVP: [String] = []
    var isLead = false
    var isParticipant = false
    @IBOutlet weak var leadersNeededLabel: UILabel!
    @IBOutlet weak var partipantsNeededLabel: UILabel!
    @IBOutlet weak var leaderStack: UIStackView!
    @IBOutlet weak var participateStack: UIStackView!
    @IBOutlet weak var signUpLeaderButton: UIButton!
    @IBOutlet weak var goingParticipantButton: UIButton!
    @IBOutlet weak var alreadyInvolvedLabel: UILabel!
    @IBOutlet weak var undoSignUpButton: UIButton!
    @IBOutlet weak var undoGoingButton: UIButton!
    
    @IBAction func goingParticipantButton(_ sender: UIButton) {
    Constants.refs.databaseTasks.child((task?.id)!).child("taskRSVP").child("participants").child(currentUser.uid).child("userID").setValue(currentUser.uid)
        
        Constants.refs.databaseTasks.child(task!.id).child("ranking").setValue(task!.ranking + 2)
    }
    @IBAction func undoGoingButton(_ sender: UIButton) {
    Constants.refs.databaseTasks.child((task?.id)!).child("taskRSVP").child("participants").child(currentUser.uid).removeValue()
        
        Constants.refs.databaseTasks.child(task!.id).child("ranking").setValue(task!.ranking - 2)
        
        participantsRSVP.remove(at: participantsRSVP.index(of: currentUser.uid)!)
        self.viewDidLoad()
    }
    @IBAction func signUpLeaderButton(_ sender: UIButton) {
        Constants.refs.databaseTasks.child((task?.id)!).child("taskRSVP").child("leaders").child(currentUser.uid).child("userID").setValue(currentUser.uid)
        
        Constants.refs.databaseTasks.child(task!.id).child("ranking").setValue(task!.ranking + 2)
        
            Constants.refs.databaseUsers.child(currentUser.uid).child("tasks_lead").child(task!.id).setValue(true)
        
        let point = Points.init()

        let addedPoints = point.getPoints(type: "Lead", thisTask: task!)
        
        Constants.refs.databaseUsers.child(currentUser.uid).child("points").setValue(currentUser.points + addedPoints)
        
    }
    
    @IBAction func undoSignUpButton(_ sender: UIButton) {
        Constants.refs.databaseTasks.child((task?.id)!).child("taskRSVP").child("leaders").child(currentUser.uid).removeValue()
        Constants.refs.databaseTasks.child(task!.id).child("ranking").setValue(task!.ranking - 2)
        Constants.refs.databaseUsers.child(currentUser.uid).child("tasks_lead").child(task!.id).removeValue()
        let point = Points.init()
        let subtractedPoints = point.getPoints(type: "Lead", thisTask: task!)
        Constants.refs.databaseUsers.child(currentUser.uid).child("points").setValue(currentUser.points - subtractedPoints)
        
        leadersRSVP.remove(at: leadersRSVP.index(of: currentUser.uid)!)
        self.viewDidLoad()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        alreadyInvolvedLabel.isHidden = true
        undoGoingButton.isHidden = true
        undoSignUpButton.isHidden = true
        goingParticipantButton.isEnabled = true
        signUpLeaderButton.isEnabled = true
        configurePage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func userAlreadySignedUp(){
        signUpLeaderButton.isEnabled = false
        goingParticipantButton.isEnabled = false
        alreadyInvolvedLabel.isHidden = false
        undoSignUpButton.isHidden = false
        return
    }
    
    private func userAlreadyGoing(){
        signUpLeaderButton.isEnabled = false
        goingParticipantButton.isEnabled = false
        alreadyInvolvedLabel.isHidden = false
        undoGoingButton.isHidden = false
        return
    }

    private func configurePage(){
        leaderStack.isHidden = true
        participateStack.isHidden = true
        
        let tags = task?.tag
        let tagArray = tags?.components(separatedBy: " ")
        for tag in tagArray!{
            if tag == "#lead"{
                isLead = true
                Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("leaders").observe(.value, with: { snapshot in
                    if (snapshot.exists()){
                        for child in snapshot.children {
                            if let snapshot = child as? DataSnapshot{
                                let leaderInfo = snapshot.value as! [String : String ]
                                if (leaderInfo["userID"]! == currentUser.uid){
                                    self.userAlreadySignedUp()
                                }
                                if !self.leadersRSVP.contains(leaderInfo["userID"]!){
                                    self.leadersRSVP.append(leaderInfo["userID"]!)
                                }
                            }
                            if self.task!.amounts["leaders"]! == self.leadersRSVP.count {
                                self.signUpLeaderButton.isEnabled = false
                            }
                        }
                        self.leaderStack.isHidden = false
                        self.leadersNeededLabel.text = "\(String(describing: (self.task!.amounts["leaders"]!-self.leadersRSVP.count))) leader spots left"
                    }
                    else{
                        if self.task!.amounts["leaders"]! == self.leadersRSVP.count {
                            self.signUpLeaderButton.isEnabled = false
                        }
                        self.leaderStack.isHidden = false
                        self.leadersNeededLabel.text = "\(String(describing: (self.task!.amounts["leaders"]!-self.leadersRSVP.count))) leader spots left"
                    }
                })
            }
            if tag == "#participate"{
                isParticipant = true
                //Getting RSVP-ed participants
                Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("participants").observe(.value, with: { snapshot in
                    if (snapshot.exists()){
                        for child in snapshot.children {
                            if let snapshot = child as? DataSnapshot{
                                let participantInfo = snapshot.value as! [String : String ]
                                if (participantInfo["userID"]! == currentUser.uid){
                                    self.userAlreadyGoing()
                                }
                                if !self.participantsRSVP.contains(participantInfo["userID"]!){
                                    self.participantsRSVP.append(participantInfo["userID"]!)
                                }
                                
                            }
                            if self.task!.amounts["participants"]! == self.participantsRSVP.count {
                                self.goingParticipantButton.isEnabled = false
                            }
                        }
                        self.participateStack.isHidden = false
                        self.partipantsNeededLabel.text = "\(String(describing: (self.task!.amounts["participants"]!-self.participantsRSVP.count))) participant spots left"
                    }
                    else{
                        if self.task!.amounts["participants"]! == self.participantsRSVP.count {
                            self.goingParticipantButton.isEnabled = false
                        }
                        self.participateStack.isHidden = false
                        self.partipantsNeededLabel.text = "\(String(describing: (self.task!.amounts["participants"]!-self.participantsRSVP.count))) participant spots left"
                    }
                })
            }
        }
        return
    }
    
}
