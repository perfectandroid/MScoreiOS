//
//  buttonExtension.swift
//  mScoreNew
//
//  Created by Perfect on 09/12/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation

//class CheckBox: UIButton {
//    // Images
//    let checkedImage = #imageLiteral(resourceName: "tick")
//    let uncheckedImage = #imageLiteral(resourceName: "PIN1")
//    
//    // Bool property
//    var isChecked: Bool = false {
//        didSet {
//            if isChecked == false {
//                self.setImage(uncheckedImage, for: UIControl.State.normal)
//            } else {
//                self.setImage(checkedImage, for: UIControl.State.normal)
//            }
//        }
//    }
//        
//    override func awakeFromNib() {
//        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
//        self.isChecked = false
//    }
//        
//    @objc func buttonClicked(sender: UIButton) {
//        if sender == self {
//            isChecked = !isChecked
//        }
//    }
//}
extension UIButton{
    func buttonUnderLineblack(){
        let lineView = UIView(frame: CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 2))
        lineView.backgroundColor =  UIColor.black
        self.addSubview(lineView)
    }
    func curvedButtonWithBorder(_ borderColor : CGColor){
        self.backgroundColor = .clear
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor
    }
    
    func btnWithBorder(_ borderColor : CGColor){
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor
    }
    func buttonUnderLineColor(_ color: UIColor){
        let lineView = UIView(frame: CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 2))
        lineView.backgroundColor =  color
        self.addSubview(lineView)
    }
    
    
}
