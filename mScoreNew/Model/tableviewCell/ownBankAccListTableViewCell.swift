//
//  ownBankAccListTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 27/09/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class ownBankAccListTableViewCell: UITableViewCell {

    @IBOutlet weak var accNumberL: UILabel!
    @IBOutlet weak var hdOfficeL: UILabel!
    @IBOutlet weak var accBalanceL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
