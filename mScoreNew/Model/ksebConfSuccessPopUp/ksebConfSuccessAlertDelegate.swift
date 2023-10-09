//
//  RechargeAlertDelegate.swift
//  mScoreNew
//
//  Created by Perfect on 22/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation
protocol ksebConfSuccessAlertDelegate: class {
    func okButtonTapped()
    func cancelButtonTapped()
    func shareButtonTapped()
    func ShareScreenShot(_ img : UIImage, _ Share : UIButton)
    
}
