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
    
    //MARK: Properties
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var funFactLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var backToLeaderboardButton: UIBarButtonItem!

    //The titles of each section
    var sections: [String] = []
    //Dictionary where title sections are the key and an array of tasks corresponding with the section are the values
    var sectionArrays: [String:[Task]] = [:]
    //Array of taskIDs of each lead task
    var leadTasks: [String] = []
    //Array of taskIDs of each participate task
    var participateTasks: [String] = []
    //Array of taskIDs of each create task
    var createTasks: [String] = []
    //Array of taskIDs of each pending task
    var pendingTasks: [String] = []
    var everyItemCreated: [Task] = []
    var user: User?
    var myIndex = 0
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Checks to see if the user is nil and if it is, the profile is being accessed from profile tab and no user is passed in. If it isn't, the profile is being accessed from another view controller and a User object is passed in.
        if user == nil{
            user = currentUser!
            backToLeaderboardButton.tintColor = UIColor.clear
            backToLeaderboardButton.isEnabled = false
        }
        
        //Sets navigation title to the name of the user
        self.navigationItem.title = (user?.firstName)! + " " + (user?.lastName)!
        
        //Configures and sets labels and images in profile
        jobTitleLabel.numberOfLines = 1
        jobTitleLabel.adjustsFontSizeToFitWidth = true
        jobTitleLabel.text = (user?.jobTitle)!
        departmentLabel.numberOfLines = 1
        departmentLabel.adjustsFontSizeToFitWidth = true
        departmentLabel.text = (user?.department)!
        funFactLabel.numberOfLines = 1
        funFactLabel.adjustsFontSizeToFitWidth = true
        funFactLabel.text = (user?.funFact)!
        pointsLabel.text = String((user?.points)!)
        emailLabel.numberOfLines = 1
        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.text = String((user?.email)!)
        
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
        
        //Updates user's points label in realtime
        Constants.refs.databaseUsers.child((user?.uid)!).observe(.childChanged, with: {(snap) in
            if snap.key == "points"{
                self.user?.points = snap.value as! Int
                self.pointsLabel.text = String((self.user?.points)!)
            }
        })
        
        
        //Loads all tasks held in database and stores as everyItemCreated
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
                self.everyItemCreated = newOverallItems
                
                self.sortTasks()
            }})
        
        //Waits for all tasks to be stored in everyItemCreated
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        
            //
            Constants.refs.databaseUsers.child((self.user?.uid)!).child("tasks_lead").observe(.childAdded, with: { snapshot in
                if (snapshot.exists()){
                    let task = self.everyItemCreated[self.everyItemCreated.index(where: {$0.id == snapshot.key})!]
                    if self.sectionArrays["Lead"] != nil && !self.leadTasks.contains(task.id){
                        (self.sectionArrays["Lead"]!).append(task)
                        self.leadTasks.append(task.id)
                    }
                    else{
                        self.sections.append("Lead")
                        self.sectionArrays["Lead"] = [task]
                        self.leadTasks.append(task.id)
                    }
                    self.sortTasks()
                }
        })
            Constants.refs.databaseUsers.child((self.user?.uid)!).child("tasks_lead").observe(.childRemoved, with: { snapshot in
            if (snapshot.exists()){
                var newArr = self.sections
                for section in self.sections {
                    for i in 0..<self.sectionArrays[section]!.count {
                        if self.sectionArrays[section]![i].id == snapshot.key {
                            self.leadTasks.remove(at: self.leadTasks.index(of: snapshot.key)!)
                            if self.sectionArrays[section]!.count == 1 {
                                newArr = self.sections.filter( {$0 != section })
                                self.sectionArrays.removeValue(forKey: section)
                                break
                            }
                            else {
                                self.sectionArrays[section]!.remove(at: i)
                                break
                            }
                        }
                    }
                }
                self.sections = newArr
                self.tableView.reloadData()
            }
        })
            Constants.refs.databaseUsers.child((self.user?.uid)!).child("tasks_created").observe(.childAdded, with: { snapshot in
            if (snapshot.exists()){
                let task = self.everyItemCreated[self.everyItemCreated.index(where: {$0.id == snapshot.key})!]
                if self.sectionArrays["Created"] != nil && !self.createTasks.contains(task.id){
                    (self.sectionArrays["Created"]!).append(task)
                    self.createTasks.append(task.id)
                }
                else{
                    self.sections.append("Created")
                    self.sectionArrays["Created"] = [task]
                    self.createTasks.append(task.id)
                }
                self.sortTasks()
            }
        })
            Constants.refs.databaseUsers.child((self.user?.uid)!).child("tasks_created").observe(.childRemoved, with: { snapshot in
                if (snapshot.exists()){
                    var newArr = self.sections
                    for section in self.sections {
                        for i in 0..<self.sectionArrays[section]!.count {
                            if self.sectionArrays[section]![i].id == snapshot.key {
                                self.createTasks.remove(at: self.createTasks.index(of: snapshot.key)!)
                                if self.sectionArrays[section]!.count == 1 {
                                    newArr = self.sections.filter( {$0 != section })
                                    self.sectionArrays.removeValue(forKey: section)
                                    break
                                }
                                else {
                                    self.sectionArrays[section]!.remove(at: i)
                                    break
                                }
                            }
                        }
                    }
                    self.sections = newArr
                    self.tableView.reloadData()
                }
            })
        
            if self.user!.uid == currentUser.uid{
            Constants.refs.databaseUsers.child((self.user?.uid)!).child("tasks_participated").observe(.childAdded, with: { snapshot in
                if (snapshot.exists()){
                    let task = self.everyItemCreated[self.everyItemCreated.index(where: {$0.id == snapshot.key})!]
                    if self.sectionArrays["Participated"] != nil && !self.participateTasks.contains(task.id){
                        (self.sectionArrays["Participated"]!).append(task)
                        self.participateTasks.append(task.id)
                    }
                    else{
                        self.sections.append("Participated")
                        self.sectionArrays["Participated"] = [task]
                        self.participateTasks.append(task.id)
                    }
                    self.sortTasks()
                }
            })
                Constants.refs.databaseUsers.child((self.user?.uid)!).child("tasks_participated").observe(.childRemoved, with: { snapshot in
                    if (snapshot.exists()){
                        var newArr = self.sections
                        for section in self.sections {
                            for i in 0..<self.sectionArrays[section]!.count {
                                if self.sectionArrays[section]![i].id == snapshot.key {
                                    self.participateTasks.remove(at: self.participateTasks.index(of: snapshot.key)!)
                                    if self.sectionArrays[section]!.count == 1 {
                                        newArr = self.sections.filter( {$0 != section })
                                        self.sectionArrays.removeValue(forKey: section)
                                        break
                                    }
                                    else {
                                        self.sectionArrays[section]!.remove(at: i)
                                        break
                                    }
                                }
                            }
                        }
                        self.sections = newArr
                        self.tableView.reloadData()
                    }
                })
                
                Constants.refs.databaseUsers.child((self.user?.uid)!).child("tasks_pending").observe(.childAdded, with: { snapshot in
                    if (snapshot.exists()){
                        let task = self.everyItemCreated[self.everyItemCreated.index(where: {$0.id == snapshot.key})!]
                        if self.sectionArrays["Pending"] != nil && !self.pendingTasks.contains((task.id)){
                            (self.sectionArrays["Pending"]!).append(task)
                            self.pendingTasks.append(task.id)
                        }
                        else{
                            self.sections.append("Pending")
                            self.sectionArrays["Pending"] = ([task])
                            self.pendingTasks.append(task.id)
                        }
                        self.sortTasks()
                    }
                })
                Constants.refs.databaseUsers.child((self.user?.uid)!).child("tasks_pending").observe(.childRemoved, with: { snapshot in
                    if (snapshot.exists()){
                        var newArr = self.sections
                        for section in self.sections {
                            for i in 0..<self.sectionArrays[section]!.count {
                                if self.sectionArrays[section]![i].id == snapshot.key {
                                    self.pendingTasks.remove(at: self.pendingTasks.index(of: snapshot.key)!)
                                    if self.sectionArrays[section]!.count == 1 {
                                        newArr = self.sections.filter( {$0 != section })
                                        self.sectionArrays.removeValue(forKey: section)
                                        break
                                    }
                                    else {
                                        self.sectionArrays[section]!.remove(at: i)
                                        break
                                    }
                                }
                            }
                        }
                        self.sections = newArr
                        self.tableView.reloadData()
                    }
                })
        }
        }

        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
            try! Auth.auth().signOut()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        //Loads number of sections. If section count is 0, tableview displays "No eggs available"
        var numOfSections: Int = 0
        if self.sections.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections = self.sections.count
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No eggs available"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.sectionArrays[sections[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        var thisTask: Task!
        
        //Checks each section until it finds the corresponding task and stores the task in thisTask
        for i in 0..<self.sectionArrays.count{
            if (indexPath.section == i) {
                thisTask = (sectionArrays[sections[i]]?[indexPath.row])!
            }
        }
        
        //Configures cell
        cell.taskTitle.numberOfLines = 1
        cell.taskTitle.adjustsFontSizeToFitWidth = true
        cell.taskTitle.text = thisTask!.title
        var startTime = thisTask.startTime.split(separator: " ")
        let checkdate = NSDate(timeIntervalSince1970: thisTask.timeMilliseconds)
        let dateString = self.dateFormatter.string(from: checkdate as Date)
        let dayOfWeek = getDayOfWeek(dateString)
        var taskTimeInfo = ""
        taskTimeInfo = dayOfWeek! + ", " + String(startTime[0])
        taskTimeInfo += " " + String(startTime[1]).dropLast() + " at "
        taskTimeInfo += String(startTime[4]) + " " + String(startTime[5])
        cell.taskTime.numberOfLines = 1
        cell.taskTime.adjustsFontSizeToFitWidth = true
        cell.taskTime.text = String(taskTimeInfo)
        cell.taskCategory.setTitle(thisTask!.category, for: .normal)
        cell.taskImage.contentMode = UIViewContentMode.scaleAspectFill
        cell.taskImage.clipsToBounds = true
        cell.taskImage.layer.cornerRadius = cell.taskImage.frame.size.width/2
        
        let storageRef = Constants.refs.storage.child("taskPhotos/\(thisTask.id).png")
        // Load the image using SDWebImage
        SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
        cell.taskImage.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
            if error != nil {
                cell.taskImage.image = #imageLiteral(resourceName: "psheader")
            }
        }

        //TaskTableViewCellDelegate
        cell.delegate = self
        
        return cell
    }
    
    //MARK: TaskTableViewCellDelegate
    func taskTableViewCellCategoryButtonClicked(_ sender: TaskTableViewCell){
        let storyboard = UIStoryboard(name: "Initiatives", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailSearchNavigationController") as! UINavigationController
        
        //Set's the navigation color scheme to the previous view controller's navigation bar color
        if backToLeaderboardButton.isEnabled{
            vc.navigationBar.barTintColor = UIColor(red: 189.0/255.0, green: 229.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        }
        else{
            vc.navigationBar.barTintColor = UIColor(red: 222.0/255.0, green: 237.0/255.0, blue: 125.0/255.0, alpha: 1.0)
        }
        
        //Root View Controller of the Navigation Conroller
        let childVC = vc.viewControllers[0] as! DetailSearchTableViewController
        childVC.navigationItem.title = sender.taskCategory.title(for: .normal)
        childVC.overallItems = self.everyItemCreated
        
        self.present(vc, animated: true, completion: nil)
    }
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        return
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set myIndex for detailed view
        myIndex = indexPath.row
    }
    
    //MARK: Segue Functions
    @IBAction func unwindToProfile(segue:UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailTask", let destinationVC = segue.destination as? DetailTaskViewController, let myIndex = tableView.indexPathForSelectedRow?.row {
            for i in 0..<self.sectionArrays.count{
                if (tableView.indexPathForSelectedRow?.section == i) {
                    destinationVC.task_in = self.sectionArrays[sections[i]]?[myIndex]
                }
            }
            destinationVC.taskIndex = myIndex
            //This is for the unwind segue after a detail task is deleted
            destinationVC.segueFromController = "ProfileViewController"
        }
        else if segue.identifier == "toTutorial",
        
        //Sets the segueFromController variable for the TutorialPageViewController so it can be passed to the LeaderboardTutorialViewController
        //This is so when the tutorial is done and the 'Done' button is hit, it unwinds to the parent view
        let destinationVC = segue.destination as? TutorialPageViewController{
            destinationVC.segueFromController = "ProfileViewController"
        }

    }
    
    //MARK: Helper Functions
    //Sort tasks by created timestamp
    private func sortTasks() -> Void {
        if sectionArrays["Created"] != nil{
            self.sectionArrays["Created"]!.sort(by: {$0.timeMilliseconds > $1.timeMilliseconds})
        }
        if sectionArrays["Lead"] != nil{
            self.sectionArrays["Lead"]!.sort(by: {$0.timeMilliseconds > $1.timeMilliseconds})
        }
        self.tableView.reloadData()
    }
    
    
    private func getDayOfWeek(_ today:String) -> String? {
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        
        switch weekDay {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return "Yikes"
        }
    }

    
    
}
