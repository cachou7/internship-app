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
    var overallItems: [Task]?
    var filteredItems: [Task] = []
    var myIndex = 0
    var currentDB: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSearchResults()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
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
    
    //TABLEVIEW DELEGATES
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var isLead = false
        var isParticipant = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        var thisTask: Task!
        
        thisTask = self.filteredItems[indexPath.row]
        
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
        
        if thisTask!.category == "Fun & Games" {
            if isLead{
                cell.taskLeaderPoints.text = "+" + String(getLeaderPoints(thisTask: thisTask)) + " pts"
            }
            if isParticipant{
                cell.taskParticipantPoints.text = "+" + String(getParticipantPoints(thisTask: thisTask)) + " pts"
            }
        }
        else if thisTask!.category == "Philanthropy" {
            if isLead{
                cell.taskLeaderPoints.text = "+" + String(getLeaderPoints(thisTask: thisTask) * 7 / 4) + " pts"
            }
            if isParticipant{
                cell.taskParticipantPoints.text = "+" + String(getParticipantPoints(thisTask: thisTask) * 7 / 4) + " pts"
            }
        }
        else if thisTask!.category == "Shared Interests" {
            if isLead{
                cell.taskLeaderPoints.text = "+" + String(getLeaderPoints(thisTask: thisTask) * 3 / 2) + " pts"
            }
            if isParticipant{
                cell.taskParticipantPoints.text = "+" + String(getParticipantPoints(thisTask: thisTask) * 3 / 2) + " pts"
            }
        }
        else if thisTask!.category == "Skill Building" {
            if isLead{
                cell.taskLeaderPoints.text = "+" + String(getLeaderPoints(thisTask: thisTask) * 2) + " pts"
            }
            if isParticipant{
                cell.taskParticipantPoints.text = "+" + String(getParticipantPoints(thisTask: thisTask) * 2) + " pts"
            }
        }
        else {
            if isLead{
                cell.taskLeaderPoints.text = "+" + String(getLeaderPoints(thisTask: thisTask) * 5 / 4) + " pts"
            }
            if isParticipant{
                cell.taskParticipantPoints.text = "+" + String(getParticipantPoints(thisTask: thisTask) * 5 / 4) + " pts"
            }
        }
        
        cell.delegate = self
        return cell
    }
    //END TABLEVIEW DELEGATES
    
    func taskTableViewCellCategoryButtonClicked(_ sender: TaskTableViewCell){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailSearchNavigationController") as! UINavigationController
        let childVC = vc.viewControllers[0] as! DetailSearchTableViewController
        childVC.navigationItem.title = sender.taskCategory.title(for: .normal)
        
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
            if !(snapshot.hasChild(self.overallItems![tappedIndexPath.row].id)){
                let likedIcon = UIImage(named: "redHeart")
                sender.taskLiked.setImage(likedIcon, for: .normal)
                sender.contentView.backgroundColor = UIColor.white
                currentTasks.child(self.overallItems![tappedIndexPath.row].id).setValue(true)
                Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("users_liked").child(currentUser.uid).setValue(true)
                Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("ranking").setValue(self.overallItems![tappedIndexPath.row].ranking + 1)
                
                Constants.refs.databaseTasks.child(self.overallItems![tappedIndexPath.row].id).child("usersLikedAmount").setValue(self.overallItems![tappedIndexPath.row].usersLikedAmount + 1)
            }
                //END HEART TAPPED
                
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
            //END HEART UNTAPPED
        })
        
    }
    //END LIKING TASKS
    
    // Set myIndex for detailed view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearch", let destinationVC = segue.destination as? SearchBarViewController{
            destinationVC.overallItems = self.overallItems
        }
        if segue.identifier == "detailTask", let destinationVC = segue.destination as? DetailTaskViewController, let myIndex = tableView.indexPathForSelectedRow?.row {
            
            destinationVC.task_in = self.filteredItems[myIndex]
            destinationVC.taskIndex = myIndex
        }
    }
    
    private func getLeaderPoints(thisTask: Task)-> Int{
        var leaderPts = Int((thisTask.endTimeMilliseconds - thisTask.timeMilliseconds) / 200)
        if leaderPts / 10 < 35 {
            leaderPts = 35
        }
        else {
            leaderPts /= 10
            if leaderPts > 100 {
                leaderPts = 100
            }
        }
        return leaderPts
    }
    
    private func getParticipantPoints(thisTask: Task)-> Int{
        var participantPts = Int((thisTask.endTimeMilliseconds - thisTask.timeMilliseconds) / 1000)
        if participantPts / 10 < 5 {
            participantPts = 5
        }
        else {
            participantPts /= 10
            if participantPts > 20 {
                participantPts = 20
            }
        }
        return participantPts
    }
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
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
