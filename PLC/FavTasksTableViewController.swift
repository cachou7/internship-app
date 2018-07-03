//
//  FavTasksTableViewController.swift
//  PLC
//
//  Created by Chris on 7/3/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

class FavTasksTableViewController: UITableViewController, TaskTableViewCellDelegate {
    
    let user = Auth.auth().currentUser!
    var likedItems: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var newItems: [Task] = []
        
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(DataEventType.value, with: { snapshot in
            let likedTasksDict = snapshot.value as? [String : Any ] ?? [:]
            for task in likedTasksDict {
                Constants.refs.databaseTasks.child(task.key).observe(DataEventType.value, with: { snapshot in
                    let tasksInfo = snapshot.value as? [String : String ] ?? [:]
                    let likedTask = Task(title: tasksInfo["taskTitle"]!, description: tasksInfo["taskDescription"]!, tag: tasksInfo["taskTag"]!, time: tasksInfo["taskTime"]!, location: tasksInfo["taskLocation"]!, timestamp: tasksInfo["timestamp"]!, id: tasksInfo["taskId"]!, createdBy: tasksInfo["createdBy"]!, ranking: tasksInfo["ranking"]!, timeMilliseconds: tasksInfo["timeMilliseconds"]!)
                    newItems.append(likedTask!)
                    self.tableView.reloadData()
                })
            }
            self.likedItems = newItems
            print(self.likedItems)
            self.likedItems.sort(by: {$0.timestamp > $1.timestamp})
            self.tableView.rowHeight = 90.0
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        //let currentTasks = Constants.refs.databaseUsers.child(user.uid + "/tasks_liked")
        cell.taskTitle.text = likedItems[indexPath.row].title
        cell.taskLocation.text = likedItems[indexPath.row].location
        cell.taskTime.text = likedItems[indexPath.row].time
        cell.taskTag.text = likedItems[indexPath.row].tag
        
        let likedIcon = UIImage(named: "redHeart")
        cell.taskLiked.setImage(likedIcon, for: .normal)

        cell.delegate = self
        return cell
    }
    
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        //print("Heart", sender, tappedIndexPath.row)
        
        sender.isSelected = !sender.isSelected
        
        let currentTasks = Constants.refs.databaseUsers.child(user.uid + "/tasks_liked")
        
        // Heart tapped, set image to red heart
        if (sender.isSelected) {
            let likedIcon = UIImage(named: "redHeart")
            sender.taskLiked.setImage(likedIcon, for: .normal)
            sender.contentView.backgroundColor = UIColor.white
            currentTasks.child(likedItems[tappedIndexPath.row].id).setValue(true)
        }
            // Heart untapped, set image to blank heart
        else {
            let unlikedIcon = UIImage(named: "heartIcon")
            sender.taskLiked.setImage(unlikedIcon, for: .normal)
            currentTasks.child(likedItems[tappedIndexPath.row].id).setValue(nil)
        }
    }
    // Set myIndex for detailed view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        self.tableView.reloadData()
        //performSegue(withIdentifier: "detailTask", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
