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
    @IBOutlet weak var leadersNeededLabel: UILabel!
    @IBOutlet weak var partipantsNeededLabel: UILabel!
    @IBOutlet weak var leaderStack: UIStackView!
    @IBOutlet weak var participateStack: UIStackView!
    @IBOutlet weak var signUpLeaderButton: UIButton!
    @IBOutlet weak var goingParticipantButton: UIButton!
    @IBOutlet weak var alreadyInvolvedLabel: UILabel!
    
    @IBAction func goingParticipantButton(_ sender: UIButton) {
        Constants.refs.databaseTasks.child((task?.id)!).child("taskRSVP").child("participants").child(currentUser.uid).child("userID").setValue(currentUser.uid)
        
        Constants.refs.databaseTasks.child(task!.id).child("ranking").setValue(task!.ranking + 2)
        
        //self.viewDidLoad()
    }
    @IBAction func signUpLeaderButton(_ sender: UIButton) {
        Constants.refs.databaseTasks.child((task?.id)!).child("taskRSVP").child("leaders").child(currentUser.uid).child("userID").setValue(currentUser.uid)
        
        Constants.refs.databaseTasks.child(task!.id).child("ranking").setValue(task!.ranking + 2)
        //self.viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(task!.id)
        alreadyInvolvedLabel.isHidden = true
        configurePage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func userAlreadySignedUp(){
        signUpLeaderButton.isEnabled = false
        goingParticipantButton.isEnabled = false
        alreadyInvolvedLabel.isHidden = false
        return
    }

    private func configurePage(){
        leaderStack.isHidden = true
        participateStack.isHidden = true
        
        let tags = task?.tag
        let tagArray = tags?.components(separatedBy: " ")
        for tag in tagArray!{
            if tag == "#lead"{
                Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("leaders").observe(.value, with: { snapshot in
                    var newLeaders: [String] = []
                    if (snapshot.exists()){
                        for child in snapshot.children {
                            print(child)
                            if let snapshot = child as? DataSnapshot{
                                let leaderInfo = snapshot.value as! [String : String ]
                                print(leaderInfo)
                                print(leaderInfo["userID"]!)
                                if (leaderInfo["userID"]! == currentUser.uid){
                                    self.signUpLeaderButton.isEnabled = false
                                    self.goingParticipantButton.isEnabled = false
                                    self.alreadyInvolvedLabel.isHidden = false
                                }
                                newLeaders.append(leaderInfo["userID"]!)
                            }
                            self.leadersRSVP.append(contentsOf: newLeaders)
                            print(self.leadersRSVP.count)
                            if self.task!.amounts["leaders"]! == self.leadersRSVP.count {
                                self.signUpLeaderButton.isEnabled = false
                            }
                            self.leaderStack.isHidden = false
                            self.leadersNeededLabel.text = "\(String(describing: (self.task!.amounts["leaders"]!-self.leadersRSVP.count))) out of \(String(describing: self.task!.amounts["leaders"]!)) leaders needed"
                        }
                    }
                    else{
                        if self.task!.amounts["leaders"]! == self.leadersRSVP.count {
                            self.signUpLeaderButton.isEnabled = false
                        }
                        self.leaderStack.isHidden = false
                        self.leadersNeededLabel.text = "\(String(describing: (self.task!.amounts["leaders"]!-self.leadersRSVP.count))) out of \(String(describing: self.task!.amounts["leaders"]!)) leaders needed"
                    }
                })
            }
            if tag == "#participate"{
                //Getting RSVP-ed participants
                Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("participants").observe(.value, with: { snapshot in
                    var newParticipants: [String] = []
                    if (snapshot.exists()){
                        for child in snapshot.children {
                            if let snapshot = child as? DataSnapshot{
                                let participantInfo = snapshot.value as! [String : String ]
                                if (participantInfo["userID"]! == currentUser.uid){
                                    self.signUpLeaderButton.isEnabled = false
                                    self.goingParticipantButton.isEnabled = false
                                    self.alreadyInvolvedLabel.isHidden = false
                                }
                                newParticipants.append(participantInfo["userID"]!)
                            }
                            self.participantsRSVP.append(contentsOf: newParticipants)
                            if self.task!.amounts["participants"]! == self.participantsRSVP.count {
                                self.goingParticipantButton.isEnabled = false
                            }
                            self.participateStack.isHidden = false
                            self.partipantsNeededLabel.text = "\(String(describing: (self.task!.amounts["participants"]!-self.participantsRSVP.count))) out of \(String(describing: self.task!.amounts["participants"]!)) participants needed"
                        }
                    }
                    else{
                        if self.task!.amounts["participants"]! == self.participantsRSVP.count {
                            self.goingParticipantButton.isEnabled = false
                        }
                        self.participateStack.isHidden = false
                        self.partipantsNeededLabel.text = "\(String(describing: (self.task!.amounts["participants"]!-self.participantsRSVP.count))) out of \(String(describing: self.task!.amounts["participants"]!)) participants needed"
                    }
                })
            }
        }
        return
    }
    
}
