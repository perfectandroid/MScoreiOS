//
//  nextButtonInKeyboard.swift
//  mScoreNew
//
//  Created by Perfect on 11/01/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation
import UIKit

public class nextButtonInClick
{
    class func load() -> UIButton
    {
        let screenHeight = UIScreen.main.bounds.size.height
        
        mobilePadNextButton.setTitle("Next", for: UIControl.State())//Set Done here
        mobilePadNextButton.setTitleColor(UIColor.black, for: UIControl.State())
        mobilePadNextButton.frame = CGRect(x: 0, y: screenHeight - 53, width: 106, height: 53)
        mobilePadNextButton.adjustsImageWhenHighlighted = false
//        mobilePadNextButton.addTarget(self, action: #selector(self.mobilePadNextAction(_:)), for: UIControlEvents.touchUpInside)
        return mobilePadNextButton
    }
    class func ShowKeyboard(view: UIView)
    {
            DispatchQueue.main.async { () -> Void in
                mobilePadNextButton.isHidden = false
                let keyBoardWindow = UIApplication.shared.windows.last
                mobilePadNextButton.frame = CGRect(x: 0, y: (keyBoardWindow?.frame.size.height)!-53, width: 106, height: 53)
                keyBoardWindow?.addSubview(mobilePadNextButton)
                keyBoardWindow?.bringSubviewToFront(mobilePadNextButton)
                
        }
    }
    @objc class func mobilePadNextAction(_ sender : UIButton)
    {
        
    }
}

