//
//  Extensions.swift
//  mScoreNew
//
//  Created by Perfect on 24/09/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import Foundation
extension UISegmentedControl {
    func replaceSegments(segments: [String]) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
        }
    }
}
extension Formatter {
    static let number = NumberFormatter()
    
}
extension Locale {
    static let englishUS: Locale = .init(identifier: "en_US")
    static let frenchFR: Locale = .init(identifier: "fr_FR")
    static let portugueseBR: Locale = .init(identifier: "pt_BR")
    
    static let indianRS :  Locale = .init(identifier: "en_IN")
    // ... and so on
    
}
extension Numeric {
    func formatted(with groupingSeparator: String? = nil, style: NumberFormatter.Style, locale: Locale = .current) -> String {
        Formatter.number.locale = locale
        Formatter.number.numberStyle = style
        if let groupingSeparator = groupingSeparator {
            Formatter.number.groupingSeparator = groupingSeparator
        }
        let formattedBalance = Formatter.number.string(for: self) ?? ""
        let formattedBal = formattedBalance.replacingOccurrences(of: "-₹", with: "₹ -")
        return formattedBal
    }
    
    var currencyIN: String { formatted(style: .currency, locale: .indianRS)}
    // Localized
//    var currency:   String { formatted(style: .currency) }
    // Fixed locales
//    var currencyUS: String { formatted(style: .currency, locale: .englishUS) }
//    var currencyFR: String { formatted(style: .currency, locale: .frenchFR) }
//    var currencyBR: String { formatted(style: .currency, locale: .portugueseBR) }
    // ... and so on
//    var calculator: String { formatted(groupingSeparator: " ", style: .decimal) }
    
    
    
    func convertInWords(with groupingSeparator: String? = nil)-> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .spellOut
        var h = numberFormatter.string(for: self)

        h =  "Rupees " + String(h!) + " Only"
        return String(h!)
    }
    var InWords: String { convertInWords()}

}
