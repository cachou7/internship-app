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
    
    /*fileprivate let gregorian = Calendar(identifier: .gregorian)
     fileprivate let formatter: DateFormatter = {
     let formatter = DateFormatter()
     formatter.dateFormat = "yyyy-MM-dd"
     return formatter
     }()*/
    
    //fileprivate weak var calendar: FSCalendar!
    let user = Auth.auth().currentUser!
    var likedItems: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up listener to get liked tasks and detect when tasks are liked
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childAdded, with: { taskId in
            print("Fetching fav tasks...")
            // Get specific information for each liked task and add it to LikedItems, then reload data
            Constants.refs.databaseTasks.child(taskId.key).observeSingleEvent(of: .value, with: { snapshot in
                let tasksInfo = snapshot.value as? [String : Any ] ?? [:]
                var amounts = Dictionary<String, Int>()
                if tasksInfo["participantAmount"]! as! Int != 0{
                    amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                }
                if tasksInfo["leaderAmount"]! as! Int != 0{
                    amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                }
                let likedTask = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, time: tasksInfo["taskTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, type: tasksInfo["taskType"]! as! String, amounts: amounts)
                
                self.likedItems.append(likedTask!)
                print("Added task named: " + (tasksInfo["taskTitle"]! as! String))
                self.likedItems.sort(by: {$0.timestamp > $1.timestamp})
                self.tableView.rowHeight = 90.0
                self.tableView.reloadData()
            })
        })
        
        // Set up listener to detect when tasks are unliked from main Initiatives view and delete from likeItems
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childRemoved, with: { taskId in
            print("Deleting item from fav tasks...")
            //if self.likedItems.count > 0 {
            for i in 0..<self.likedItems.count {
                if self.likedItems[i].id == taskId.key {
                    self.likedItems.remove(at: i)
                    break
                }
            }
            //}
            
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
        let likedIcon = UIImage(named: "redHeart")
        
        cell.taskTitle.text = likedItems[indexPath.row].title
        cell.taskLocation.text = likedItems[indexPath.row].location
        cell.taskTime.text = likedItems[indexPath.row].time
        cell.taskTag.text = likedItems[indexPath.row].tag
        cell.taskLiked.setImage(likedIcon, for: .normal)
        cell.delegate = self
        
        return cell
    }
    
    // Remove task from Favs page if user untaps heart on this page
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("Removed task at row " + String(tappedIndexPath.row))
        let currentTasks = Constants.refs.databaseUsers.child(user.uid + "/tasks_liked")
        let unlikedIcon = UIImage(named: "heartIcon")
        sender.taskLiked.setImage(unlikedIcon, for: .normal)
        Constants.refs.databaseTasks.child(self.likedItems[tappedIndexPath.row].id).child("ranking").setValue(self.likedItems[tappedIndexPath.row].ranking - 1)
        
        Constants.refs.databaseTasks.child(self.likedItems[tappedIndexPath.row].id).child("users_liked").child(user.uid).removeValue()
        currentTasks.child(self.likedItems[tappedIndexPath.row].id).removeValue()
        self.likedItems.remove(at: tappedIndexPath.row)
        
        tableView.reloadData()
        //}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavTaskDetails", let destinationVC = segue.destination as? DetailTaskViewController, let myIndex = tableView.indexPathForSelectedRow?.row {
            destinationVC.task_in = self.likedItems[myIndex]
        }
    }
}
