//
//  TaskTableViewCell.swift
//  PLC
//
//  Created by Chris on 6/26/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var taskTime: UILabel!
    @IBOutlet weak var taskTag: UILabel!
    @IBOutlet weak var taskLiked: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func heartButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if (sender.isSelected) {
            let likedIcon = UIImage(named: "redHeart")
            taskLiked.setImage(likedIcon, for: .normal)
            
        }
        else {
            let unlikedIcon = UIImage(named: "heartIcon")
            taskLiked.setImage(unlikedIcon, for: .normal)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
