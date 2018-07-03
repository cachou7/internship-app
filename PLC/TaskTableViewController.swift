//
//  InitiativesViewController.swift
//  PLC
//
//  Created by Chris on 6/25/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

var myIndex = 0
var items: [Task] = []

class TaskTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, TaskTableViewCellDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        Constants.refs.databaseTasks.observe(.value, with: { snapshot in
        var newItems: [Task] = []
        var createdBy: String
        for child in snapshot.children {
            if let snapshot = child as? DataSnapshot{
                if ((snapshot.childSnapshot(forPath: "createdBy").value as? String) != nil){
                    createdBy = snapshot.childSnapshot(forPath: "createdBy").value as! String
                }
                else {
                    createdBy = "DefaultUser"
                }
                let task = Task(title: snapshot.childSnapshot(forPath: "taskTitle").value! as! String, description: snapshot.childSnapshot(forPath: "taskDescription").value! as! String, tag: snapshot.childSnapshot(forPath: "taskTag").value! as! String, time: snapshot.childSnapshot(forPath: "taskTime").value! as! String, location: snapshot.childSnapshot(forPath: "taskLocation").value! as! String, timestamp: snapshot.childSnapshot(forPath: "timestamp").value! as! String, id: snapshot.childSnapshot(forPath: "taskId").value! as! String, createdBy: createdBy)
                newItems.append(task!)
            }
            
            items = newItems
            items.sort(by: {$0.timestamp > $1.timestamp})
            self.tableView.reloadData()
            }})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        cell.taskTitle.text = items[indexPath.row].title
        cell.taskLocation.text = items[indexPath.row].location
        cell.taskTime.text = items[indexPath.row].time
        cell.taskTag.text = items[indexPath.row].tag
        
        //Check if user has liked the task and display correct heart
        currentTasks.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(items[indexPath.row].id) {
                let likedIcon = UIImage(named: "redHeart")
                cell.taskLiked.setImage(likedIcon, for: .normal)
            }
        })
        cell.delegate = self
        return cell
    }
    
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        //print("Heart", sender, tappedIndexPath.row)
        
        sender.isSelected = !sender.isSelected
         
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        
        // Heart tapped, set image to red heart
        if (sender.isSelected) {
            let likedIcon = UIImage(named: "redHeart")
            sender.taskLiked.setImage(likedIcon, for: .normal)
            sender.contentView.backgroundColor = UIColor.white
            currentTasks.child(items[tappedIndexPath.row].id).setValue(true)
        }
        // Heart untapped, set image to blank heart
        else {
            let unlikedIcon = UIImage(named: "heartIcon")
            sender.taskLiked.setImage(unlikedIcon, for: .normal)
            currentTasks.child(items[tappedIndexPath.row].id).setValue(nil)
         }
    }
    // Set myIndex for detailed view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        self.tableView.reloadData()
        //performSegue(withIdentifier: "detailTask", sender: self)
    }
    
    @IBAction func composeButton(_ sender: UIBarButtonItem) {
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "InitiativeCreate", bundle: nil).instantiateViewController(withIdentifier: "InitiativeCreateViewController")
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self as UIPopoverPresentationControllerDelegate

        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
    
    // UIPopoverPresentationControllerDelegate method
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Force popover style
        return UIModalPresentationStyle.popover
    }
        
}

