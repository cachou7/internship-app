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
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let user = Auth.auth().currentUser!
    var dateInfo: [String:[Task]] = [:]
    var datesList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up listener to get liked tasks and detect when tasks are liked
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childAdded, with: { taskId in
            print("Fetching fav tasks...")
            print(taskId.key)
            // Get specific information for each liked task and add it to LikedItems, then reload data
            Constants.refs.databaseTasks.child(taskId.key).observe(.value, with: { snapshot in
                let tasksInfo = snapshot.value as? [String : Any ] ?? [:]
                var amounts = Dictionary<String, Int>()
                if tasksInfo["participantAmount"]! as! Int != 0 {
                    amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                }
                if tasksInfo["leaderAmount"]! as! Int != 0{
                    amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                }
                let likedTask = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, startTime: tasksInfo["taskTime"]! as! String, endTime: tasksInfo["taskEndTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, endTimeMilliseconds: tasksInfo["taskEndTimeMilliseconds"]! as! TimeInterval, amounts: amounts, usersLikedAmount: tasksInfo["usersLikedAmount"]! as! Int)
                
                //self.likedItems.append(likedTask!)
                print("Added task named: " + (tasksInfo["taskTitle"]! as! String))
                //self.likedItems.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
                self.tableView.rowHeight = 90.0
                
                let date = NSDate(timeIntervalSince1970: tasksInfo["taskTimeMilliseconds"] as! TimeInterval)
                let dateString = self.dateFormatter.string(from: date as Date)
                let keyExists = self.dateInfo[dateString] != nil
                if !keyExists {
                    self.dateInfo[dateString] = ([likedTask] as! [Task])
                }
                else {
                    var currTasks = self.dateInfo[dateString] as! [Task]
                    currTasks.append(likedTask!)
                    currTasks.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
                    self.dateInfo[dateString] = currTasks
                }
                
                for key in self.dateInfo.keys {
                    if !self.datesList.contains(key) {
                        self.datesList.append(key)
                    }
                }
                
                self.datesList = self.datesList.sorted(by: { $0.compare($1) == .orderedAscending })
                self.tableView.reloadData()
            })
            
            Constants.refs.databaseTasks.child(taskId.key).observe(.childChanged, with: { snapshot in
                let tasksInfo = snapshot.value as? Any
                
                print(tasksInfo)
                
                
            })
            
            self.tableView.reloadData()
        })
        
        // Set up listener to detect when tasks are unliked from main Initiatives view and delete from likeItems
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childRemoved, with: { taskId in
            print("Deleting item from fav tasks...")
            //if self.likedItems.count > 0 {
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
            //}
            self.datesList = newArr
            self.tableView.reloadData()
        })
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            Constants.refs.databaseUserSelectedDate.child(self.user.uid).observe(.value, with : { snapshot in
                if snapshot.exists() {
                    let selectedDate = snapshot.value as! String
                    
                    var row = 0
                    var index = 0
                    var found = false
                    
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
                        
                        /*if !found {
                         if self.datesList.count == 0 {
                         index = 0
                         }
                         else {
                         index = self.datesList.count - 1
                         }
                         }*/
                        
                        let indexPath = IndexPath(row: row, section: index)
                        
                        let deadlineTime = DispatchTime.now() + .milliseconds(300)
                        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                    //self.tableView.reloadData()
                    //self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    //self.tableView.reloadData()
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return datesList.count
    }
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.dateInfo[datesList[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favTaskCell", for: indexPath) as! FavTaskTableViewCell
        let likedIcon = UIImage(named: "redHeart")
        
        for i in 0..<self.datesList.count {
            if (indexPath.section == i) {
                let myTask = self.dateInfo[datesList[i]]![indexPath.row]
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 5
                cell.layer.cornerRadius = 20
                cell.taskTitle.text = myTask.title
                cell.taskLocation.text = myTask.location
                var startTime = myTask.startTime.split(separator: " ")
                var endTime = myTask.endTime.split(separator: " ")
                /*cell.taskTimeFrame.text = String(startTime[4]) + " " + String(startTime[5]) + " - " + String(endTime[4]) + " " + String(endTime[5])
                cell.taskMonth.text = String(startTime[0]).uppercased()
                let taskDay = String(startTime[1]).split(separator: ",")
                cell.taskDay.text = String(taskDay[0])*/
                cell.startTime.text = String(startTime[4]) + " " + String(startTime[5])
                cell.endTime.text = String(endTime[4]) + " " + String(endTime[5])
                cell.taskLiked.setImage(likedIcon, for: .normal)
                cell.delegate = self
            }
        }
        
        return cell
    }
    
    // Remove task from Favs page if user untaps heart on this page
    func favTaskTableViewCellDidTapHeart(_ sender: FavTaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("Removed task at row " + String(tappedIndexPath.row))
        let currentTasks = Constants.refs.databaseUsers.child(user.uid + "/tasks_liked")
        let unlikedIcon = UIImage(named: "heartIcon")
        sender.taskLiked.setImage(unlikedIcon, for: .normal)
        Constants.refs.databaseTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).child("ranking").setValue(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].ranking - 1)
        
        Constants.refs.databaseTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).child("usersLikedAmount").setValue(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].usersLikedAmount - 1)
        
        Constants.refs.databaseTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).child("users_liked").child(user.uid).removeValue()
        currentTasks.child(self.dateInfo[datesList[tappedIndexPath.section]]![tappedIndexPath.row].id).removeValue()
        
        
        //self.likedItems.remove(at: tappedIndexPath.row)
        
        tableView.reloadData()
        //}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavTaskDetails", let destinationVC = segue.destination as? DetailTaskViewController, let myIndex = tableView.indexPathForSelectedRow {
            destinationVC.task_in = self.dateInfo[datesList[myIndex.section]]![myIndex.row]
        }
    }
    
    func getDayOfWeek(_ today:String) -> String? {
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        
        switch weekDay {
        case 0:
            return "Sat"
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
        default:
            return "Yikes"
        }
    }
}

extension String {
    var words: [String] {
        return components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter{!$0.isEmpty}
    }
}
