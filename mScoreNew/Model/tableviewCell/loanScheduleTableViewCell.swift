//
//  loanScheduleTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 13/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class loanScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var slNoL: UILabel!
    @IBOutlet weak var periodL: UILabel!
    @IBOutlet weak var demandL: UILabel!
    @IBOutlet weak var principalL: UILabel!
    @IBOutlet weak var interestL: UILabel!
    @IBOutlet weak var totalL: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
