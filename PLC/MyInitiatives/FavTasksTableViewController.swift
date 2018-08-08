//
//  FavTasksTableViewController.swift
//  PLC
//
//  Created by Chris on 7/3/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//
import UIKit
import Firebase

class FavTasksTableViewController: UITableViewController, FavTaskTableViewCellDelegate {
    
    // MM-dd-yyy formatter
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    // yyyy-MM-dd formatter
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // Initialize current user
    let user = Auth.auth().currentUser!
    // Stores key: Date and value: [Task] an array of tasks scheduled for that date
    var dateInfo: [String:[Task]] = [:]
    // Stores a list of all dates that have an event
    var datesList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up listener to get liked tasks and detect when tasks are liked
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childAdded, with: { taskId in
            // Get info for each task
            Constants.refs.databaseTasks.child(taskId.key).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists(){
                    let tasksInfo = snapshot.value as? [String : Any ] ?? [:]
                    var amounts = Dictionary<String, Int>()
                    if tasksInfo["participantAmount"]! as! Int != 0 {
                        amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                    }
                    if tasksInfo["leaderAmount"]! as! Int != 0{
                        amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                    }
                    
                    // Initialize task with info
                    let likedTask = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, startTime: tasksInfo["taskTime"]! as! String, endTime: tasksInfo["taskEndTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, endTimeMilliseconds: tasksInfo["taskEndTimeMilliseconds"]! as! TimeInterval, amounts: amounts, usersLikedAmount: tasksInfo["usersLikedAmount"]! as! Int, category: tasksInfo["category"] as! String)
                    
                    self.tableView.rowHeight = 90.0
                    
                    // Sort tasks by individual dates
                    let date = NSDate(timeIntervalSince1970: tasksInfo["taskTimeMilliseconds"] as! TimeInterval)
                    let dateString = self.dateFormatter.string(from: date as Date)
                    let keyExists = self.dateInfo[dateString] != nil
                    // If date is not in dictionary, then add key:date and value:Task to dict
                    if !keyExists {
                        self.dateInfo[dateString] = ([likedTask] as! [Task])
                    }
                    // If date exists, then append task to end of tasks list for that date
                    else {
                        var currTasks = self.dateInfo[dateString] as! [Task]
                        currTasks.append(likedTask!)
                        currTasks.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
                        self.dateInfo[dateString] = currTasks
                    }
                    
                    // If date does not exist in list of dates with events, then add it
                    for key in self.dateInfo.keys {
                        if !self.datesList.contains(key) {
                            self.datesList.append(key)
                        }
                    }
                    
                    self.datesList = self.datesList.sorted(by: { $0.compare($1) == .orderedAscending })
                    self.tableView.reloadData()
                }
            })
            
