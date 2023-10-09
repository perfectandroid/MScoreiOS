//
//  StandingInstraTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 14/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class StandingInstraTableViewCell: UITableViewCell {

    @IBOutlet weak var slNo: UILabel!
    @IBOutlet weak var sourceDet: UILabel!
    @IBOutlet weak var destinationDet: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var reminder: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
