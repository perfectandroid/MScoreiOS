//
//  ConfigurationClass.swift
//  mScoreNew
//
//  Created by Perfect on 17/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation
class Configuration {
    // write
    static func writeAnyData(key: String, value: Any){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    // read int values
    static func readIntData(key: String) -> Int{
        if UserDefaults.standard.object(forKey: key) == nil {
            return 0
        } else {
            return UserDefaults.standard.integer(forKey: key)
        }
    }
    
    // read string values
    static func readStringData(key: String) -> String{
        if UserDefaults.standard.object(forKey: key) == nil {
            return ""
        } else {
            return UserDefaults.standard.string(forKey: key)!
        }
    }
    // read bool value
    static func readBoolData(key: String) -> Bool{
        if UserDefaults.standard.object(forKey: key) == nil {
            return false
        } else {
            return UserDefaults.standard.bool(forKey: key)
        }
    }
}
