//
//  UIScrollViewExtension.swift
//  mScoreNew
//
//  Created by Perfect on 25/11/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import Foundation
import UIKit


extension UIScrollView {
    func resizeScrollViewContentSize() {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        self.contentSize = contentRect.size
    }
}
