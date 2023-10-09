//
//  shareTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 08/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class shareTableViewCell: UITableViewCell {
    
    @IBOutlet weak var benName: UILabel!
    @IBOutlet weak var benDetails: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
