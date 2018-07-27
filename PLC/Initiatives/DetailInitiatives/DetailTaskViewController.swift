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
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    var task_in:Task!
    var taskIndex: Int!
    var RSVPController : RSVPViewController?
    var CheckInController : CheckInViewController?
    var InvolvementController : InvolvementViewController?
    var segueFromController: String?
    var isLead = false
    var isParticipant = false
    
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
    var presenter = Presentr(presentationType: .bottomHalf)
    let presenterInvolvement: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.90)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 100))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        //customPresenter.transitionType = .coverVerticalFromBottom
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = false
        //customPresenter.backgroundColor = .green
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = true
        customPresenter.dismissOnSwipeDirection = .bottom
        return customPresenter
    }()

    @IBOutlet weak var RSVPButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var involvementButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.dismissOnSwipe = true
        presenter.dismissOnSwipeDirection = .bottom
        presenter.dismissAnimated = true
        presenter.roundCorners = true
        
        checkInButton.isHidden = true
        
        if task_in.createdBy == currentUser.uid{
            editButton.isEnabled = true
            deleteButton.isEnabled = true
            RSVPButton.isHidden = true
            involvementButton.isHidden = false
        }
        else{
            involvementButton.isHidden = true
            editButton.isEnabled = false
            deleteButton.isEnabled = false
        }
        
        let tags = task_in?.tag
        let tagArray = tags?.components(separatedBy: " ")
        for tag in tagArray!{
            if tag == "#lead"{
                isLead = true            }
            if tag == "#participate"{
                isParticipant = true
            }
        }
        
        Constants.refs.databaseCurrentTasks.observe(.value, with: { snapshot in
            if snapshot.hasChild(self.task_in.id){
                self.RSVPButton.isHidden = true
                if self.isParticipant && !(self.task_in.createdBy == currentUser.uid){
                    self.checkInButton.isHidden = false
                }
            }
        })
        
        Constants.refs.databasePastTasks.observe(.value, with: { snapshot in
            if snapshot.hasChild(self.task_in.id){
                self.editButton.isEnabled = false
                self.RSVPButton.isHidden = true
                self.checkInButton.isHidden = true
                self.involvementButton.isHidden = false
            }
        })
        
        // Do any additional setup after loading the view.
        taskTitle.numberOfLines = 1
        taskTitle.adjustsFontSizeToFitWidth = true
        taskTitle.text = task_in.title
        taskLocation.text = task_in.location
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
        taskDescription.text = task_in.description
        let thisTask = task_in
        
        taskParticipantPoints.text = " None"
        taskLeaderPoints.text = " None"
        
        let point = Points.init()
        if isLead{
            taskLeaderPoints.text = "+" + String(point.getPoints(type: "Lead", category: thisTask!.category, thisTask: thisTask)) + " pts"
        }
        if isParticipant{
            taskParticipantPoints.text = "+" + String(point.getPoints(type: "Participant", category: thisTask!.category, thisTask: thisTask)) + " pts"
        }
        
        let storageRef = Constants.refs.storage.child("taskPhotos/\(task_in.id).png")
        // Load the image using SDWebImage
        SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
        taskPhoto.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
            if error != nil {
                self.taskPhoto.image = #imageLiteral(resourceName: "merchMart")
                
                self.taskPhoto.contentMode = UIViewContentMode.scaleAspectFill
                self.taskPhoto.clipsToBounds = true
            }
            else{
                self.taskPhoto.contentMode = UIViewContentMode.scaleAspectFill
                self.taskPhoto.clipsToBounds = true
                print("Successfuly loaded image")
            }

        }
        
        //Setting the label for the user who created event
        Constants.refs.databaseUsers.child(task_in.createdBy).observeSingleEvent(of: .value, with: {(snapshot) in
            self.taskCreatedBy.setTitle((snapshot.childSnapshot(forPath: "firstName").value as! String) + " " + (snapshot.childSnapshot(forPath: "lastName").value as! String), for: .normal)
            })
        
        taskLeaderAmount.text = "0"
        taskParticipantAmount.text = "0"
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
    
    // align description to upper left
    override func viewWillLayoutSubviews() {
        taskDescription.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func involvementButton(_ sender: UIButton) {
        InvolvementController = (storyboard?.instantiateViewController(withIdentifier: "InvolvementViewController") as! InvolvementViewController)
        InvolvementController?.delegate = self
        setInvolvementCurrentTask()
        customPresentViewController(presenterInvolvement, viewController: InvolvementController!, animated: true, completion: nil)
    }
    @IBAction func RSVPButton(_ sender: UIButton) {
        RSVPController = (storyboard?.instantiateViewController(withIdentifier: "RSVPViewController") as! RSVPViewController)
        RSVPController?.delegate = self
        setRSVPCurrentTask()
        customPresentViewController(presenter, viewController: RSVPController!, animated: true, completion: nil)
        
    }
    
    @IBAction func checkInButton(_ sender: UIButton) {
        CheckInController = (storyboard?.instantiateViewController(withIdentifier: "CheckInViewController") as! CheckInViewController)
        CheckInController?.delegate = self
        setCheckInCurrentTask()
        customPresentViewController(presenter, viewController: CheckInController!, animated: true, completion: nil)
    }
    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Task", message: "Are you sure you want to delete this task?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Constants.refs.databaseTasks.child(self.task_in.id).child("users_liked").observeSingleEvent(of: .value, with: { snapshot in
            for user in snapshot.children{
                let userInfo = user as! DataSnapshot
                    print(userInfo.key)
                Constants.refs.databaseUsers.child(userInfo.key).child("tasks_liked").child(self.task_in.id).removeValue()
                }});
            Constants.refs.databaseUsers.child(self.task_in.createdBy).child("tasks_created").child(self.task_in.id).removeValue();
            Constants.refs.databaseUpcomingTasks.child(self.task_in.id).removeValue();
            Constants.refs.databaseCurrentTasks.child(self.task_in.id).removeValue();
            Constants.refs.databaseCurrentTasks.child(self.task_in.id).removeValue();
            Constants.refs.databaseTasks.child(self.task_in.id).removeValue()
            
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
            
            })
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask", let destinationVC = segue.destination as? EditInitiativeViewController, let task_out = task_in {
            destinationVC.task_in = task_out
        }
        else if segue.identifier == "toProfile"{
            let destinationVC = segue.destination.childViewControllers[0] as! ProfileViewController
            destinationVC.signOutButton.isEnabled = false
            destinationVC.signOutButton.tintColor = UIColor.clear
            Constants.refs.databaseUsers.child(self.task_in.createdBy).observe(.value, with: {(snapshot) in
                let userSnap = snapshot.value as? [String : Any ] ?? [:]
                let user = User(uid: userSnap["uid"] as! String, firstName: userSnap["firstName"] as! String, lastName: userSnap["lastName"] as! String, jobTitle: userSnap["jobTitle"] as! String, department: userSnap["department"] as! String, currentProjects: userSnap["currentProjects"] as! String, points: userSnap["points"] as! Int, email: userSnap["email"] as! String)
                destinationVC.user = user
                
            })
            //self.show(destinationVC, sender: Any?.self)
        }
    }
    
    @IBAction func unwindToDetail(segue:UIStoryboardSegue) {
        if segue.source is EditInitiativeViewController{
            Constants.refs.databaseTasks.child(task_in.id).observeSingleEvent(of: .value, with: { snapshot in
                let tasksInfo = snapshot.value as? [String : Any ] ?? [:]
                var amounts = Dictionary<String, Int>()
                if tasksInfo["participantAmount"]! as! Int != 0{
                    amounts["participants"] = (tasksInfo["participantAmount"]! as! Int)
                }
                if tasksInfo["leaderAmount"]! as! Int != 0{
                    amounts["leaders"] = (tasksInfo["leaderAmount"]! as! Int)
                }
                
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
