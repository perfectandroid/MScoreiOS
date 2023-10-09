//
//  BranchListTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 21/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class BranchListTableViewCell: UITableViewCell {

    @IBOutlet weak var bankImg: UIImageView!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var bankAddress: UILabel!
    @IBOutlet weak var bankNum: UILabel!
    @IBOutlet weak var bankWorkingHr: UILabel!
    @IBOutlet weak var nextImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
