//
//  faqTableViewCell.swift
//  mScoreNew
//
//  Created by Perfect on 30/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class ExpandingTableViewCellContent{
    var title:String?
    var descri:String?
    var expanded:Bool
    
    init(title:String, descri:String){
        self.title = title
        self.descri = descri
        self.expanded = false

    }
    
}

class faqTableViewCell: UITableViewCell {

    @IBOutlet weak var qstnLabel: UILabel!
    @IBOutlet weak var answrLabel: UILabel!
    
    @IBOutlet weak var qstnView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func set(content:ExpandingTableViewCellContent){
        self.qstnLabel.text = content.title
        self.answrLabel.text = content.expanded ? content.descri : ""
        self.contstaintUpdate()
        
    }
    
    func contstaintUpdate() {
       
        
        
        
        UIView.animate(withDuration: 0.1, delay: 0) {
            self.selectionStyle = .none
            let animate  = CABasicAnimation(keyPath: "backgroundColor")
            animate.fromValue = UIColor.white.withAlphaComponent(0.4).cgColor
            animate.toValue = UIColor.white.cgColor
            animate.duration = 1
            animate.autoreverses = true
            self.contentView.layer.add(animate, forKey: "")
            self.contentView.backgroundColor = .white
            self.layoutIfNeeded()
        }
    }

}
