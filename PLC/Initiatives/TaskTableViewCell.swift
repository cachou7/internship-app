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
    
    //MARK: Properties
    let key = currentUser.uid
    weak var delegate: TaskTableViewCellDelegate?
    
    @IBOutlet weak var taskSecondIcon: UIImageView!
    @IBOutlet weak var taskFirstIcon: UIImageView!
    @IBOutlet weak var taskCategory: UIButton!
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLiked: UIButton!
    @IBOutlet weak var taskTime: UILabel!
    @IBOutlet weak var taskNumberOfLikes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    //MARK: Actions
    @IBAction func heartButton(_ sender: UIButton) {
        delegate?.taskTableViewCellDidTapHeart(self)
    }
    
    @IBAction func categoryButton(_ sender: UIButton) {
        delegate?.taskTableViewCellCategoryButtonClicked(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}

protocol TaskTableViewCellDelegate : class {
    func taskTableViewCellDidTapHeart(_ sender: TaskTableViewCell)
    func taskTableViewCellCategoryButtonClicked(_ sender: TaskTableViewCell)
}



