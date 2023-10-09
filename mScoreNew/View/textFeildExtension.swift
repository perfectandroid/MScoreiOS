//
//  textFeildBottomBorder.swift
//  mScoreNew
//
//  Created by Perfect on 13/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation

extension UITextField
{
    func setBottomBorder(_ color:UIColor, _ ht:Double)
    {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        
        self.layer.shadowOffset = CGSize(width: 0.0, height: ht)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}


