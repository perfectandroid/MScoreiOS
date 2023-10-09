//
//  DateExtension.swift
//  mScoreNew
//
//  Created by Perfect on 17/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation

extension Date{
    func currentDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func formattedDateFromString(dateString: String, ipFormatter:  String, opFormatter : String) -> String?
    {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = ipFormatter
        if let date = inputFormatter.date(from: dateString)
        {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = opFormatter
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
//    func startOfMonth() -> Date {
//        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
//    }
    
//    func endOfMonth() -> Date {
//        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
//    }
    
    func startOfMonth(_ dateFormat : String, _ SeleDate : Date) -> String {
        let dateFormatter = DateFormatter()
        let date = SeleDate
            dateFormatter.dateFormat = dateFormat
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
        let startOfMonth = Calendar.current.date(from: comp)!
        return dateFormatter.string(from: startOfMonth)
    }
    
    
    
    func endOfMonth(_ dateFormat : String, _ SeleDate : Date) -> String {
        let dateFormatter = DateFormatter()
        let date = SeleDate
            dateFormatter.dateFormat = dateFormat
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
        let startOfMonth = Calendar.current.date(from: comp)!
        var comps2 = DateComponents()
            comps2.month = 1
            comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)
        return dateFormatter.string(from: endOfMonth!)
    }
    
    

}
