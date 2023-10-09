//
//  syncNormalCalling.swift
//  mScoreNew
//
//  Created by Perfect on 04/01/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation
import UIKit

public class refreshData
{
    @objc public class func update()
    {
        var TokenNo: String = ""
        var pin: String = ""
        var customerId: String = ""
        // udid generation
        let UDID = udidGeneration.udidGen()

        // instance of encryption settings
        let instanceOfEncryption: Encryption = Encryption()
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            return
        }
        do
        {
            let fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                TokenNo = fetchedCusDetail.value(forKey: "tokenNum") as! String
                pin = fetchedCusDetail.value(forKey: "pin") as! String
                customerId = String(fetchedCusDetail.value(forKey: "customerId") as! Int)
            }
        }
        catch
        {

        }
        var encryptedAll = String()
        var encryptedPin = String()
        var encryptedCusId = String()
        var encryptedNoOfDays = String()
        do
        {
            let fetchedSettings = try coredatafunction.fetchObjectofSettings()
            for fetchedSetting in fetchedSettings
            {
                encryptedAll = instanceOfEncryption.encryptUseDES("false", key: "Agentscr") as String
                encryptedPin = instanceOfEncryption.encryptUseDES(pin, key: "Agentscr") as String
                encryptedCusId = instanceOfEncryption.encryptUseDES(customerId, key: "Agentscr") as String
                encryptedNoOfDays = instanceOfEncryption.encryptUseDES(fetchedSetting.value(forKey: "days") as? String, key: "Agentscr") as String
            }
        }
        catch
        {
            
        }
        let url = URL(string: BankIP + APIBaseUrlPart + "/SyncNormal?All=\(encryptedAll)&IDCustomer=\(encryptedCusId)&Pin=\(encryptedPin)&NoOfDays=\(encryptedNoOfDays)&imei=\(UDID)&token=\(TokenNo)")
        let session = URLSession(configuration: .default, delegate: OtpScreen(), delegateQueue: nil)
        let task = session.dataTask(with: url!) { data,response,error in
            if error != nil
            {
                return
            }
            if let datas = data
            {
                let dataInString = String(data: datas, encoding: String.Encoding.utf8)
                let responseData = dataInString?.range(of: "{\"acInfo\":null")
                if responseData == nil
                {
                    do
                    {
                        let fullDatas = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        let acInfos = fullDatas.value(forKey: "acInfo") as! [NSDictionary]
                        saveCoreData.data(acInfos, false)
                    }
                    catch
                    {
                    }
                }
                else
                {
                    // core data deleting
                    coredatafunction.delete("Accountdetails")
                    coredatafunction.delete("Customerdetails")
                    coredatafunction.delete("Transactiondetails")
                    coredatafunction.delete("Settings")
                    coredatafunction.delete("Messages")
                    UserDefaults.standard.removeObject(forKey: "LastLogin")

                }
            }
        }
        task.resume()
    }
}
