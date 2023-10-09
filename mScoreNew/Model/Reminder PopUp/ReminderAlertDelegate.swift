//
//  RechargeAlertDelegate.swift
//  mScoreNew
//
//  Created by Perfect on 22/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation
protocol ReminderAlertDelegate: class {
    func dateButtonTapped()
    func timeButtonTapped()
    func noteButtonTapped()
    func submitButtonTapped()
    func cancelButtonTapped()
}
