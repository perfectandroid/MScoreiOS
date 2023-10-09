//
//  AccShareTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 08/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class AccShareTableViewCell: UITableViewCell {

    @IBOutlet weak var accHolderName: UILabel!
    @IBOutlet weak var accHolderDetails: UILabel!
    @IBOutlet weak var accSelectionCheckbox: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    

}
