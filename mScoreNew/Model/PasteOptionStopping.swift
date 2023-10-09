//
//  File.swift
//  mScoreNew
//
//  Created by Perfect on 04/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation
import UIKit  // don't forget this

class CustomUITextField: UITextField
{
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool
    {
        if action == #selector(UIResponderStandardEditActions.paste(_:))
        {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }    
}
