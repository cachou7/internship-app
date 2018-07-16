//
//  DetailTaskViewController.swift
//  PLC
//
//  Created by Chris on 6/28/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

class DetailTaskViewController: UIViewController {
    
    var task_in:Task!
    var taskIndex: Int!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var taskTime: UILabel!
    @IBOutlet weak var taskEndTime: UILabel!
    @IBOutlet weak var taskCreatedBy: UILabel!
    @IBOutlet weak var taskDescription: UILabel!
    @IBOutlet weak var taskLeaderAmount: UILabel!
    @IBOutlet weak var taskParticipantAmount: UILabel!
    //var titleViaSegue:String?
    @IBOutlet weak var participateLabel: UILabel!
    
    @IBOutlet weak var leaderStack: UIStackView!
    @IBOutlet weak var participateStack: UIStackView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var leadLabel: UILabel!
    @IBOutlet weak var createLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        taskTitle.text = task_in.title
        taskLocation.text = task_in.location
        taskTime.text = task_in.startTime
        taskEndTime.text = task_in.endTime
        taskDescription.text = task_in.description
        //Setting the label for the user who created event
        Constants.refs.databaseUsers.child(task_in.createdBy).observeSingleEvent(of: .value, with: {(snapshot) in
            self.taskCreatedBy.text = (snapshot.childSnapshot(forPath: "firstName").value as! String) + " " + (snapshot.childSnapshot(forPath: "lastName").value as! String)
            })

        if task_in.createdBy == currentUser.uid{
            editButton.isEnabled = true
            deleteButton.isEnabled = true
        }
        else{
            editButton.isEnabled = false
            deleteButton.isEnabled = false
        }
        
        let tags = task_in.tag
        let tagArray = tags.components(separatedBy: " ")
        for tag in tagArray{
            if tag == "#lead"{
                taskLeaderAmount.text = "\(String(describing: task_in.amounts["leaders"]!))"
                leadLabel.isEnabled = true
                leadLabel.textColor = UIColor(red: 118.0/255.0, green:48.0/255.0, blue:255.0/255.0, alpha: 1.0)
            }
            else{
                leaderStack.isHidden = true
            }
            if tag == "#participate"{
                taskLeaderAmount.text = "\(String(describing: task_in.amounts["participants"]!))"
                participateLabel.isEnabled = true
                participateLabel.textColor = UIColor(red: 118.0/255.0, green:48.0/255.0, blue:255.0/255.0, alpha: 1.0)
            }
            else{
                participateStack.isHidden = true
            }
        }
    }
    
    // align description to upper left
    override func viewWillLayoutSubviews() {
        taskDescription.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Task", message: "Are you sure you want to delete this task?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Constants.refs.databaseTasks.child(self.task_in.id).child("users_liked").observeSingleEvent(of: .value, with: { snapshot in
            for user in snapshot.children{
                let userInfo = user as! DataSnapshot
                    print(userInfo.key)
                Constants.refs.databaseUsers.child(userInfo.key).child("tasks_liked").child(self.task_in.id).removeValue()
                }});
            Constants.refs.databaseUsers.child(self.task_in.createdBy).child("tasks_created").child(self.task_in.id).removeValue();
            Constants.refs.databaseTasks.child(self.task_in.id).removeValue()
            
            self.performSegue(withIdentifier: "unwindToInitiatives", sender: self)
           
            
            })
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask", let destinationVC = segue.destination as? EditInitiativeViewController, let task_out = task_in {
            destinationVC.task_in = task_out
        }
    }
    
    @IBAction func unwindToDetail(segue:UIStoryboardSegue) {
        if segue.source is EditInitiativeViewController{
            Constants.refs.databaseTasks.child(task_in.id).observeSingleEvent(of: .value, with: { snapshot in
                let tasksInfo = snapshot.value as? [String : Any ] ?? [:]
                var amounts = Dictionary<String, Int>()
                if tasksInfo["participantAmount"]! as! Int != 0{
                    amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                }
                if tasksInfo["leaderAmount"]! as! Int != 0{
                    amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                }
                
                let updatedTask = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, startTime: tasksInfo["taskTime"]! as! String, endTime: tasksInfo["taskEndTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, endTimeMilliseconds: tasksInfo["taskEndTimeMilliseconds"]! as! TimeInterval, amounts: amounts)
                self.task_in = updatedTask
                self.viewDidLoad()
            })
        }
    }
    
}
