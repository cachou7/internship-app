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

protocol InvolvementViewControllerDelegate
{
    func setInvolvementCurrentTask()
    
}

class InvolvementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var users: [User] = []
    var delegate: InvolvementViewControllerDelegate?
    var task: Task?
    var leaders: [String] = []
    var participants: [String] = []
    var sections: [String] = []
    var sectionArrays: [String:[String]] = [:]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    private func configurePage(){
        Constants.refs.databaseTasks.child(task!.id).child("taskCheckIn").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let checkedInInfo = snapshot.value as! [String : String]
                        if self.sectionArrays["Checked In"] != nil{
                            (self.sectionArrays["Checked In"]!).append(checkedInInfo["userID"]!)
                        }
                        else{
                            self.sections.append("Checked In")
                            self.sectionArrays["Checked In"] = [checkedInInfo["userID"]!]
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        })
        Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("leaders").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let leaderInfo = snapshot.value as! [String : String ]
                        if self.sectionArrays["Signed Up"] != nil{
                            (self.sectionArrays["Signed Up"]!).append(leaderInfo["userID"]!)
                        }
                        else{
                            self.sections.append("Signed Up")
                            self.sectionArrays["Signed Up"] = [leaderInfo["userID"]!]
                        }
                        //(self.sectionArrays["Signed Up"]!).append(leaderInfo["userID"]!)
                        self.leaders.append(leaderInfo["userID"]!)
                        self.tableView.reloadData()
                    }
                }
            }
        })
        Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("participants").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let participantInfo = snapshot.value as! [String : String ]
                        if self.sectionArrays["Signed Up"] != nil{
                            (self.sectionArrays["Signed Up"]!).append(participantInfo["userID"]!)
                        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if self.sections.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections = self.sections.count
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No users involved"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows is "+String((self.sectionArrays[sections[section]]?.count)!))
        return (self.sectionArrays[sections[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("The section is "+sections[section])
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! InvolvementTableViewCell

        //Cell formating
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.1
        cell.layer.cornerRadius = 20
        //Cell ImageView Formatting
        cell.userProfilePhoto.layer.cornerRadius = cell.userProfilePhoto.frame.size.width/2
        cell.userProfilePhoto.layer.borderWidth = 0.1
        cell.userProfilePhoto.layer.borderColor = UIColor.black.cgColor
        cell.userProfilePhoto.clipsToBounds = true
        
        for i in 0..<self.sectionArrays.count{
            if (indexPath.section == i) {
                if sections[i] == "Checked In"{
                    cell.userTypeIcon.image = #imageLiteral(resourceName: "iconPerson")
                }
                else{
                    if participants.contains((sectionArrays[sections[i]]?[indexPath.row])!){
                        cell.userTypeIcon.image = #imageLiteral(resourceName: "iconPerson")
                    }
                }
                Constants.refs.databaseUsers.child((sectionArrays[sections[i]]?[indexPath.row])!).observeSingleEvent(of: .value, with: {(snapshot) in
                    cell.userProfileLink.text = (snapshot.childSnapshot(forPath: "firstName").value as! String) + " " + (snapshot.childSnapshot(forPath: "lastName").value as! String)
                })
                //cell.userProfileLink.text = sectionArrays[sections[i]]?[indexPath.row]
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
        
        //cell.delegate = self
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile"{
            let destinationVC = segue.destination.childViewControllers[0] as! ProfileViewController
            destinationVC.signOutButton.isEnabled = false
            destinationVC.signOutButton.tintColor = UIColor.clear
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
