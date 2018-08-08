//
//  DetailTaskViewController.swift
//  PLC
//
//  Created by Chris on 6/28/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import Presentr
import SDWebImage

class DetailTaskViewController: UIViewController, RSVPViewControllerDelegate, CheckInViewControllerDelegate, InvolvementViewControllerDelegate{
    
    // MM-dd-yyyy date formatter
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    // MARK: Initialize variables
    var task_in:Task!
    var taskIndex: Int!
    var RSVPController : RSVPViewController?
    var CheckInController : CheckInViewController?
    var InvolvementController : InvolvementViewController?
    var segueFromController: String?
    var isLead = false
    var isParticipant = false
    var isPending = false
    
    // MARK: OUTLETS
    @IBOutlet weak var taskParticipantPoints: UILabel!
    @IBOutlet weak var taskLeaderPoints: UILabel!
    @IBOutlet weak var taskDay: UILabel!
    @IBOutlet weak var taskMonth: UILabel!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var taskTime: UILabel!
    @IBOutlet weak var taskCreatedBy: UIButton!
    @IBOutlet weak var taskDescription: UILabel!
    @IBOutlet weak var taskLeaderAmount: UILabel!
    @IBOutlet weak var taskParticipantAmount: UILabel!
    @IBOutlet weak var taskPhoto: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var RSVPButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var involvementButton: UIButton!
    var presenter = Presentr(presentationType: .bottomHalf)
    
