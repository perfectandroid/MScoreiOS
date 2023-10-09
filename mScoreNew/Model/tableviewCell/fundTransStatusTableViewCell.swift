//
//  fundTransStatusTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 16/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class fundTransStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var statusTypeImg: UIImageView!
    @IBOutlet weak var statusDateL: UILabel!
    @IBOutlet weak var statusTypeL: UILabel!
    @IBOutlet weak var statusBenNameL: UILabel!
    @IBOutlet weak var statusNarrationL: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
