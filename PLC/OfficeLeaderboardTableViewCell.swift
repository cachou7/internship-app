//
//  OfficeLeaderboardTableViewCell.swift
//  PLC
//
//  Created by Connor Eschrich on 7/23/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class OfficeLeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfilePhoto: UIImageView!
    @IBOutlet weak var userProfileLink: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
