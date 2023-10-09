//
//  NoticeTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 17/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var noticeTypeName: UILabel!
    @IBOutlet weak var accType: UILabel!
    @IBOutlet weak var accNumber: UILabel!
    @IBOutlet weak var noticeDate: UILabel!
    @IBOutlet weak var dueAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
