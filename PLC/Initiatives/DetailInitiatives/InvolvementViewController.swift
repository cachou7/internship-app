//
//  InvolvementViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/19/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

// Involvement protocol
protocol InvolvementViewControllerDelegate
{
    func setInvolvementCurrentTask()
}

class InvolvementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Initialize
    var users: [User] = []
    var delegate: InvolvementViewControllerDelegate?
    var task: Task?
    var leaders: [String] = []
    var participants: [String] = []
    var sections: [String] = []
    var sectionArrays: [String:[String]] = [:]
    
    // MARK: OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePage()
    }
    
    // dataSource and delegates
    override func viewDidAppear(_ animated: Bool) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    // Get check-in and RSVP information
    private func configurePage(){
        // Get check-in information for task from task db
        Constants.refs.databaseTasks.child(task!.id).child("taskCheckIn").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let checkedInInfo = snapshot.value as! [String : String]
                        // If not empty, then append information
                        if self.sectionArrays["Checked In"] != nil {
                            (self.sectionArrays["Checked In"]!).append(checkedInInfo["userID"]!)
                        }
                        // Initialize checked-in section
                        else {
                            self.sections.append("Checked In")
                            self.sectionArrays["Checked In"] = [checkedInInfo["userID"]!]
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        })
        
        // Get leader RSVP information from task db
        Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("leaders").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let leaderInfo = snapshot.value as! [String : String ]
                        // If not empty, append leader information
                        if self.sectionArrays["Signed Up"] != nil{
                            (self.sectionArrays["Signed Up"]!).append(leaderInfo["userID"]!)
                        }
                        // If empty, initialize with leader information
                        else{
                            self.sections.append("Signed Up")
                            self.sectionArrays["Signed Up"] = [leaderInfo["userID"]!]
                        }

                        self.leaders.append(leaderInfo["userID"]!)
                        self.tableView.reloadData()
                    }
                }
            }
        })
        
        // Get participant RSVP information from task db
        Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("participants").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let participantInfo = snapshot.value as! [String : String]
                        // If not empty, append participant info
                        if self.sectionArrays["Signed Up"] != nil {
                            (self.sectionArrays["Signed Up"]!).append(participantInfo["userID"]!)
                        }
                        // Else, initialize with participant info
                        else{
                            self.sections.append("Signed Up")
                            self.sectionArrays["Signed Up"] = [participantInfo["userID"]!]
                        }
                        
                        self.participants.append(participantInfo["userID"]!)
                        self.tableView.reloadData()
                    }
                }
            }
        })
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Return number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        
        // At least one person leading or participating
        if self.sections.count > 0 {
            // Appearance
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            
            numOfSections = self.sections.count
        }
        else {
            
            // Data label appearance
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No users involved"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            
            // Table view appearance
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }
    
    // Number of people participating/leading
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.sectionArrays[sections[section]]?.count)!
    }
    
    // Leading or particiapting header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! InvolvementTableViewCell

        //Cell formatting
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.1
        cell.layer.cornerRadius = 20
        
        //Cell ImageView Formatting
        cell.userProfilePhoto.layer.cornerRadius = cell.userProfilePhoto.frame.size.width/2
        cell.userProfilePhoto.layer.borderWidth = 0.1
        cell.userProfilePhoto.layer.borderColor = UIColor.black.cgColor
        cell.userProfilePhoto.clipsToBounds = true
        
        for i in 0..<self.sectionArrays.count {
            
            // Found section
            if (indexPath.section == i) {
                
                // Set user image icon
                if sections[i] == "Checked In"{
                    cell.userTypeIcon.image = #imageLiteral(resourceName: "iconPerson")
                }
                else {
                    if participants.contains((sectionArrays[sections[i]]?[indexPath.row])!){
                        cell.userTypeIcon.image = #imageLiteral(resourceName: "iconPerson")
                    }
                }
                
                // Get user first and last name from db
                Constants.refs.databaseUsers.child((sectionArrays[sections[i]]?[indexPath.row])!).observeSingleEvent(of: .value, with: {(snapshot) in
                    cell.userProfileLink.text = (snapshot.childSnapshot(forPath: "firstName").value as! String) + " " + (snapshot.childSnapshot(forPath: "lastName").value as! String)
                })
                
                let storageRef = Constants.refs.storage.child("userPhotos/\((sectionArrays[sections[i]]?[indexPath.row])!).png")
                
                // Load the image using SDWebImage
                SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
                cell.userProfilePhoto.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
                    if error != nil {
                        cell.userProfilePhoto.image = #imageLiteral(resourceName: "iconProfile")
                    }
                    
                }
            }
        }

        return cell
    }
    
    // Prepare segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Segue to Profile (detail profile view)
        if segue.identifier == "toProfile"{
            let destinationVC = segue.destination.childViewControllers[0] as! ProfileViewController
            
            // DestinationVC appearance
            destinationVC.signOutButton.isEnabled = false
            destinationVC.signOutButton.tintColor = UIColor.clear
            destinationVC.tutorialButton.isEnabled = false
            destinationVC.tutorialButton.tintColor = UIColor.clear
            
            // Get user information from user db and set destinationVC user to this user
            for i in 0..<self.sectionArrays.count{
                if (tableView.indexPathForSelectedRow?.section == i) {
                    Constants.refs.databaseUsers.child((sectionArrays[sections[i]]?[(tableView.indexPathForSelectedRow?.row)!])!).observe(.value, with: {(snapshot) in
                    let userSnap = snapshot.value as? [String : Any ] ?? [:]
                        let user = User(uid: userSnap["uid"] as! String, firstName: userSnap["firstName"] as! String, lastName: userSnap["lastName"] as! String, jobTitle: userSnap["jobTitle"] as! String, department: userSnap["department"] as! String, funFact: userSnap["funFact"] as! String, points: userSnap["points"] as! Int, email: userSnap["email"] as! String)
                    destinationVC.user = user
                    
                    })
                }
            }
        }
    }
}
