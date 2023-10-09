//
//  Transaction.swift
//  mScoreNew
//
//  Created by Perfect on 19/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation

struct Transaction
{
    var dates: String!
    var creditDebit:[String]!
    var narration:[String]!
    var amount:[String]!
    var expanded:Bool!
    init(dates:String,creditDebit:[String],narration:[String],amount:[String],expanded:Bool)
    {
        self.dates = dates
        self.creditDebit = creditDebit
        self.narration = narration
        self.amount = amount
        self.expanded = expanded
    }
}
