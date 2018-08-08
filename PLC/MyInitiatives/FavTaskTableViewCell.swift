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
    
    // Set key to currentUser
    let key = currentUser.uid
    weak var delegate: FavTaskTableViewCellDelegate?
    
    // MARK: OUTLETS
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
    
    // Set up clickable heart button
    @IBAction func heartButton(_ sender: UIButton) {
        delegate?.favTaskTableViewCellDidTapHeart(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// Set up delegate for when user clicks on heart in cell
protocol FavTaskTableViewCellDelegate : class {
    func favTaskTableViewCellDidTapHeart(_ sender: FavTaskTableViewCell)
}
