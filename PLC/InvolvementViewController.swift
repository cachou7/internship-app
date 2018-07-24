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
    //var signUps: [String] = []
    //var checkIns: [String] = []
    var leaders: [String] = []
    var participants: [String] = []
    var sections: [String] = ["Signed Up"]
    var sectionArrays: [String:[String]] = [:]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //checkInTableView.isHidden = true
        sectionArrays["Signed Up"] = []
        
        let tags = task?.tag
        let tagArray = tags?.components(separatedBy: " ")
        for tag in tagArray!{
            if tag == "#participate"{
                self.sections.append("Checked In")
                self.sectionArrays["Checked In"] = []
            }
            
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configurePage()
    }
    
    private func configurePage(){
        Constants.refs.databaseTasks.child(task!.id).child("taskCheckIn").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let checkedInInfo = snapshot.value as! [String : String]
                        print(checkedInInfo["userID"]!)
                        (self.sectionArrays["Checked In"]!).append(checkedInInfo["userID"]!)
                        print(checkedInInfo["userID"]!)
                    }
                }
            }
        })
       // self.tableView.reloadData()
        Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("leaders").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let leaderInfo = snapshot.value as! [String : String ]
                        print(leaderInfo["userID"]!)
                        (self.sectionArrays["Signed Up"]!).append(leaderInfo["userID"]!)
                        self.leaders.append(leaderInfo["userID"]!)
                    }
                }
            }
        })
       // self.tableView.reloadData()
        //Getting RSVP-ed participants
        Constants.refs.databaseTasks.child(task!.id).child("taskRSVP").child("participants").observe(.value, with: { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot{
                        let participantInfo = snapshot.value as! [String : String ]
                        (self.sectionArrays["Signed Up"]!).append(participantInfo["userID"]!)
                        self.participants.append(participantInfo["userID"]!)
                    }

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("# of sections is "+String(self.sections.count))
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows is "+String((self.sectionArrays[sections[section]]?.count)!))
        return (self.sectionArrays[sections[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        print("The section is "+sections[section])
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! InvolvementTableViewCell
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
