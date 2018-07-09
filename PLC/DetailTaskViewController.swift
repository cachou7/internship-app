//
//  DetailTaskViewController.swift
//  PLC
//
//  Created by Chris on 6/28/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class DetailTaskViewController: UIViewController {
    
    var task_in:Task!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var taskTime: UILabel!
    @IBOutlet weak var taskDescription: UILabel!
    //var titleViaSegue:String?
    @IBOutlet weak var participateLabel: UILabel!
    
    @IBOutlet weak var leadLabel: UILabel!
    @IBOutlet weak var createLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        taskTitle.text = task_in.title
        taskLocation.text = task_in.location
        taskTime.text = task_in.time
        taskDescription.text = task_in.description
        let tags = task_in.tag
        let tagArray = tags.components(separatedBy: " ")
        for tag in tagArray{
            print(tag)
            if tag == "#lead"{
                leadLabel.isEnabled = true
                leadLabel.textColor = UIColor.blue
            }
            if tag == "#create"{
                createLabel.isEnabled = true
                createLabel.textColor = UIColor.blue
            }
            if tag == "#participate"{
                participateLabel.isEnabled = true
                participateLabel.textColor = UIColor.blue
            }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
