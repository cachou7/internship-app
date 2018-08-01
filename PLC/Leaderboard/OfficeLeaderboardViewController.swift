//
//  OfficeLeaderboardViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/19/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class OfficeLeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Users Loaded From DB
        Constants.refs.databaseUsers.observe(.value, with: { snapshot in
            print(snapshot)
            
            for child in snapshot.children {
                print(child)
                if let snapshot = child as? DataSnapshot{
                    let userSnap = snapshot.value as? [String : Any ] ?? [:]
                    let user = User(uid: userSnap["uid"] as! String, firstName: userSnap["firstName"] as! String, lastName: userSnap["lastName"] as! String, jobTitle: userSnap["jobTitle"] as! String, department: userSnap["department"] as! String, currentProjects: userSnap["currentProjects"] as! String, points: userSnap["points"] as! Int, email: userSnap["email"] as! String)
                    print("User added to newUsers " + (user?.uid)!)
                    let containsUser = self.users.contains { (person) -> Bool in
                        return person.uid == user!.uid
                        }
                    if !containsUser{
                        self.users.append(user!)
                        self.sortUsers()
                    }
                    else if containsUser{
                        let index = self.users.index(where:{ $0.uid == user?.uid })
                        self.users.remove(at: index!)
                        self.users.append(user!)
                        self.sortUsers()
                    }
                    }
                }
            })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        
        for user in users{
            print(user.uid)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfSections section: Int) -> Int{
        var numOfSections: Int = 0
        if users.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No users"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "officeCell", for: indexPath) as! OfficeLeaderboardTableViewCell
        
        let thisUser = self.users[indexPath.row]

        cell.layer.borderWidth = 0.1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 20
        //Cell ImageView Formatting
        cell.userProfilePhoto.layer.cornerRadius = cell.userProfilePhoto.frame.size.width/2
        cell.userProfilePhoto.layer.borderWidth = 0.1
        cell.userProfilePhoto.layer.borderColor = UIColor.black.cgColor
        cell.userProfilePhoto.clipsToBounds = true
        
        cell.rankLabel.text = String(indexPath.row+1)
        cell.userProfileLink.text = "\(thisUser.firstName) \(thisUser.lastName)" 
        cell.userPoints.text = String(thisUser.points) + " pts"
        
        let storageRef = Constants.refs.storage.child("userPhotos/\(thisUser.uid).png")
        // Load the image using SDWebImage
        SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
        cell.userProfilePhoto.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
            if error != nil {
                cell.userProfilePhoto.image = #imageLiteral(resourceName: "iconProfile")
            }
        }
        return cell
    }
    
    // Sorts users based on points, then reload view
    func sortUsers() -> Void {
        //OVERALL
        self.users.sort(by: {$0.points > $1.points})
        //END OVERALL
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile"{
            let vc = segue.destination as! UINavigationController
            vc.navigationBar.barTintColor = UIColor(red: 189.0/255.0, green: 229.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            let destinationVC = vc.childViewControllers[0] as! ProfileViewController
            destinationVC.signOutButton.isEnabled = false
            destinationVC.signOutButton.tintColor = UIColor.clear
            destinationVC.user = self.users[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
}
