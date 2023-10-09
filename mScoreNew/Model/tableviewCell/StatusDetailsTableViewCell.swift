//
//  StatusDetailsTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 18/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class StatusDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var statDetailsHdr: UILabel!
    @IBOutlet weak var statDetailsValue: UILabel!
    @IBOutlet weak var statDetailsRsInWords: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
