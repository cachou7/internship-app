//
//  DetailSearchTableViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/26/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class DetailSearchTableViewController: UITableViewController, TaskTableViewCellDelegate {
    
    //MARK: Properties
    var overallItems: [Task]?
    var filteredItems: [Task] = []
    var myIndex = 0
    var currentDB: String = ""
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Filter pages
        if self.navigationItem.title! == "Most Popular" || self.navigationItem.title! == "Upcoming" || self.navigationItem.title! == "Fresh"{
            self.navigationItem.title = self.navigationItem.title! + " Eggs"
            filteredItems = overallItems!
            Constants.refs.databasePastTasks.observe(.value, with: {(snapshot) in
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot{
                        let taskInfo = snap.value as? [String : Any ] ?? [:]
                        overallLoop: for i in 0..<self.filteredItems.count{
                            if self.filteredItems[i].id == taskInfo["taskID"] as! String{
                                self.filteredItems.remove(at: i)
                                self.tableView.reloadData()
                                break overallLoop
                            }
                        }
                    }
                }
            })
            sortTasks()
        }
        else{
            updateSearchResults()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        //Loads number of sections. If section count is 0, tableview displays "No eggs available"
        var numOfSections: Int = 0
        if filteredItems.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections = 1
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        var thisTask: Task!
        
        thisTask = self.filteredItems[indexPath.row]
        
        //Configures cell
        cell.taskTitle.numberOfLines = 1
        cell.taskTitle.adjustsFontSizeToFitWidth = true
        cell.taskTitle.text = thisTask!.title
        cell.taskNumberOfLikes.text = String(thisTask!.usersLikedAmount)
        var startTime = thisTask.startTime.split(separator: " ")
        let checkdate = NSDate(timeIntervalSince1970: thisTask.timeMilliseconds)
        let dateString = self.dateFormatter.string(from: checkdate as Date)
        let dayOfWeek = getDayOfWeek(dateString)!
        let taskLocation = thisTask!.location
        var taskTimeInfo = ""
        taskTimeInfo = dayOfWeek + ", " + String(startTime[0]) + " " + String(startTime[1]).dropLast()
        taskTimeInfo += " · " + String(startTime[4]) + " "
        taskTimeInfo += String(startTime[5]) + " · " + taskLocation
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
            }
            else{
                cell.taskImage.contentMode = UIViewContentMode.scaleAspectFill
                cell.taskImage.clipsToBounds = true
            }
            
        }
        cell.taskCategory.setTitle(thisTask!.category, for: .normal)
        
        cell.delegate = self
        return cell
    }
    
    //MARK: TableViewCell Delegates
    func taskTableViewCellCategoryButtonClicked(_ sender: TaskTableViewCell){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailSearchNavigationController") as! UINavigationController
        let childVC = vc.viewControllers[0] as! DetailSearchTableViewController
        childVC.navigationItem.title = sender.taskCategory.title(for: .normal)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //LIKING TASKS
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        sender.isSelected = !sender.isSelected
        
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        
        currentTasks.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //HEART TAPPED
            if !(snapshot.hasChild(self.overallItems![tappedIndexPath.row].id)){
                let likedIcon = UIImage(named: "redHeart")
                sender.taskLiked.setImage(likedIcon, for: .normal)
                sender.contentView.backgroundColor = UIColor.white
                currentTasks.child(self.overallItems![tappedIndexPath.row].id).setValue(true)
                Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("users_liked").child(currentUser.uid).setValue(true)
                Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("ranking").setValue(self.overallItems![tappedIndexPath.row].ranking + 1)
                
                Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("usersLikedAmount").setValue(self.overallItems![tappedIndexPath.row].usersLikedAmount + 1)
            }
            //HEART UNTAPPED
            else {
                let unlikedIcon = UIImage(named: "heartIcon")
                sender.taskLiked.setImage(unlikedIcon, for: .normal)
                currentTasks.child(self.overallItems![tappedIndexPath.row].id).removeValue()
                Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("users_liked").child(currentUser.uid).removeValue()
                Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("ranking").setValue(self.overallItems![tappedIndexPath.row].ranking - 1)
                if self.overallItems![tappedIndexPath.row].usersLikedAmount - 1 < 0{
                    Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("usersLikedAmount").setValue(0)
                }
                else{
                    Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("usersLikedAmount").setValue(self.overallItems![tappedIndexPath.row].usersLikedAmount - 1)
                }
            }
        })
        
    }
    
    // Set myIndex for detailed view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
    }
    
    //MARK: Segue Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearch", let destinationVC = segue.destination as? SearchBarViewController{
            destinationVC.overallItems = self.overallItems
        }
        if segue.identifier == "detailTask", let destinationVC = segue.destination as? DetailTaskViewController, let myIndex = tableView.indexPathForSelectedRow?.row {
            
            destinationVC.task_in = self.filteredItems[myIndex]
            destinationVC.taskIndex = myIndex
            //This is for the unwind segue after a detail task is deleted
            destinationVC.segueFromController = "DetailSearchTableViewController"
        }
    }
    
    @IBAction func unwindToDetailSearch(segue:UIStoryboardSegue) {
        if segue.identifier == "unwindToDetailSearch" {
            let selectedIndex = tableView.indexPathForSelectedRow?.row
            let itemRemoved = self.filteredItems[selectedIndex!]
            self.filteredItems.remove(at: selectedIndex!)
            self.overallItems!.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
            let index = deleteFromEveryItemCreated(array: overallItems!, left: 0, right: (overallItems?.count)!-1, taskToRemove: itemRemoved)
            overallItems!.remove(at: index)
            tableView.deleteRows(at: tableView.indexPathsForSelectedRows!, with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    //MARK: Helper Functions
    private func updateSearchResults() {
        let searchString = self.navigationItem.title!
        
        // Filter the data array and get only those countries that match the search text.
        filteredItems = (overallItems?.filter({ (task) -> Bool in
            let taskTitle: NSString = task.title as NSString
            let taskTag: NSString = task.tag as NSString
            let taskLocation: NSString = task.location as NSString
            let taskCategory: NSString = task.category as NSString
            
            
            return ((taskTitle.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound || (taskTag.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound || (taskLocation.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound || (taskCategory.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound)
        }))!
        return
    }
    
    func sortTasks() -> Void {
        //Sorts by ranking
        if self.navigationItem.title! == "Most Popular Eggs"{
            self.filteredItems.sort(by: {$0.ranking > $1.ranking})
        }
            //Sorts by start timestamp of event
        else if self.navigationItem.title! == "Upcoming Eggs"{
            self.filteredItems.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
        }
            //Sorts by creation timestamp
        else{
            self.filteredItems.sort(by: {$0.timestamp > $1.timestamp})
        }
        self.tableView.reloadData()
    }
    
    private func deleteFromEveryItemCreated(array: [Task], left: Int, right: Int, taskToRemove: Task)->Int{
        if right >= 1{
            let mid = left + (right - left)/2
            
            // If the element is present at the
            // middle itself
            if array[mid].timeMilliseconds == taskToRemove.timeMilliseconds{
                if array[mid].id == taskToRemove.id{
                    return mid
                }
            }
            
            // If element is smaller than mid, then
            // it can only be present in left subarray
            if array[mid].timeMilliseconds > taskToRemove.timeMilliseconds{
                return deleteFromEveryItemCreated(array: array, left: left, right: mid-1, taskToRemove: taskToRemove)
            }
            
            // Else the element can only be present
            // in right subarray
            return deleteFromEveryItemCreated(array: array, left: mid+1, right: right, taskToRemove: taskToRemove)
        }
        return -1
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