    // Set up presenter appearance
    let presenterInvolvement: Presentr = {
        
        // Width and height
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.90)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 100))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        // Appearance
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = false
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = true
        customPresenter.dismissOnSwipeDirection = .bottom
        
        return customPresenter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Presenter customization
        presenter.dismissOnSwipe = true
        presenter.dismissOnSwipeDirection = .bottom
        presenter.dismissAnimated = true
        presenter.roundCorners = true
        
        checkInButton.isHidden = true
        
        // Show edit, delete, involvement if created by current user. Hide RSVP.
        if task_in.createdBy == currentUser.uid{
            editButton.isEnabled = true
            deleteButton.isEnabled = true
            RSVPButton.isHidden = true
            involvementButton.isHidden = false
        }
        // Else, hide involvement, edit, and delete
        else{
            involvementButton.isHidden = true
            editButton.isEnabled = false
            deleteButton.isEnabled = false
        }
        
        // Get lead/participate tags from task
        let tags = task_in?.tag
        let tagArray = tags?.components(separatedBy: " ")
        for tag in tagArray!{
            if tag == "#lead"{
                isLead = true            }
            if tag == "#participate"{
                isParticipant = true
            }
        }
        
        // Check if task is in Current Tasks and show appropriate buttons
        Constants.refs.databaseCurrentTasks.observe(.value, with: { snapshot in
            // Found in database
            if snapshot.hasChild(self.task_in.id){
                // Hide RSVP
                self.RSVPButton.isHidden = true
                // If user is participant and did not create task, show check in
                if self.isParticipant && !(self.task_in.createdBy == currentUser.uid){
                    self.checkInButton.isHidden = false
                }
            }
        })
        
        // Check if task is in Pending Tasks database and show appropriate buttons
        Constants.refs.databasePendingTasks.observe(.value, with: { snapshot in
            // Found in database
            if snapshot.hasChild(self.task_in.id){
                // Hide RSVP, involvement, and check-in
                self.isPending = true
                self.RSVPButton.isHidden = true
                self.involvementButton.isHidden = true
                self.checkInButton.isHidden = true
            }
        })
        
        // Check if task is in Past Tasks database and show appropriate buttons
        Constants.refs.databasePastTasks.observe(.value, with: { snapshot in
            // Found in database
            if snapshot.hasChild(self.task_in.id){
                // Show edit, hide RSVP, check-in, and involvement
                self.editButton.isEnabled = false
                self.RSVPButton.isHidden = true
                self.checkInButton.isHidden = true
                self.involvementButton.isHidden = false
            }
        })
        
        // Task title fit on one line
        taskTitle.numberOfLines = 1
        taskTitle.adjustsFontSizeToFitWidth = true
        
        // Set title and location
        taskTitle.text = task_in.title
        taskLocation.text = task_in.location
        
        // Parse and arrange date information
        var startTime = task_in.startTime.split(separator: " ")
        var endTime = task_in.endTime.split(separator: " ")
        taskMonth.text = String(startTime[0]).uppercased()
        let taskDayText = String(startTime[1]).split(separator: ",")
        taskDay.text = String(taskDayText[0])
        let checkdate = NSDate(timeIntervalSince1970: task_in.timeMilliseconds)
        let dateString = self.dateFormatter.string(from: checkdate as Date)
        let dayOfWeek = getDayOfWeek(dateString)
        let taskTimeFrame = String(startTime[4]) + " " + String(startTime[5]) + " - " + String(endTime[4]) + " " + String(endTime[5])
        taskTime.text = dayOfWeek! + ", " + String(startTime[0]) + " " + String(taskDayText[0]) + " at " + taskTimeFrame
        
        // Set description
        taskDescription.text = task_in.description
        
        let thisTask = task_in
        
        // Initialize points info
        taskParticipantPoints.text = " None"
        taskLeaderPoints.text = " None"
        let point = Points.init()
        
        // Get points for leader and participant roles
        if isLead{
            taskLeaderPoints.text = "+" + String(point.getPoints(type: "Lead",  thisTask: thisTask)) + " pts"
        }
        if isParticipant{
            taskParticipantPoints.text = "+" + String(point.getPoints(type: "Participant", thisTask: thisTask)) + " pts"
        }
        
        let storageRef = Constants.refs.storage.child("taskPhotos/\(task_in.id).png")
        // Load the image using SDWebImage
        SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
        taskPhoto.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
            // No image set for task
            if error != nil {
                self.taskPhoto.image = #imageLiteral(resourceName: "psheader")
                
                self.taskPhoto.contentMode = UIViewContentMode.scaleAspectFill
                self.taskPhoto.clipsToBounds = true
            }
            // Load image for task
            else {
                self.taskPhoto.contentMode = UIViewContentMode.scaleAspectFill
                self.taskPhoto.clipsToBounds = true
            }

        }
        
        //Setting the label for the user who created event
        Constants.refs.databaseUsers.child(task_in.createdBy).observeSingleEvent(of: .value, with: {(snapshot) in
            self.taskCreatedBy.setTitle((snapshot.childSnapshot(forPath: "firstName").value as! String) + " " + (snapshot.childSnapshot(forPath: "lastName").value as! String), for: .normal)
            })
        
        // Initialize leader and participant amounts
        taskLeaderAmount.text = "0"
        taskParticipantAmount.text = "0"
        
        // Get appropriate leader and participant numbers from db
        if isLead{
            Constants.refs.databaseTasks.child(task_in.id + "/taskRSVP/leaders").observe(.value, with: { snapshot in
                self.taskLeaderAmount.text = String(snapshot.childrenCount)
            })
        }
        if isParticipant{
            Constants.refs.databaseTasks.child(task_in.id + "/taskRSVP/participants").observe(.value, with: { snapshot in
                self.taskParticipantAmount.text = String(snapshot.childrenCount)
            })
        }
    }
    
    // Align description to upper left
    override func viewWillLayoutSubviews() {
        taskDescription.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Show involvement for task
    @IBAction func involvementButton(_ sender: UIButton) {
        InvolvementController = (storyboard?.instantiateViewController(withIdentifier: "InvolvementViewController") as! InvolvementViewController)
        InvolvementController?.delegate = self
        setInvolvementCurrentTask()
        customPresentViewController(presenterInvolvement, viewController: InvolvementController!, animated: true, completion: nil)
    }
    
    // Show RSVP info for task
    @IBAction func RSVPButton(_ sender: UIButton) {
        RSVPController = (storyboard?.instantiateViewController(withIdentifier: "RSVPViewController") as! RSVPViewController)
        RSVPController?.delegate = self
        setRSVPCurrentTask()
        customPresentViewController(presenter, viewController: RSVPController!, animated: true, completion: nil)
    }
    
    // Show check-in info for task
    @IBAction func checkInButton(_ sender: UIButton) {
        CheckInController = (storyboard?.instantiateViewController(withIdentifier: "CheckInViewController") as! CheckInViewController)
        CheckInController?.delegate = self
        setCheckInCurrentTask()
        customPresentViewController(presenter, viewController: CheckInController!, animated: true, completion: nil)
    }
    
    // Delete task
    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        
        // Warning
        let alert = UIAlertController(title: "Delete Task", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            // Remove pending task
            // Remove task from pending tasks db and task_pending under users db
            if self.isPending{
                Constants.refs.databasePendingTasks.child(self.task_in.id).removeValue()
                Constants.refs.databaseUsers.child(currentUser.uid).child("tasks_pending").child(self.task_in.id).removeValue()
            }
            // If liked task, remove from tasks_liked in users db
            Constants.refs.databaseTasks.child(self.task_in.id).child("users_liked").observeSingleEvent(of: .value, with: { snapshot in
            for user in snapshot.children{
                let userInfo = user as! DataSnapshot
                    print(userInfo.key)
                Constants.refs.databaseUsers.child(userInfo.key).child("tasks_liked").child(self.task_in.id).removeValue()
                }
            })
            
            // Set up async
            let deadlineTime = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                // RSVP task
                Constants.refs.databaseTasks.child(self.task_in.id).child("taskRSVP").observeSingleEvent(of: .value, with: { snapshot in
                    for child in snapshot.children{
                        let userType = (child as! DataSnapshot).key
                        
                        // Leaders
                        // Remove events from tasks_lead under user db
                        if userType == "leaders" {
                            for user in (child as! DataSnapshot).children{
                                let userInfo = user as! DataSnapshot
                                
                                // Update user points (remove appropriate points from user gained from deleted event)
                                if !self.isPending{
                                    Constants.refs.databaseUsers.child(userInfo.key).child("points").observeSingleEvent(of: .value, with: {(snap) in
                                        let currentPoints = snap.value as! Int
                                        let point = Points()
                                        Constants.refs.databaseUsers.child(userInfo.key).child("points").setValue(currentPoints - point.getPoints(type: "Lead", thisTask: self.task_in))
                                    })
                                }
                                Constants.refs.databaseUsers.child(userInfo.key).child("tasks_lead").child(self.task_in.id).removeValue()
                            }
                        }
                            
                        // Participant
                        // Remove events from tasks_participated under user db
                        else {
                            for user in (child as! DataSnapshot).children{
                                let userInfo = user as! DataSnapshot
                                
                                // Update user points (subtract points gained from this task from user total points)
                                if !self.isPending{
                                    Constants.refs.databaseUsers.child(userInfo.key).child("points").observeSingleEvent(of: .value, with: {(snap) in
                                        let currentPoints = snap.value as! Int
                                        let point = Points()
                                        Constants.refs.databaseUsers.child(userInfo.key).child("points").setValue(currentPoints - point.getPoints(type: "Participate", thisTask: self.task_in))
                                        
                                    })
                                }
                            Constants.refs.databaseUsers.child(userInfo.key).child("tasks_participated").child(self.task_in.id).removeValue()
                            }
                        }
                    }
                })
                
                // Async
                // Update tasks_created branch under users db
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    Constants.refs.databaseUsers.child(self.task_in.createdBy).child("tasks_created").child(self.task_in.id).removeValue()
                    
                    // Remove points user gained from creating task
                    if !self.isPending{
                        let point = Points()
                        Constants.refs.databaseUsers.child(self.task_in.createdBy).child("points").setValue(currentUser.points - point.getPoints(type: "Create", thisTask: self.task_in))
                    }
                    
                    // Update appropriate databases
                    Constants.refs.databaseUpcomingTasks.child(self.task_in.id).removeValue()
                    Constants.refs.databaseCurrentTasks.child(self.task_in.id).removeValue()
                    Constants.refs.databasePastTasks.child(self.task_in.id).removeValue()
                    Constants.refs.databaseTasks.child(self.task_in.id).removeValue()
                }
                
                // Show appropriate segue after deleting task
                if self.segueFromController == "TaskTableViewController"{
                        self.performSegue(withIdentifier: "unwindToInitiatives", sender: self)
                }
                else if self.segueFromController == "ProfileViewController"{
                    self.performSegue(withIdentifier: "unwindToProfile", sender: self)
                }
                else if self.segueFromController == "FavTaskTableViewController"{
                    self.performSegue(withIdentifier: "unwindToFavInitiatives", sender: self)
                }
                else if self.segueFromController == "DetailSearchTableViewController"{
                    self.performSegue(withIdentifier: "unwindToDetailSearch", sender: self)
                }
            }
        })
        
        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Edit task
        if segue.identifier == "editTask", let destinationVC = segue.destination as? EditInitiativeViewController, let task_out = task_in {
            destinationVC.task_in = task_out
        }
        
        // Profile view
        else if segue.identifier == "toProfile"{
            let destinationVC = segue.destination.childViewControllers[0] as! ProfileViewController
            
            // Destination VC appearance
            destinationVC.signOutButton.isEnabled = false
            destinationVC.signOutButton.tintColor = UIColor.clear
            destinationVC.tutorialButton.isEnabled = false
            destinationVC.tutorialButton.tintColor = UIColor.clear
            
            // Set user info
            Constants.refs.databaseUsers.child(self.task_in.createdBy).observe(.value, with: {(snapshot) in
                let userSnap = snapshot.value as? [String : Any ] ?? [:]
                let user = User(uid: userSnap["uid"] as! String, firstName: userSnap["firstName"] as! String, lastName: userSnap["lastName"] as! String, jobTitle: userSnap["jobTitle"] as! String, department: userSnap["department"] as! String, funFact: userSnap["funFact"] as! String, points: userSnap["points"] as! Int, email: userSnap["email"] as! String)
                destinationVC.user = user
            })
        }
    }
    
    // Unwind to detail view
    @IBAction func unwindToDetail(segue:UIStoryboardSegue) {
        // From edit view
        if segue.source is EditInitiativeViewController{
            // Update task information from db
            Constants.refs.databaseTasks.child(task_in.id).observeSingleEvent(of: .value, with: { snapshot in
                
                // Initialize
                let tasksInfo = snapshot.value as? [String : Any ] ?? [:]
                var amounts = Dictionary<String, Int>()
                
                // Get participant and leader amounts
                if tasksInfo["participantAmount"]! as! Int != 0{
                    amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                }
                if tasksInfo["leaderAmount"]! as! Int != 0{
                    amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                }
                
                // Updated task information
                let updatedTask = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, startTime: tasksInfo["taskTime"]! as! String, endTime: tasksInfo["taskEndTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, endTimeMilliseconds: tasksInfo["taskEndTimeMilliseconds"]! as! TimeInterval, amounts: amounts, usersLikedAmount: tasksInfo["usersLikedAmount"]! as! Int, category: tasksInfo["category"] as! String)
                
                self.task_in = updatedTask
                
                self.viewDidLoad()
            })
        }
    }
    
    //RSVPViewControllerDelegate method
    func setRSVPCurrentTask() {
        RSVPController?.task = task_in
        
    }
    
    //CheckInViewControllerDelegate method
    func setCheckInCurrentTask() {
        CheckInController?.task = task_in
        
    }
    
    //WhoIsGoingTableViewControllerDelegate method
    func setInvolvementCurrentTask() {
        InvolvementController?.task = task_in
        
    }
    
    // Input: Date in the form MM-dd-yyyy, return day of the week
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
