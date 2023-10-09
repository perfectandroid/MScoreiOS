//
//  extentionNSLayoutConstrain.swift
//  mScoreNew
//
//  Created by Perfect on 07/01/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint
    {
        return NSLayoutConstraint(item: self.firstItem!,
                                  attribute: self.firstAttribute,
                                  relatedBy: self.relation,
                                  toItem: self.secondItem,
                                  attribute: self.secondAttribute,
                                  multiplier: multiplier,
                                  constant: self.constant)
    }
}