            self.tableView.reloadData()
        })
        
        // Set up listener to detect when tasks are unliked from main Initiatives view and delete from dateInfo
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childRemoved, with: { taskId in
            var newArr = self.datesList
            for date in self.datesList {
                for i in 0..<self.dateInfo[date]!.count {
                    if self.dateInfo[date]![i].id == taskId.key {
                        if self.dateInfo[date]!.count == 1 {
                            newArr = self.datesList.filter( {$0 != date })
                            self.dateInfo.removeValue(forKey: date)
                            break
                        }
                        else {
                            self.dateInfo[date]!.remove(at: i)
                            break
                        }
                    }
                }
            }
            self.datesList = newArr
            self.tableView.reloadData()
        })
        
        // Set up async scroll to user selected date
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            Constants.refs.databaseUserSelectedDate.child(self.user.uid).observe(.value, with : { snapshot in
                if snapshot.exists() {
                    let selectedDate = snapshot.value as! String
                    
                    var row = 0
                    var index = 0
                    var found = false
                    
                    // Scroll to event on selected date if found
                    // Else, scroll to event on closest date after selected date
                    // Else, scroll to event on closest date before selected date
                    if self.datesList.count != 0 {
                        for i in 0..<self.datesList.count {
                            if self.datesList[i] == selectedDate && !found {
                                index = i
                                found = true
                                for j in 0..<self.dateInfo[self.datesList[i]]!.count {
                                    let currentTime = Date().timeIntervalSince1970
                                    if (self.dateInfo[self.datesList[i]]![j].endTimeMilliseconds > currentTime) {
                                        row = j
                                        break
                                    }
                                }
                                break
                            }
                            else if !found {
                                if self.datesList[i] > selectedDate {
                                    index = i
                                    break
                                }
                                else {
                                    index = i
                                }
                            }
                        }
                        let indexPath = IndexPath(row: row, section: index)
                        
                        // Async scroll to date
                        let deadlineTime = DispatchTime.now() + .milliseconds(300)
                        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Return number of different event dates
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if datesList.count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections = datesList.count
            tableView.backgroundView = nil
        }
        // Currently no favorite tasks
        else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No favorites"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }
    
    // Return day of week, month, and day of each favorited event
    // If date is today, then return today
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        var date = ""
        let todaysDate = Date()
        let today = dateFormatter.string(from: todaysDate)
        
        date = self.dateInfo[datesList[section]]![0].startTime
        let checkdate = NSDate(timeIntervalSince1970: self.dateInfo[datesList[section]]![0].timeMilliseconds)
        let dateString = self.dateFormatter.string(from: checkdate as Date)
        
        let dayOfWeek = getDayOfWeek(dateString)
        
        if (dateString == today) {
            return "Today"
        }
        
        let monthDay = date.words
        
        return dayOfWeek! + " " + monthDay[0] + " " + monthDay[1]
    }
    
    // Return number of events for the date in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.dateInfo[datesList[section]]!.count
    }
    
    // Populate each cell with task info
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favTaskCell", for: indexPath) as! FavTaskTableViewCell
        let likedIcon = UIImage(named: "redHeart")
        
        for i in 0..<self.datesList.count {
            if (indexPath.section == i) {
                let myTask = self.dateInfo[datesList[i]]![indexPath.row]
                
                // Cell appearance
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 5
                cell.layer.cornerRadius = 20
                
                cell.taskTitle.text = myTask.title
                cell.taskLocation.text = myTask.location
                cell.taskLiked.setImage(likedIcon, for: .normal)
                
                // Get start and end times for event
                var startTime = myTask.startTime.split(separator: " ")
                var endTime = myTask.endTime.split(separator: " ")
                cell.startTime.text = String(startTime[4]) + " " + String(startTime[5])
                cell.endTime.text = String(endTime[4]) + " " + String(endTime[5])
                
                // Get task category and set image
                if myTask.category == "Fun & Games" {
                    cell.taskCategoryIcon.image = UIImage(named: "iconParty")
                    cell.taskCategory.text = "Fun & Games"
                }
                else if myTask.category == "Philanthropy" {
                    cell.taskCategoryIcon.image = UIImage(named: "iconCharity")
                    cell.taskCategory.text = "Philanthropy"
                }
                else if myTask.category == "Shared Interests" {
                    cell.taskCategoryIcon.image = UIImage(named: "iconGroup")
                    cell.taskCategory.text = "Shared Interests"
                }
                else if myTask.category == "Skill Building" {
                    cell.taskCategoryIcon.image = UIImage(named: "iconSkill")
                    cell.taskCategory.text = "Skill Building"
                }
                else {
                    cell.taskCategoryIcon.image = UIImage(named: "iconStar")
                    cell.taskCategory.text = "Other"
                }
                cell.delegate = self
            }
        }
        
        return cell
    }
    
    // Remove task from Favs page if user untaps heart on this page
    func favTaskTableViewCellDidTapHeart(_ sender: FavTaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let currentTasks = Constants.refs.databaseUsers.child(user.uid + "/tasks_liked")
        let unlikedIcon = UIImage(named: "heartIcon")
        sender.taskLiked.setImage(unlikedIcon, for: .normal)
        
        // Update task rankings under task in database
        Constants.refs.databaseTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).child("ranking").setValue(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].ranking - 1)
        
        // Update users_liked amount under task in database
        if (self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].usersLikedAmount - 1) > 0 {
            Constants.refs.databaseTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).child("usersLikedAmount").setValue(0)
        }
        else {
            Constants.refs.databaseTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).child("usersLikedAmount").setValue(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].usersLikedAmount - 1)
        }
        
        // Remove task key from users_liked under task in database
        Constants.refs.databaseTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).child("users_liked").child(user.uid).removeValue()
        currentTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).removeValue()
        
        tableView.reloadData()
    }
    
    // Segue to detail task view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavTaskDetails", let destinationVC = segue.destination as? DetailTaskViewController, let myIndex = tableView.indexPathForSelectedRow {
            destinationVC.task_in = self.dateInfo[datesList[myIndex.section]]![myIndex.row]
            destinationVC.segueFromController = "FavTaskTableViewController"
        }
    }
    
    // Returns day of the week from date
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

    // Delete event from favorites task table
    @IBAction func unwindToFavInitiatives(segue:UIStoryboardSegue) {
        if segue.identifier == "unwindToFavInitiatives" {
            let selectedIndex = tableView.indexPathForSelectedRow?.row
            for i in 0..<self.datesList.count {
                if (tableView.indexPathForSelectedRow?.section == i) {
                    let elementRemoved = self.dateInfo[datesList[i]]!.remove(at: selectedIndex!)
                    print(elementRemoved.id)
                    if dateInfo[datesList[i]]!.count == 0{
                        dateInfo.removeValue(forKey: datesList[i])
                        datesList.remove(at: i)
                    }
                }
            }
            
            self.tableView.reloadData()
        }
    }
 
}

// String splitter helper function
extension String {
    var words: [String] {
        return components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter{!$0.isEmpty}
    }
}
