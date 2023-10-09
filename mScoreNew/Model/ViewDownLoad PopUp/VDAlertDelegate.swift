//
//  RechargeAlertDelegate.swift
//  mScoreNew
//
//  Created by Perfect on 22/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation
protocol VDAlertDelegate: AnyObject {
    func refresh(_ monDat : Int,_ FromDate: String, _ ToDate : String,  _ DFromDate: String,_ DToDate : String)

    func VDButtonTapped()
    func cancelButtonTapped()
}
