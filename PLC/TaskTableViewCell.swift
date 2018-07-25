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
    
    let key = currentUser.uid
    weak var delegate: TaskTableViewCellDelegate?
    
    
    
    @IBOutlet weak var taskParticipantPoints: UILabel!
    @IBOutlet weak var taskLeaderPoints: UILabel!
    @IBOutlet weak var taskCategory: UILabel!
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskCategoryIcon: UIImageView!
    @IBOutlet weak var taskSecondPoints: UILabel!
    @IBOutlet weak var taskSecondIcon: UIImageView!
    @IBOutlet weak var taskFirstPoints: UILabel!
    @IBOutlet weak var taskFirstIcon: UIImageView!
    @IBOutlet weak var taskMonth: UILabel!
    @IBOutlet weak var taskDay: UILabel!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLiked: UIButton!
    @IBOutlet weak var taskTime: UILabel!
    @IBOutlet weak var taskNumberOfLikes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func heartButton(_ sender: UIButton) {
        
        delegate?.taskTableViewCellDidTapHeart(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

protocol TaskTableViewCellDelegate : class {
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell)
}
