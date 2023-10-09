//
//  RechargeAlertDelegate.swift
//  mScoreNew
//
//  Created by Perfect on 22/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation
protocol qpConfSuccessAlertDelegate: class {
    func qpokButtonTapped()
    func qpcancelButtonTapped()
    func qpshareButtonTapped()
    func qpShareScreenShot(_ img : UIImage, _ Share : UIButton)
    
}
