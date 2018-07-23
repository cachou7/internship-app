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
                    let user = User(uid: userSnap["uid"] as! String, firstName: userSnap["firstName"] as! String, lastName: userSnap["lastName"] as! String, jobTitle: userSnap["jobTitle"] as! String, department: userSnap["department"] as! String, currentProjects: userSnap["currentProjects"] as! String, points: userSnap["points"] as! Int)
                    print("User added to newUsers " + (user?.uid)!)
                    self.users.append(user!)
                    self.sortUsers()
                }
            }})
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(String(self.users.count))
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "officeCell", for: indexPath) as! OfficeLeaderboardTableViewCell
        
        let thisUser = self.users[indexPath.row]
        
        print("This user is " + thisUser.uid)
        
        cell.layer.borderWidth = 0.1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 20
        //Cell ImageView Formatting
        cell.userProfilePhoto.layer.cornerRadius = cell.userProfilePhoto.frame.size.width/2
        cell.userProfilePhoto.layer.borderWidth = 0.1
        cell.userProfilePhoto.layer.borderColor = UIColor.black.cgColor
        cell.userProfilePhoto.clipsToBounds = true
        
        cell.userProfileLink.text = thisUser.uid
        cell.userPoints.text = String(thisUser.points)
        
        let storageRef = Constants.refs.storage.child("userPhotos/\(thisUser.uid).png")
        // Load the image using SDWebImage
        SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
        cell.userProfilePhoto.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
            if let error = error {
                cell.userProfilePhoto.image = #imageLiteral(resourceName: "iconProfile")
                print("Error loading image: \(error)")
            }
            else{
                print("Successfuly loaded image")
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
    
    
}
