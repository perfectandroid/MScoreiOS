//
//  recentRechListTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 28/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class recentRechListTableViewCell: UITableViewCell {

    @IBOutlet weak var recentOperatorL: UILabel!
    @IBOutlet weak var recentNumberL: UILabel!
    @IBOutlet weak var recentDateStatusL: UILabel!
    @IBOutlet weak var recentAmountL: UIButton!{
        didSet{
            recentAmountL.btnWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
