//
//  StringProtocolExtension.swift
//  mScoreNew
//
//  Created by Perfect on 24/09/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import Foundation

extension StringProtocol {
    func masked(_ n: Int = 5, reversed: Bool = false) -> String {
        let mask = String(repeating: "•", count: Swift.max(0, count-n))
        return reversed ? mask + suffix(n) : prefix(n) + mask
        
//        var name = "0123456789"
//        print(name.masked(5))
//        // 01234•••••
//        print(name.masked(5, reversed: true))
//        // •••••56789
    }
    
    

}
