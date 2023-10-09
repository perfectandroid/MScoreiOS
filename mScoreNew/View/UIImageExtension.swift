//
//  UIImageExtension.swift
//  mScoreNew
//
//  Created by Perfect on 23/09/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation

extension UIImage {
    convenience init?(barcode: String) {
        let data = barcode.data(using: .ascii)
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        filter.setValue(data, forKey: "inputMessage")
        guard let ciImage = filter.outputImage else {
            return nil
        }
        self.init(ciImage: ciImage)
    }
    
}
