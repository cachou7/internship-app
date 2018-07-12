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

class TaskTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, TaskTableViewCellDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    //MARK: Actions
    
    //SEGMENTED BAR
    @IBAction func segmentedBar(_ sender: UISegmentedControl) {
        print("CHANGE")
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
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        popController.popoverPresentationController?.barButtonItem = sender
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self as UIPopoverPresentationControllerDelegate
        
        // present the popover
        self.present(popController, animated: true, completion: nil)
        self.tableView.reloadData()
    }
    //END COMPOSE BUTTON
    
    //MARK: Variables
    @IBOutlet weak var segmentedBarOutlet: UISegmentedControl!
    var menuView: NavigationDropdownMenu!
    var searchController: UISearchController!
    var myIndex = 0
    var currentDB: String = ""
    //var items: [Task] = []
    var overallItems: [Task] = []
    var bigIdeaItems: [Task] = []
    var communityItems: [Task] = []
    var filteredItems: [Task] = []
    var indexDropdown: Int = 0
    var passedTask:Task!
    var shouldShowSearchResults = false
    var initialToolbar: UIView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialToolbar = tableView.tableHeaderView
        
        //SEARCH BAR FUNCTION
        self.configureSearchBar()
        
        
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
            self.indexDropdown = indexPath
            self.sortTasks()
        }
        
        self.navigationItem.titleView = menuView
        //END OF DROPDOWN MENU
        
        //Tasks Loaded From DB
        Constants.refs.databaseTasks.observe(.value, with: { snapshot in
        var newOverallItems: [Task] = []
        var newCommunityItems: [Task] = []
        var newBigIdeaItems: [Task] = []
        
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
                let task = Task(title: tasksInfo["taskTitle"]! as! String, description: tasksInfo["taskDescription"]! as! String, tag: tasksInfo["taskTag"]! as! String, time: tasksInfo["taskTime"]! as! String, location: tasksInfo["taskLocation"]! as! String, timestamp: tasksInfo["timestamp"]! as! TimeInterval, id: tasksInfo["taskId"]! as! String, createdBy: tasksInfo["createdBy"]! as! String, ranking: tasksInfo["ranking"]! as! Int, timeMilliseconds: tasksInfo["taskTimeMilliseconds"]! as! TimeInterval, type: tasksInfo["taskType"]! as! String, amounts: amounts)
                
                newOverallItems.append(task!)
                
                if task?.type == "Community"{
                    newCommunityItems.append(task!)
                }
                else if task?.type == "Big Idea"{
                    newBigIdeaItems.append(task!)
                }
            }
            self.overallItems = newOverallItems
            self.bigIdeaItems = newBigIdeaItems
            self.communityItems = newCommunityItems
            
            self.sortTasks()
            }})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults{
            return filteredItems.count
        }
        else{
            if self.currentDB == "All" {
                return self.overallItems.count
            }
            else if self.currentDB == "Community" {
                return self.communityItems.count
            }
            else {
                return self.bigIdeaItems.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        
        if shouldShowSearchResults{
            cell.taskTitle.text = filteredItems[indexPath.row].title
            cell.taskLocation.text = filteredItems[indexPath.row].location
            cell.taskTime.text = filteredItems[indexPath.row].time
            cell.taskTag.text = filteredItems[indexPath.row].tag
            
            //Check if user has liked the task and display correct heart
            currentTasks.observe(.value, with: { snapshot in
                if !snapshot.hasChild(self.filteredItems[indexPath.row].id) {
                    let unlikedIcon = UIImage(named: "heartIcon")
                    cell.taskLiked.setImage(unlikedIcon, for: .normal)
                }
                else {
                    let likedIcon = UIImage(named: "redHeart")
                    cell.taskLiked.setImage(likedIcon, for: .normal)
                }
            })
        }
        else{
            
            if self.indexDropdown == 0 {
                cell.taskTitle.text = self.overallItems[indexPath.row].title
                cell.taskLocation.text = self.overallItems[indexPath.row].location
                cell.taskTime.text = self.overallItems[indexPath.row].time
                cell.taskTag.text = self.overallItems[indexPath.row].tag
                
                //Check if user has liked the task and display correct heart
                currentTasks.observe(.value, with: { snapshot in
                    if !snapshot.hasChild(self.overallItems[indexPath.row].id) {
                        let unlikedIcon = UIImage(named: "heartIcon")
                        cell.taskLiked.setImage(unlikedIcon, for: .normal)
                    }
                    else {
                        let likedIcon = UIImage(named: "redHeart")
                        cell.taskLiked.setImage(likedIcon, for: .normal)
                    }
                })
            }
            
            else if self.indexDropdown == 1 {
                cell.taskTitle.text = self.communityItems[indexPath.row].title
                cell.taskLocation.text = self.communityItems[indexPath.row].location
                cell.taskTime.text = self.communityItems[indexPath.row].time
                cell.taskTag.text = self.communityItems[indexPath.row].tag
                
                //Check if user has liked the task and display correct heart
                currentTasks.observe(.value, with: { snapshot in
                    if !snapshot.hasChild(self.communityItems[indexPath.row].id) {
                        let unlikedIcon = UIImage(named: "heartIcon")
                        cell.taskLiked.setImage(unlikedIcon, for: .normal)
                    }
                    else {
                        let likedIcon = UIImage(named: "redHeart")
                        cell.taskLiked.setImage(likedIcon, for: .normal)
                    }
                })
            }
            
            else {
                cell.taskTitle.text = self.bigIdeaItems[indexPath.row].title
                cell.taskLocation.text = self.bigIdeaItems[indexPath.row].location
                cell.taskTime.text = self.bigIdeaItems[indexPath.row].time
                cell.taskTag.text = self.bigIdeaItems[indexPath.row].tag
                
                //Check if user has liked the task and display correct heart
                currentTasks.observe(.value, with: { snapshot in
                    if !snapshot.hasChild(self.bigIdeaItems[indexPath.row].id) {
                        let unlikedIcon = UIImage(named: "heartIcon")
                        cell.taskLiked.setImage(unlikedIcon, for: .normal)
                    }
                    else {
                        let likedIcon = UIImage(named: "redHeart")
                        cell.taskLiked.setImage(likedIcon, for: .normal)
                    }
                })
            }
        }

        cell.delegate = self
        return cell
    }
    
    //LIKING TASKS
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        //print("Heart", sender, tappedIndexPath.row)
        sender.isSelected = !sender.isSelected

        let items: [Task]
        if self.currentDB == "All" {
            items = overallItems
        }
        else if self.currentDB == "Community"{
            items = communityItems
        }
        else{
            items = bigIdeaItems
        }
        
        let currentTasks = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_liked")
        
        

        currentTasks.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //HEART TAPPED
            if !(snapshot.hasChild(items[tappedIndexPath.row].id)){
                let likedIcon = UIImage(named: "redHeart")
                sender.taskLiked.setImage(likedIcon, for: .normal)
                sender.contentView.backgroundColor = UIColor.white
                currentTasks.child(items[tappedIndexPath.row].id).setValue(true)
                Constants.refs.databaseTasks.child(items[tappedIndexPath.row].id).child("users_liked").child(currentUser.uid).setValue(true)
                Constants.refs.databaseTasks.child(items[tappedIndexPath.row].id).child("ranking").setValue(items[tappedIndexPath.row].ranking + 1)
            }
            //END HEART TAPPED
                
            //HEART UNTAPPED
            else {
                let unlikedIcon = UIImage(named: "heartIcon")
                sender.taskLiked.setImage(unlikedIcon, for: .normal)
                currentTasks.child(items[tappedIndexPath.row].id).removeValue()
                Constants.refs.databaseTasks.child(items[tappedIndexPath.row].id).child("users_liked").child(currentUser.uid).removeValue()
                Constants.refs.databaseTasks.child(items[tappedIndexPath.row].id).child("ranking").setValue(items[tappedIndexPath.row].ranking - 1)
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
            if self.currentDB == "All" {
                destinationVC.task_in = self.overallItems[myIndex]
            }
            else if self.currentDB == "Community" {
                destinationVC.task_in = self.communityItems[myIndex]
            }
            else {
                destinationVC.task_in = self.bigIdeaItems[myIndex]
            }
            destinationVC.taskIndex = myIndex
        }
    }
    
    
    //SEARCH FUNCTION
    func configureSearchBar(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
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
    
    // UIPopoverPresentationControllerDelegate method
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Force popover style
        return UIModalPresentationStyle.popover
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    // Sorts tasks based on which tab bar and menu dropdown bar is selected, then reload view
    func sortTasks() -> Void {
        //OVERALL
        if self.indexDropdown == 0{
            self.currentDB = "All"
            if self.segmentedBarOutlet.selectedSegmentIndex == 0{
                self.overallItems.sort(by: {$0.timestamp > $1.timestamp})
            }
            else if self.segmentedBarOutlet.selectedSegmentIndex == 1{
                self.overallItems.sort(by: {$0.ranking > $1.ranking})
            }
            else{
                self.overallItems.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
            }
        }
        //END OVERALL
            
        //COMMUNITY
        else if self.indexDropdown == 1{
            //self.items = self.communityItems
            self.currentDB = "Community"
            if self.segmentedBarOutlet.selectedSegmentIndex == 0{
                self.communityItems.sort(by: {$0.timestamp > $1.timestamp})
            }
            else if self.segmentedBarOutlet.selectedSegmentIndex == 1{
                self.communityItems.sort(by: {$0.ranking > $1.ranking})
            }
            else{
                self.communityItems.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
            }
        }
        //END COMMUNITY
            
        //BIG IDEA
        else{
            //self.items = self.bigIdeaItems
            self.currentDB = "Big Ideas"
            if self.segmentedBarOutlet.selectedSegmentIndex == 0{
                self.bigIdeaItems.sort(by: {$0.timestamp > $1.timestamp})
            }
            else if self.segmentedBarOutlet.selectedSegmentIndex == 1{
                self.bigIdeaItems.sort(by: {$0.ranking > $1.ranking})
            }
            else{
                self.bigIdeaItems.sort(by: {$0.timeMilliseconds < $1.timeMilliseconds})
            }
        }
        //END BIG IDEA
        self.tableView.reloadData()
    }
    
    @IBAction func unwindToInitiatives(segue:UIStoryboardSegue) {
        if segue.source is DetailTaskViewController{
            self.tableView.reloadData()
        }
    }
}

