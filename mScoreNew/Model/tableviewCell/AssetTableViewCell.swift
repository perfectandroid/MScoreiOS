//
//  AssetTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 28/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class AssetTableViewCell: UITableViewCell {

    
    @IBOutlet weak var assetImg: UIImageView!
    @IBOutlet weak var assetLbl: UILabel!
    
    @IBOutlet weak var proView: UIProgressView!
    @IBOutlet weak var percentageView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
