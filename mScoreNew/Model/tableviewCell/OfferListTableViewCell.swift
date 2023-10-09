//
//  OfferListTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 26/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class OfferListTableViewCell: UITableViewCell {

    @IBOutlet weak var validityLbl: UILabel!
    @IBOutlet weak var offerDescriptionL: UILabel!
    @IBOutlet weak var amount: UIButton!{
        didSet {
            amount.btnWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
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
