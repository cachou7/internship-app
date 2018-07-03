//
//  InitiativesViewController.swift
//  PLC
//
//  Created by Chris on 6/25/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase
import NavigationDropdownMenu

var myIndex = 0
var items: [Task] = []
var menuView: NavigationDropdownMenu!

class TaskTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, TaskTableViewCellDelegate {
    //MARK: Actions
    @IBAction func segmentedBar(_ sender: UISegmentedControl) {
        print("CHANGE")
        if segmentedBarOutlet.selectedSegmentIndex == 0{
            items.sort(by: {$0.timestamp > $1.timestamp})
            print("0")
            for item in items{
                print(item.timestamp)
            }
            self.tableView.reloadData()
        }
        else if segmentedBarOutlet.selectedSegmentIndex == 1{
            items.sort(by: {$0.ranking > $1.ranking})
            print("1")
            for item in items{
                print(item.ranking)
            }
            self.tableView.reloadData()
        }
        else{
            items.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
            print("2")
            for item in items{
                print(item.timeMilliseconds)
            }
            self.tableView.reloadData()
        }
    }
    // Variables
    @IBOutlet weak var segmentedBarOutlet: UISegmentedControl!
    var menuView: NavigationDropdownMenu!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //DROPDOWN MENU
        let menuItems = ["All Initiatives", "Community Initiatives", "Big Idea Initiatives"]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

        menuView = NavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: Title.index(0), items: menuItems)

        menuView.cellHeight = 50
        menuView.cellBackgroundColor = UIColor.white
        menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
        menuView.shouldKeepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor.black
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
        menuView.cellTextLabelAlignment = .left // .Center // .Right // .Left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.black
        menuView.maskBackgroundOpacity = 0.3
        
        menuView.showRightLine = true
        
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> Void in
            print("Did select item at index: \(indexPath)")
        }
        
        self.navigationItem.titleView = menuView
        //END OF DROPDOWN MENU
        
        //Tasks Loaded From DB
        Constants.refs.databaseTasks.observe(.value, with: { snapshot in
        var newItems: [Task] = []
        var createdBy: String
        var ranking: String
        var timeMilliseconds: String
            
        for child in snapshot.children {
            if let snapshot = child as? DataSnapshot{
                
                //Checks for tasks created before "createdBy" portion added
                if ((snapshot.childSnapshot(forPath: "createdBy").value as? String) != nil){
                    createdBy = snapshot.childSnapshot(forPath: "createdBy").value as! String
                }
                else {
                    createdBy = "DefaultUser"
                }
                if ((snapshot.childSnapshot(forPath: "ranking").value as? String) != nil){
                    ranking = snapshot.childSnapshot(forPath: "ranking").value as! String
                }
                else {
                    ranking = "0"
                }
                if ((snapshot.childSnapshot(forPath: "taskTimeMilliseconds").value as? String) != nil){
                    timeMilliseconds = snapshot.childSnapshot(forPath: "taskTimeMilliseconds").value as! String
                }
                else {
                    timeMilliseconds = "0"
                }
                
                //Checks for tasks created before "ranking" portion added
                
                let task = Task(title: snapshot.childSnapshot(forPath: "taskTitle").value! as! String, description: snapshot.childSnapshot(forPath: "taskDescription").value! as! String, tag: snapshot.childSnapshot(forPath: "taskTag").value! as! String, time: snapshot.childSnapshot(forPath: "taskTime").value! as! String, location: snapshot.childSnapshot(forPath: "taskLocation").value! as! String, timestamp: snapshot.childSnapshot(forPath: "timestamp").value! as! String, id: snapshot.childSnapshot(forPath: "taskId").value! as! String, createdBy: createdBy, ranking: ranking, timeMilliseconds: timeMilliseconds)
                newItems.append(task!)
            }
            
            items = newItems
            if self.segmentedBarOutlet.selectedSegmentIndex == 0{
                items.sort(by: {$0.timestamp > $1.timestamp})
                self.tableView.reloadData()
            }
            else if self.segmentedBarOutlet.selectedSegmentIndex == 1{
                items.sort(by: {$0.ranking > $1.ranking})
                self.tableView.reloadData()
            }
            else{
                items.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
                self.tableView.reloadData()
            }
            }})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        cell.taskTitle.text = items[indexPath.row].title
        cell.taskLocation.text = items[indexPath.row].location
        cell.taskTime.text = items[indexPath.row].time
        cell.taskTag.text = items[indexPath.row].tag
        
        //Check if user has liked the task and display correct heart
        currentTasks.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.hasChild(items[indexPath.row].id) {
                let unlikedIcon = UIImage(named: "heartIcon")
                cell.taskLiked.setImage(unlikedIcon, for: .normal)
            }
            else {
                let likedIcon = UIImage(named: "redHeart")
                cell.taskLiked.setImage(likedIcon, for: .normal)
            }
        })
        cell.delegate = self
        return cell
    }
    
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        //print("Heart", sender, tappedIndexPath.row)
        
        sender.isSelected = !sender.isSelected
         
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        
        // Heart tapped, set image to red heart
        if (sender.isSelected) {
            let likedIcon = UIImage(named: "redHeart")
            sender.taskLiked.setImage(likedIcon, for: .normal)
            sender.contentView.backgroundColor = UIColor.white
            currentTasks.child(items[tappedIndexPath.row].id).setValue(true)
        }
        // Heart untapped, set image to blank heart
        else {
            let unlikedIcon = UIImage(named: "heartIcon")
            sender.taskLiked.setImage(unlikedIcon, for: .normal)
            currentTasks.child(items[tappedIndexPath.row].id).setValue(nil)
         }
    }
    // Set myIndex for detailed view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        self.tableView.reloadData()
        //performSegue(withIdentifier: "detailTask", sender: self)
    }
    
    @IBAction func composeButton(_ sender: UIBarButtonItem) {
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "InitiativeCreate", bundle: nil).instantiateViewController(withIdentifier: "InitiativeCreateViewController")
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self as UIPopoverPresentationControllerDelegate

        // present the popover
        self.present(popController, animated: true, completion: nil)
        
        self.tableView.reloadData()
    }
    
    // UIPopoverPresentationControllerDelegate method
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Force popover style
        return UIModalPresentationStyle.popover
    }
        
}

