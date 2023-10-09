//
//  Udid.swift
//  mScoreNew
//
//  Created by Perfect on 26/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation
import JNKeychain

public class udidGeneration
{
    class func udidGen() -> String
    {
        var deviceUDID = self.keychain_valueForKey("keychainDeviceUDID") as? String
        if deviceUDID == nil
        {
            deviceUDID = UIDevice.current.identifierForVendor!.uuidString
        // save new value in keychain
            self.keychain_setObject(deviceUDID! as AnyObject, forKey: "keychainDeviceUDID")
        }
        return deviceUDID!
    }
    class func keychain_setObject(_ object: AnyObject, forKey: String)
    {
        let result = JNKeychain.saveValue(object, forKey: forKey)
        if !result
        {
            print("keychain saving: something went wrong")
        }
    }

    class func keychain_valueForKey(_ key: String) -> AnyObject?
    {
        let value = JNKeychain.loadValue(forKey: key)
        return value as AnyObject?
    }
}

