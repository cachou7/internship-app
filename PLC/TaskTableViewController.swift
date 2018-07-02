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

class TaskTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        Constants.refs.databaseTasks.observe(.value, with: { snapshot in
        var newItems: [Task] = []
        for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
                let task = Task(title: snapshot.childSnapshot(forPath: "taskTitle").value! as! String, description: snapshot.childSnapshot(forPath: "taskDescription").value! as! String, tag: snapshot.childSnapshot(forPath: "taskTag").value! as! String, time: snapshot.childSnapshot(forPath: "taskTime").value! as! String, location: snapshot.childSnapshot(forPath: "taskLocation").value! as! String, timestamp: snapshot.childSnapshot(forPath: "timestamp").value! as! String) {
                    newItems.append(task)
                }
            }
            
            items = newItems
            items.sort(by: {$0.timestamp > $1.timestamp})
            self.tableView.reloadData()
        })
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
        cell.taskTitle.text = items[indexPath.row].title
        cell.taskLocation.text = items[indexPath.row].location
        cell.taskTime.text = items[indexPath.row].time
        let tagArray = items[indexPath.row].tag.components(separatedBy: "#")
        var tagText: String = ""
        for tagWord in tagArray{
            print(tagWord)
            if tagWord != ""{
                tagText.append("#"+tagWord+" ")
            }
        }
        print(tagText)
        cell.taskTag.text = tagText
        
        return cell
    }
    
    // Set myIndex for detailed view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        //performSegue(withIdentifier: "detailTask", sender: self)
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailTask") {
            let vc = segue.destination as! DetailTaskViewController
            vc.taskTitle = "TEST"
        }
    }*/
    
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

