//
//  DetailTaskViewController.swift
//  PLC
//
//  Created by Chris on 6/28/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class DetailTaskViewController: UIViewController {
    
    var task_in:Task!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var taskTime: UILabel!
    @IBOutlet weak var taskDescription: UILabel!
    //var titleViaSegue:String?
    @IBOutlet weak var participateLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var leadLabel: UILabel!
    @IBOutlet weak var createLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        taskTitle.text = task_in.title
        taskLocation.text = task_in.location
        taskTime.text = task_in.time
        taskDescription.text = task_in.description
        
        if task_in.createdBy == currentUser.uid{
            editButton.isEnabled = true
        }
        else{
            editButton.isEnabled = false
        }
        
        let tags = task_in.tag
        let tagArray = tags.components(separatedBy: " ")
        for tag in tagArray{
            if tag == "#lead"{
                leadLabel.isEnabled = true
                leadLabel.textColor = UIColor.blue
            }
            if tag == "#participate"{
                participateLabel.isEnabled = true
                participateLabel.textColor = UIColor.blue
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask", let destinationVC = segue.destination as? EditInitiativeViewController, let task_out = task_in {
            destinationVC.task_in = task_out
        }
    }
    
    @IBAction func unwindToDetail(segue:UIStoryboardSegue) {
        if segue.source is EditInitiativeViewController{
            Constants.refs.databaseTasks.child(task_in.id).observeSingleEvent(of: .value, with: { snapshot in
                let tasksInfo = snapshot.value as? [String : String ] ?? [:]
                var amounts = Dictionary<String, Int>()
                if tasksInfo["participantAmount"]! != "0"{
                    amounts["participants"] = Int(tasksInfo["participantAmount"]!)
                }
                if tasksInfo["leaderAmount"]! != "0"{
                    amounts["leaders"] = Int(tasksInfo["leaderAmount"]!)
                }
                let updatedTask = Task(title: tasksInfo["taskTitle"]!, description: tasksInfo["taskDescription"]!, tag: tasksInfo["taskTag"]!, time: tasksInfo["taskTime"]!, location: tasksInfo["taskLocation"]!, timestamp: tasksInfo["timestamp"]!, id: tasksInfo["taskId"]!, createdBy: tasksInfo["createdBy"]!, ranking: tasksInfo["ranking"]!, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]!, type: tasksInfo["taskType"]!, amounts: amounts)
                self.task_in = updatedTask
                self.viewDidLoad()
            })
        }
    }
    
}
