//
//  FavTaskTableViewCell.swift
//  PLC
//
//  Created by Chris on 7/18/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import Firebase

class FavTaskTableViewCell: UITableViewCell {
    
    let key = currentUser.uid
    weak var delegate: FavTaskTableViewCellDelegate?
    
    
    @IBOutlet weak var taskCategoryIcon: UIImageView!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var taskCategory: UILabel!
    @IBOutlet weak var taskLiked: UIButton!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func heartButton(_ sender: UIButton) {
        
        delegate?.favTaskTableViewCellDidTapHeart(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

protocol FavTaskTableViewCellDelegate : class {
    func favTaskTableViewCellDidTapHeart(_ sender: FavTaskTableViewCell)
}
