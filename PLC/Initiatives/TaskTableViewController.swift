//
//  InitiativesViewController.swift
//  PLC
//
//  Created by Chris on 6/25/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase
import Presentr
import SDWebImage


class TaskTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, TaskTableViewCellDelegate {
    
    //MARK: Variables
    var searchController: UISearchController!
    var myIndex = 0
    var currentDB: String = ""
    var overallItems: [Task] = []
    var everyItemCreated: [Task] = []
    var passedTask:Task!
    var initialToolbar: UIView! = nil
    var presenter = Presentr(presentationType: .custom(width: .default, height: .custom(size:600), center: .center))
    var dataIsAvailable = false
    //var currentView: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.roundCorners = true
        presenter.cornerRadius = 20
        presenter.dismissOnTap = false
        
        initialToolbar = tableView.tableHeaderView
        
        //Tasks Loaded From DB
        Constants.refs.databaseTasks.observe(.value, with: { snapshot in
        var newOverallItems: [Task] = []
            
        for child in snapshot.children {
            if let snapshot = child as? DataSnapshot{
                let tasksInfo = snapshot.value as? [String : Any ] ?? [:]
                var amounts = Dictionary<String, Int>()
                if tasksInfo["participantAmount"]! as! Int != 0{
                    amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                }
                if tasksInfo["leaderAmount"]! as! Int != 0{
                    amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                }
                let task = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, startTime: tasksInfo["taskTime"]! as! String, endTime: tasksInfo["taskEndTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, endTimeMilliseconds: tasksInfo["taskEndTimeMilliseconds"]! as! TimeInterval, amounts: amounts, usersLikedAmount: tasksInfo["usersLikedAmount"]! as! Int, category: tasksInfo["category"] as! String)
                
                newOverallItems.append(task!)
            }
            
            self.overallItems = newOverallItems
            
            Constants.refs.databasePastTasks.observe(.value, with: {(snapshot) in
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot{
                        let taskInfo = snap.value as? [String : Any ] ?? [:]
                        var upperBound = 0
                        if self.overallItems.count > 0{
                            upperBound = self.overallItems.count-1
                        }
                        overallLoop: for i in 0...upperBound{
                            if self.overallItems[i].id == taskInfo["taskID"] as! String{
                                self.overallItems.remove(at: i)
                                self.tableView.reloadData()
                                break overallLoop
                            }
                        }
                    }
                }
            })
            
            self.everyItemCreated = newOverallItems
            
            self.sortTasks()
            }})
        
        
        Constants.refs.databasePastTasks.observe(.value, with: {(snapshot) in
            for child in snapshot.children {
                if let snap = child as? DataSnapshot{
                    let taskInfo = snap.value as? [String : Any ] ?? [:]
                    overallLoop: for i in 0..<self.overallItems.count{
                        if self.overallItems[i].id == taskInfo["taskID"] as! String{
                            self.overallItems.remove(at: i)
                            self.tableView.reloadData()
                            break overallLoop
                        }
                    }
                }
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Actions
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    //COMPOSE BUTTON
    @IBAction func composeButton(_ sender: UIBarButtonItem) {
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "InitiativeCreate", bundle: nil).instantiateViewController(withIdentifier: "InitiativeCreateViewController")
        
        customPresentViewController(presenter, viewController: popController, animated: true, completion: nil)
        
        self.tableView.reloadData()
    }
    //END COMPOSE BUTTON
    
    //TABLEVIEW DELEGATES
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if overallItems.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No initiatives available"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.overallItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        let pendingTasks = Constants.refs.databasePendingTasks
        let thisTask: Task! = self.overallItems[indexPath.row]
        
        cell.taskTitle.numberOfLines = 1
        cell.taskTitle.adjustsFontSizeToFitWidth = true
        cell.taskTitle.text = thisTask!.title
        cell.taskNumberOfLikes.text = String(thisTask!.usersLikedAmount)
        var startTime = thisTask.startTime.split(separator: " ")
        let currentTime = Date().timeIntervalSince1970
        let checkdate = NSDate(timeIntervalSince1970: thisTask.timeMilliseconds)
        let dateString = self.dateFormatter.string(from: checkdate as Date)
        let dayOfWeek = getDayOfWeek(dateString)!
        let taskLocation = thisTask!.location
        var taskTimeInfo = ""
        if currentTime > thisTask.timeMilliseconds && currentTime < thisTask.endTimeMilliseconds {
            taskTimeInfo = dayOfWeek + ", " + String(startTime[0]) + " " + String(startTime[1]).dropLast()
            taskTimeInfo += " · Happening Now · " + taskLocation
        }
        else {
            taskTimeInfo = dayOfWeek + ", " + String(startTime[0]) + " " + String(startTime[1]).dropLast()
            taskTimeInfo += " · " + String(startTime[4]) + " "
            taskTimeInfo += String(startTime[5]) + " · " + taskLocation
        }
        cell.taskTime.text = String(taskTimeInfo)
        //Check if user has liked the task and display correct heart
        currentTasks.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.hasChild(thisTask!.id) {
                let unlikedIcon = UIImage(named: "heartIcon")
                cell.taskLiked.setImage(unlikedIcon, for: .normal)
            }
            else {
                let likedIcon = UIImage(named: "redHeart")
                cell.taskLiked.setImage(likedIcon, for: .normal)
            }
        })
        
