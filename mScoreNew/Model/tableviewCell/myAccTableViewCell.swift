//
//  accSummaryTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 05/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class myAccTableViewCell: UITableViewCell {
    @IBOutlet weak var myAccTypeL: UILabel!
    @IBOutlet weak var myAccNoDetailL: UILabel!
    @IBOutlet weak var myAccBalanceL: UILabel!
    @IBOutlet weak var myAccTypeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
