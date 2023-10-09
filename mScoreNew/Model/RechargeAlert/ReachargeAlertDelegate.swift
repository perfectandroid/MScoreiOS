//
//  RechargeAlertDelegate.swift
//  mScoreNew
//
//  Created by Perfect on 22/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation
protocol RechargeAlertDelegate: class {
    func prePaidButtonTapped()
    func dthButtonTapped()
    func landLineButtonTapped()
    func postPaidButtonTapped()
    func dataCardButtonTapped()
    func ksebButtonTapped()
    func rechargeHistoryButtonTapped()
    func cancelButtonTapped()

}