        let storageRef = Constants.refs.storage.child("taskPhotos/\(thisTask.id).png")
        // Load the image using SDWebImage
        SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
        cell.taskImage.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
            if error != nil {
                cell.taskImage.image = #imageLiteral(resourceName: "psheader")
                cell.taskImage.contentMode = UIViewContentMode.scaleAspectFill
                cell.taskImage.clipsToBounds = true
                //cell.taskImage.layer.cornerRadius = cell.taskImage.frame.size.width/2
            }
            else{
                cell.taskImage.contentMode = UIViewContentMode.scaleAspectFill
                cell.taskImage.clipsToBounds = true
                //cell.taskImage.layer.cornerRadius = cell.taskImage.frame.size.width/2
            }
            
        }
        cell.taskCategory.setTitle(thisTask!.category, for: .normal)
        
        var createdByUser = false
        if thisTask.createdBy == currentUser.uid {
            createdByUser = true
            cell.taskFirstIcon.image = UIImage(named: "iconChicken")
        }
        pendingTasks.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(thisTask.id) {
                if createdByUser {
                    cell.taskFirstIcon.image = UIImage(named: "iconChicken")
                    cell.taskSecondIcon.image = UIImage(named: "iconPending")
                }
                else {
                    cell.taskFirstIcon.image = UIImage(named: "iconPending")
                }
            }
            else {
                cell.taskFirstIcon.image = UIImage(named: "iconChicken")
            }
        })
        
        cell.delegate = self
        return cell
    }
    
    //END TABLEVIEW DELEGATES

    func taskTableViewCellCategoryButtonClicked(_ sender: TaskTableViewCell){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailSearchNavigationController") as! UINavigationController
        let childVC = vc.viewControllers[0] as! DetailSearchTableViewController
        childVC.navigationItem.title = sender.taskCategory.title(for: .normal)
        childVC.overallItems = self.everyItemCreated
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //LIKING TASKS
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        //print("Heart", sender, tappedIndexPath.row)
        sender.isSelected = !sender.isSelected
        
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        
        

        currentTasks.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //HEART TAPPED
            if !(snapshot.hasChild(self.overallItems[tappedIndexPath.row].id)){
                let likedIcon = UIImage(named: "redHeart")
                sender.taskLiked.setImage(likedIcon, for: .normal)
                sender.contentView.backgroundColor = UIColor.white
                currentTasks.child(self.overallItems[tappedIndexPath.row].id).setValue(true)
                Constants.refs.databaseTasks.child(self.overallItems[tappedIndexPath.row].id).child("users_liked").child(currentUser.uid).setValue(true)
                Constants.refs.databaseTasks.child(self.overallItems[tappedIndexPath.row].id).child("ranking").setValue(self.overallItems[tappedIndexPath.row].ranking + 1)
                
                Constants.refs.databaseTasks.child(self.overallItems[tappedIndexPath.row].id).child("usersLikedAmount").setValue(self.overallItems[tappedIndexPath.row].usersLikedAmount + 1)
            }
            //END HEART TAPPED
                
            //HEART UNTAPPED
            else {
                let unlikedIcon = UIImage(named: "heartIcon")
                sender.taskLiked.setImage(unlikedIcon, for: .normal)
                currentTasks.child(self.overallItems[tappedIndexPath.row].id).removeValue()
                Constants.refs.databaseTasks.child(self.overallItems[tappedIndexPath.row].id).child("users_liked").child(currentUser.uid).removeValue()
                Constants.refs.databaseTasks.child(self.overallItems[tappedIndexPath.row].id).child("ranking").setValue(self.overallItems[tappedIndexPath.row].ranking - 1)
                
                    if self.overallItems[tappedIndexPath.row].usersLikedAmount - 1 < 0
                    {
                        Constants.refs.databaseTasks.child(self.overallItems[tappedIndexPath.row].id).child("usersLikedAmount").setValue(0)
                }
                    else{
                        Constants.refs.databaseTasks.child(self.overallItems[tappedIndexPath.row].id).child("usersLikedAmount").setValue(self.overallItems[tappedIndexPath.row].usersLikedAmount - 1)
                }
             }
            //END HEART UNTAPPED
        })

    }
    //END LIKING TASKS

    // Set myIndex for detailed view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailTask", let destinationVC = segue.destination as? DetailTaskViewController, let myIndex = tableView.indexPathForSelectedRow?.row {
            
            destinationVC.task_in = self.overallItems[myIndex]
            destinationVC.taskIndex = myIndex
            destinationVC.segueFromController = "TaskTableViewController"
        }
        if segue.identifier == "toSearch",
            let destinationVC = segue.destination as? SearchViewController{
            destinationVC.overallItems = self.everyItemCreated
        }
    }
    
    // Sorts tasks based on which tab bar and menu dropdown bar is selected, then reload view
    func sortTasks() -> Void {
        //OVERALL
            self.overallItems.sort(by: {$0.timestamp > $1.timestamp})
            /*}
            else if currentView == "MostPopular"{
                self.overallItems.sort(by: {$0.ranking > $1.ranking})
            }
            else{
                self.overallItems.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
            }
 */
        //END OVERALL
        self.tableView.reloadData()
    }
    
    @IBAction func unwindToInitiatives(segue:UIStoryboardSegue) {
        if segue.identifier == "unwindToInitiatives" {
            let selectedIndex = tableView.indexPathForSelectedRow?.row
            let itemRemoved = self.overallItems[selectedIndex!]
            self.overallItems.remove(at: selectedIndex!)
            let index = self.everyItemCreated.index(where: {$0.id == itemRemoved.id})
            everyItemCreated.remove(at: index!)
            tableView.deleteRows(at: tableView.indexPathsForSelectedRows!, with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    private func getDayOfWeek(_ today:String) -> String? {
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        
        switch weekDay {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        case 7:
            return "Sat"
        default:
            return "Yikes"
        }
    }
}

