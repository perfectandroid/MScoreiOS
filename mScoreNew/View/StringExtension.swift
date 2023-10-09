//
//  StringExtension.swift
//  mScoreNew
//
//  Created by Perfect on 19/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import Foundation

extension String {
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
}
