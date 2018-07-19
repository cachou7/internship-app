//
//  WhoIsGoingTableViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/19/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

protocol WhoIsGoingTableViewControllerDelegate
{
    func setWhoIsGoingCurrentTask()
    
}

class WhoIsGoingTableViewController: UITableViewController {
    var users: [User] = []
    var delegate: WhoIsGoingTableViewControllerDelegate?
    var task: Task?
    var leaders: [String] = []
    var participants: [String] = []
    var sections: [String] = []
    var sectionArrays: [String:[String]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tags = task?.tag
        let tagArray = tags?.components(separatedBy: " ")
        for tag in tagArray!{
            if tag == "#lead"{
                sections.append("Leaders")
                sectionArrays["Leaders"] = []
            }
            if tag == "#participate"{
                sections.append("Participants")
                sectionArrays["Participants"] = []
            }
            
        }
        configurePage()
        
        
        //Constants.refs.databaseTasks.child(task?.id).

        // Do any additional setup after loading the view.
    }
    
    private func configurePage(){
        Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("leaders").observe(.value, with: { snapshot in
                    var newLeaders: [String] = []
                    if (snapshot.exists()){
                        for child in snapshot.children {
                            if let snapshot = child as? DataSnapshot{
                                let leaderInfo = snapshot.value as! [String : String ]
                                print(leaderInfo["userID"]!)
                                newLeaders.append(leaderInfo["userID"]!)
                            }
                           (self.sectionArrays["Leaders"]!).append(contentsOf: newLeaders)
                        }
                    }
                })
        self.tableView.reloadData()
                //Getting RSVP-ed participants
            Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("participants").observe(.value, with: { snapshot in
                    var newParticipants: [String] = []
                    if (snapshot.exists()){
                        for child in snapshot.children {
                            if let snapshot = child as? DataSnapshot{
                                let participantInfo = snapshot.value as! [String : String ]
                                newParticipants.append(participantInfo["userID"]!)
                            }
                            (self.sectionArrays["Participants"]!).append(contentsOf: newParticipants)
                        }
                    }
                })
        self.tableView.reloadData()
        return
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print("# of sections is "+String(self.sections.count))
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows is "+String((self.sectionArrays[sections[section]]?.count)!))
        return (self.sectionArrays[sections[section]]?.count)!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        print("The section is "+sections[section])
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! WhoIsGoingTableViewCell
        print(cell.userProfileLink.text as Any)
        //Cell formating
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 20
        //Cell ImageView Formatting
        cell.userProfilePhoto.layer.cornerRadius = cell.userProfilePhoto.frame.size.width/2
        cell.userProfilePhoto.layer.borderWidth = 0.5
        cell.userProfilePhoto.layer.borderColor = UIColor.black.cgColor
        cell.userProfilePhoto.clipsToBounds = true
    
        //cell.userProfileLink.text = String(self.overallItems[indexPath.row].usersLikedAmount)
        
        for i in 0..<self.sectionArrays.count{
            if (indexPath.section == i) {
                print(sectionArrays[sections[i]]?[indexPath.row])
                cell.userProfileLink.text = sectionArrays[sections[i]]?[indexPath.row]
            }
        }
        
        //cell.delegate = self
        return cell
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
