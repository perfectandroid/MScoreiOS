//
//  extentionUIView.swift
//  mScoreNew
//
//  Created by Perfect on 09/01/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation

extension UIView
{
    func roundCorners(_ radius: CGFloat,_ corners: UIRectCorner)
    {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    func screenShot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
            let contextRef = UIGraphicsGetCurrentContext()
        contextRef!.translateBy(x: 0, y: 0)
        layer.render(in: contextRef!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        return image!
    }
    func viewBorder(_ borderColor : CGColor) {
        self.layer.cornerRadius = 5
        self.clipsToBounds      = true
        self.layer.borderColor  = borderColor
        self.layer.borderWidth  = 1.0
    }

}
