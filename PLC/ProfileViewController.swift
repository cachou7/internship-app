//
//  ProfileViewController.swift
//  PLC
//
//  Created by Chris on 6/25/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var currentProjectsLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        nameLabel.text = currentUser.firstName + " " + currentUser.lastName
        jobTitleLabel.text = "Job Title: " + currentUser.jobTitle
        departmentLabel.text = "Department: " + currentUser.department
        currentProjectsLabel.text = "Current Project(s): " + currentUser.currentProjects
        
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.borderColor = UIColor.black.cgColor
        profilePhoto.clipsToBounds = true
        
        let storageRef = Constants.refs.storage.child("userPhotos/\(currentUser.uid).png")
        // Load the image using SDWebImage
        SDImageCache.shared().removeImage(forKey: storageRef.fullPath)
        profilePhoto.sd_setImage(with: storageRef, placeholderImage: nil) { (image, error, cacheType, storageRef) in
            if let error = error {
                self.profilePhoto.image = #imageLiteral(resourceName: "iconProfile")
                print("Error loading image: \(error)")
            }
            else{
                print("Successfuly loaded image")
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
