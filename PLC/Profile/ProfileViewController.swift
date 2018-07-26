//
//  ProfileViewController.swift
//  PLC
//
//  Created by Chris on 6/25/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TaskTableViewCellDelegate {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    @IBOutlet weak var backToLeaderboardButton: UIBarButtonItem!

    var sections: [String] = []
    var sectionArrays: [String:[Task]] = [:]
    var user: User?
    var myIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil{
            user = currentUser!
            backToLeaderboardButton.tintColor = UIColor.clear
            backToLeaderboardButton.isEnabled = false
        }
        
        self.navigationItem.title = (user?.firstName)! + " " + (user?.lastName)!
        jobTitleLabel.text = (user?.jobTitle)!
        departmentLabel.text = (user?.department)!
        pointsLabel.text = String((user?.points)!)
        
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.borderColor = UIColor.black.cgColor
        profilePhoto.clipsToBounds = true
        
        let storageRef = Constants.refs.storage.child("userPhotos/\((user?.uid)!).png")
        // Load the image using SDWebImage
        SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
        profilePhoto.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
            if error != nil {
                self.profilePhoto.image = #imageLiteral(resourceName: "iconProfile")
            }
            
        }
        
        Constants.refs.databaseUsers.child((user?.uid)!).child("tasks_lead").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        Constants.refs.databaseTasks.child(snapshot.key).observe(.value, with: { (snap) in
                            let tasksInfo = snap.value as? [String : Any ] ?? [:]
                            var amounts = Dictionary<String, Int>()
                            if tasksInfo["participantAmount"]! as! Int != 0{
                                amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                            }
                            if tasksInfo["leaderAmount"]! as! Int != 0{
                                amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                            }
                            let task = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, startTime: tasksInfo["taskTime"]! as! String, endTime: tasksInfo["taskEndTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, endTimeMilliseconds: tasksInfo["taskEndTimeMilliseconds"]! as! TimeInterval, amounts: amounts, usersLikedAmount: tasksInfo["usersLikedAmount"]! as! Int, category: tasksInfo["category"] as! String)
                            if self.sectionArrays["Lead"] != nil{
                                (self.sectionArrays["Lead"]!).append(task!)
                            }
                            else{
                                self.sections.append("Lead")
                                self.sectionArrays["Lead"] = [task!]
                            }
                            self.sortTasks()
                        })
                        
                    }
                }
            }
        })
        Constants.refs.databaseUsers.child((user?.uid)!).child("tasks_created").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        print(snapshot.key)
                        Constants.refs.databaseTasks.child(snapshot.key).observe(.value, with: { (snap) in
                            let tasksInfo = snap.value as? [String : Any ] ?? [:]
                            var amounts = Dictionary<String, Int>()
                            if tasksInfo["participantAmount"]! as! Int != 0{
                                amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                            }
                            if tasksInfo["leaderAmount"]! as! Int != 0{
                                amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                            }
                            let task = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, startTime: tasksInfo["taskTime"]! as! String, endTime: tasksInfo["taskEndTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, endTimeMilliseconds: tasksInfo["taskEndTimeMilliseconds"]! as! TimeInterval, amounts: amounts, usersLikedAmount: tasksInfo["usersLikedAmount"]! as! Int, category: tasksInfo["category"] as! String)
                            if self.sectionArrays["Created"] != nil{
                                (self.sectionArrays["Created"]!).append(task!)
                            }
                            else{
                                self.sections.append("Created")
                                self.sectionArrays["Created"] = [task!]
                            }
                            self.sortTasks()
                        })
                    }
                }
            }
        })
        
        if user!.uid == currentUser.uid{
            Constants.refs.databaseUsers.child((user?.uid)!).child("tasks_participated").observe(.value, with: { snapshot in
                if (snapshot.exists()){
                    for child in snapshot.children {
                        if let snapshot = child as? DataSnapshot{
                            Constants.refs.databaseTasks.child(snapshot.key).observe(.value, with: { (snap) in
                                let tasksInfo = snap.value as? [String : Any ] ?? [:]
                                var amounts = Dictionary<String, Int>()
                                if tasksInfo["participantAmount"]! as! Int != 0{
                                    amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                                }
                                if tasksInfo["leaderAmount"]! as! Int != 0{
                                    amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                                }
                                let task = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, startTime: tasksInfo["taskTime"]! as! String, endTime: tasksInfo["taskEndTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, endTimeMilliseconds: tasksInfo["taskEndTimeMilliseconds"]! as! TimeInterval, amounts: amounts, usersLikedAmount: tasksInfo["usersLikedAmount"]! as! Int, category: tasksInfo["category"] as! String)
                                if self.sectionArrays["Participated"] != nil{
                                    (self.sectionArrays["Participated"]!).append(task!)
                                }
                                else{
                                    self.sections.append("Participated")
                                    self.sectionArrays["Participated"] = [task!]
                                }
                                self.sortTasks()
                            })
                            
                        }
                    }
                }
            })
        }

        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("# of sections is "+String(self.sections.count))
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows is "+String((self.sectionArrays[sections[section]]?.count)!))
        return (self.sectionArrays[sections[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("The section is "+sections[section])
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        var thisTask: Task!
        var isLead = false
        var isParticipant = false

        
        for i in 0..<self.sectionArrays.count{
            if (indexPath.section == i) {
                thisTask = (sectionArrays[sections[i]]?[indexPath.row])!
            }
        }
        
        let tags = thisTask.tag
        let tagArray = tags.components(separatedBy: " ")
        for tag in tagArray{
            if tag == "#lead"{
                isLead = true            }
            if tag == "#participate"{
                isParticipant = true
            }
        }
        
        cell.taskTitle.numberOfLines = 1
        cell.taskTitle.adjustsFontSizeToFitWidth = true
        cell.taskTitle.text = thisTask!.title
        cell.taskNumberOfLikes.text = String(thisTask!.usersLikedAmount)
        var startTime = thisTask.startTime.split(separator: " ")
        cell.taskMonth.text = String(startTime[0]).uppercased()
        let taskDay = String(startTime[1]).split(separator: ",")
        cell.taskDay.text = String(taskDay[0])
        let checkdate = NSDate(timeIntervalSince1970: thisTask.timeMilliseconds)
        let dateString = self.dateFormatter.string(from: checkdate as Date)
        let dayOfWeek = getDayOfWeek(dateString)
        cell.taskTime.text = dayOfWeek! + " · " + String(startTime[4]) + " " + String(startTime[5]) + " · " + thisTask!.location
        //Check if user has liked the task and display correct heart
        cell.taskLiked.isEnabled = false
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
                cell.taskImage.image = #imageLiteral(resourceName: "merchMart")
                cell.taskImage.contentMode = UIViewContentMode.scaleAspectFill
                cell.taskImage.clipsToBounds = true
                cell.taskImage.layer.cornerRadius = cell.taskImage.frame.size.width/2
            }
            else{
                cell.taskImage.contentMode = UIViewContentMode.scaleAspectFill
                cell.taskImage.clipsToBounds = true
                cell.taskImage.layer.cornerRadius = cell.taskImage.frame.size.width/2
            }
            
        }
        cell.taskParticipantPoints.text = "+ 0 pts"
        cell.taskLeaderPoints.text = "+ 0 pts"
        
        cell.taskCategory.setTitle(thisTask!.category, for: .normal)
        
        let point = Points.init()
        if isLead{
            cell.taskLeaderPoints.text = "+" + String(point.getPoints(type: "Lead", category: thisTask!.category, thisTask: thisTask)) + " pts"
        }
        if isParticipant{
            cell.taskParticipantPoints.text = "+" + String(point.getPoints(type: "Participant", category: thisTask!.category, thisTask: thisTask)) + " pts"
        }
        cell.delegate = self
        return cell
    }
    
    //TASK TABLE VIEW CELL DELEGATE
    func taskTableViewCellCategoryButtonClicked(_ sender: TaskTableViewCell){
        let storyboard = UIStoryboard(name: "Initiatives", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailSearchNavigationController") as! UINavigationController
        let childVC = vc.viewControllers[0] as! DetailSearchTableViewController
        childVC.navigationItem.title = sender.taskCategory.title(for: .normal)
        
         let taskController = storyboard.instantiateViewController(withIdentifier: "TaskTableViewController") as! TaskTableViewController
        childVC.overallItems = taskController.overallItems
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        return
    }
    //END TASK TABLE VIEW CELL DELEGATE
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    func sortTasks() -> Void {
        if sectionArrays["Created"] != nil{
            self.sectionArrays["Created"]!.sort(by: {$0.timeMilliseconds > $1.timeMilliseconds})
        }
        if sectionArrays["Lead"] != nil{
            self.sectionArrays["Lead"]!.sort(by: {$0.timeMilliseconds > $1.timeMilliseconds})
        }
        self.tableView.reloadData()
    }
    
    @IBAction func unwindToProfile(segue:UIStoryboardSegue) {
        if segue.identifier == "unwindToProfile" {
            let selectedIndex = tableView.indexPathForSelectedRow?.row
            
            for i in 0..<self.sectionArrays.count{
                if (tableView.indexPathForSelectedRow?.section == i) {
                    self.sectionArrays[sections[i]]?.remove(at: selectedIndex!)
                }
            }
            //self.overallItems.remove(at: selectedIndex!)
            
            tableView.deleteRows(at: tableView.indexPathsForSelectedRows!, with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    // Set myIndex for detailed view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailTask", let destinationVC = segue.destination as? DetailTaskViewController, let myIndex = tableView.indexPathForSelectedRow?.row {
            for i in 0..<self.sectionArrays.count{
                if (tableView.indexPathForSelectedRow?.section == i) {
                    destinationVC.task_in = self.sectionArrays[sections[i]]?[myIndex]
                }
            }
            destinationVC.taskIndex = myIndex
        }
    }
    func getDayOfWeek(_ today:String) -> String? {
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
