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

class TaskTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, TaskTableViewCellDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    //MARK: Variables
    @IBOutlet weak var segmentedBarOutlet: UISegmentedControl!
    var searchController: UISearchController!
    var myIndex = 0
    var currentDB: String = ""
    var overallItems: [Task] = []
    var filteredItems: [Task] = []
    var passedTask:Task!
    var shouldShowSearchResults = false
    var initialToolbar: UIView! = nil
    var presenter = Presentr(presentationType: .popup)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        presenter.roundCorners = true
        presenter.cornerRadius = 20
        presenter.dismissOnTap = false
        
        initialToolbar = tableView.tableHeaderView
        
        //SEARCH BAR FUNCTION
        self.configureSearchBar()
        
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
            
            self.sortTasks()
            }})
        
        
        Constants.refs.databasePastTasks.observe(.value, with: {(snapshot) in
            for child in snapshot.children {
                if let snap = child as? DataSnapshot{
                    let taskInfo = snap.value as? [String : Any ] ?? [:]
                    //self.overallItems.remove(at: self.overallItems.index(of: taskInfo["taskID"] as! Task))
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
    
    //SEGMENTED BAR
    @IBAction func segmentedBar(_ sender: UISegmentedControl) {
        self.sortTasks()
    }
    //END SEGMENTED BAR
    
    //SEARCH BUTTON
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        if tableView.tableHeaderView != initialToolbar{
            shouldShowSearchResults = false
            tableView.tableHeaderView = initialToolbar
            tableView.reloadData()
        }
        else{
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    //END SEARCH BUTTON
    
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults{
            return filteredItems.count
        }
        else{
            return self.overallItems.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        var thisTask: Task!
        
        if shouldShowSearchResults{
            thisTask = self.filteredItems[indexPath.row]
        }
        else {
            thisTask = self.overallItems[indexPath.row]
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
        
        var leaderPts = Int((thisTask.endTimeMilliseconds - thisTask.timeMilliseconds) / 200)
        var participantPts = Int((thisTask.endTimeMilliseconds - thisTask.timeMilliseconds) / 1000)
        
        if leaderPts / 10 < 35 {
            leaderPts = 35
        }
        else {
            leaderPts /= 10
            if leaderPts > 100 {
                leaderPts = 100
            }
        }
        if participantPts / 10 < 5 {
            participantPts = 5
        }
        else {
            participantPts /= 10
            if participantPts > 20 {
                participantPts = 20
            }
        }
        
        if thisTask!.category == "Fun and Games" {
            cell.taskLeaderPoints.text = "+" + String(leaderPts) + " pts"
            cell.taskParticipantPoints.text = "+" + String(participantPts) + " pts"
            cell.taskCategoryIcon.image = UIImage(named: "iconParty")
            cell.taskCategory.text = "Fun & Games"
        }
        else if thisTask!.category == "Philanthropy" {
            cell.taskLeaderPoints.text = "+" + String(leaderPts * 7 / 4) + " pts"
            cell.taskParticipantPoints.text = "+" + String(participantPts * 7 / 4) + " pts"
            cell.taskCategoryIcon.image = UIImage(named: "iconCharity")
            cell.taskCategory.text = "Philanthropy"
        }
        else if thisTask!.category == "Shared Interests" {
            cell.taskLeaderPoints.text = "+" + String(leaderPts * 3 / 2) + " pts"
            cell.taskParticipantPoints.text = "+" + String(participantPts * 3 / 2) + " pts"
            cell.taskCategoryIcon.image = UIImage(named: "iconGroup")
            cell.taskCategory.text = "Shared Interests"
        }
        else if thisTask!.category == "Skill Building" {
            cell.taskLeaderPoints.text = "+" + String(leaderPts * 2) + " pts"
            cell.taskParticipantPoints.text = "+" + String(participantPts * 2) + " pts"
            cell.taskCategoryIcon.image = UIImage(named: "iconSkill")
            cell.taskCategory.text = "Skill Building"
        }
        else {
            cell.taskLeaderPoints.text = "+" + String(leaderPts * 5 / 4) + " pts"
            cell.taskParticipantPoints.text = "+" + String(participantPts * 5 / 4) + " pts"
            cell.taskCategoryIcon.image = UIImage(named: "iconStar")
            cell.taskCategory.text = "Other"
        }
        
        cell.delegate = self
        return cell
    }
    //END TABLEVIEW DELEGATES

    
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
                Constants.refs.databaseTasks.child(self.overallItems[tappedIndexPath.row].id).child("usersLikedAmount").setValue(self.overallItems[tappedIndexPath.row].usersLikedAmount - 1)
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
            
            if shouldShowSearchResults{
                destinationVC.task_in = self.filteredItems[myIndex]
            }
            else {
                destinationVC.task_in = self.overallItems[myIndex]
            }
            destinationVC.taskIndex = myIndex
        }
    }
    
    
    //SEARCH FUNCTION
    func configureSearchBar(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.tableHeaderView = initialToolbar
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredItems = overallItems.filter({ (task) -> Bool in
            let taskTitle: NSString = task.title as NSString
            let taskTag: NSString = task.tag as NSString
            let taskDescription: NSString = task.description as NSString
            
            
            return ((taskTitle.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound || (taskTag.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound || (taskDescription.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound)
        })
        
        // Reload the tableview.
        self.tableView.reloadData()
    }
    
    //END SEARCH FUNCTION
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    // Sorts tasks based on which tab bar and menu dropdown bar is selected, then reload view
    func sortTasks() -> Void {
        //OVERALL
            if self.segmentedBarOutlet.selectedSegmentIndex == 0{
                self.overallItems.sort(by: {$0.timestamp > $1.timestamp})
            }
            else if self.segmentedBarOutlet.selectedSegmentIndex == 1{
                self.overallItems.sort(by: {$0.ranking > $1.ranking})
            }
            else{
                self.overallItems.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
            }
        //END OVERALL
        self.tableView.reloadData()
    }
    
    @IBAction func unwindToInitiatives(segue:UIStoryboardSegue) {
        if segue.identifier == "unwindToInitiatives" {
            let selectedIndex = tableView.indexPathForSelectedRow?.row
            self.overallItems.remove(at: selectedIndex!)

            tableView.deleteRows(at: tableView.indexPathsForSelectedRows!, with: .automatic)
            self.tableView.reloadData()
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

