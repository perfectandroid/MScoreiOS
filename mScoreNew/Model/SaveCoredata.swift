//
//  SaveCoredata.swift
//  mScoreNew
//
//  Created by Perfect on 22/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation

public class saveCoreData
{
    class func data (_ Response: [NSDictionary], _ otpIsSelected: Bool)
    {
        // core data deleting
        if otpIsSelected == true
        {
            coredatafunction.delete("Accountdetails")
            coredatafunction.delete("Customerdetails")
            coredatafunction.delete("Transactiondetails")
            coredatafunction.delete("Settings")
            coredatafunction.delete("Messages")
            
        }
        else
        {
            coredatafunction.delete("Accountdetails")
            coredatafunction.delete("Customerdetails")
            coredatafunction.delete("Transactiondetails")
            coredatafunction.delete("Messages")
            
        }
        
        let acInfos = Response
        for acInfo in acInfos
        {
            let customerId1 = acInfo.value(forKey: "customerId") as! Int
            let customerNo2 = acInfo.value(forKey: "customerNo") as! String
            let customerName3 = acInfo.value(forKey: "customerName") as! String
            let customerAddress1a = acInfo.value(forKey: "customerAddress1") as! String
            let customerAddress2b = acInfo.value(forKey: "customerAddress2") as! String
            let customerAddress3c = acInfo.value(forKey: "customerAddress3") as! String
            let mobileNo4 = acInfo.value(forKey: "mobileNo") as! String
            let pin5 = acInfo.value(forKey: "pin") as! String
            let default1 = acInfo.value(forKey: "default1") as! NSNull
            let login6 = acInfo.value(forKey: "login") as! Int
            let TokenNo7 = acInfo.value(forKey: "TokenNo") as! String
            let DMenu8 = acInfo.value(forKey: "DMenu") as! String
            let accounts9 = acInfo.value(forKey: "accounts") as! [NSDictionary]
            for acc in accounts9
            {
                let account1 = acc.value(forKey: "account") as! Int
                let demandDeposit_id2 = acc.value(forKey: "demandDeposit_id") as! Int
                let acno3 = acc.value(forKey: "acno") as! String
                let lastacessdate4 = acc.value(forKey: "lastacessdate") as! String
                let module5 = acc.value(forKey: "module") as! String
                let acType6 = acc.value(forKey: "acType") as! String
                let typeShort7 = acc.value(forKey: "typeShort") as! String
                let branchCode8 = acc.value(forKey: "branchCode") as! String
                let branchName9 = acc.value(forKey: "branchName") as! String
                let branchShort0 = acc.value(forKey: "branchShort") as! String
                let depositDate01 = acc.value(forKey: "depositDate") as! String
                let oppmode02 = acc.value(forKey: "oppmode") as! String
                let FK_CustomerID03 = acc.value(forKey: "FK_CustomerID") as! String
                let AvailableBal04 = acc.value(forKey: "AvailableBal") as! Double
                let UnClrBal05 = acc.value(forKey: "UnClrBal") as! Double
                let transactions06 = acc.value(forKey: "transactions") as! [NSDictionary]
                for transactiondetail in transactions06
                {
                    let transaction1 = transactiondetail.value(forKey: "transaction") as! Int
                    let fk_DemandDeposit2 = transactiondetail.value(forKey: "fk_DemandDeposit") as! String
                    let effectDate3 = transactiondetail.value(forKey: "effectDate") as! String
                    let amount4 = transactiondetail.value(forKey: "amount") as! String
                    let chequeNo5 = transactiondetail.value(forKey: "chequeNo") as! String
                    let chequeDate6 = transactiondetail.value(forKey: "chequeDate") as! String
                    let narration7 = transactiondetail.value(forKey: "narration") as! String
                    let transType8 = transactiondetail.value(forKey: "transType") as! String
                    let remarks9 = transactiondetail.value(forKey: "remarks") as! String
                    let OpeningBal0 = transactiondetail.value(forKey: "OpeningBal") as! NSNull
                    
                    coredatafunction.transDetails(accnum: acno3, transaction: transaction1, fk_DemandDeposit: fk_DemandDeposit2, effectDate: effectDate3, amount: amount4, chequeNo: chequeNo5, chequeDate: chequeDate6, narration: narration7, transType: transType8, remarks: remarks9, OpeningBal: OpeningBal0)
                }
                coredatafunction.accDetails(account: account1, demandDeposit_id: demandDeposit_id2, acno: acno3, lastacessdate: lastacessdate4, module: module5, acType: acType6, typeShort: typeShort7, branchCode: branchCode8, branchName: branchName9, branchShort: branchShort0, depositDate: depositDate01, oppmode: oppmode02, FK_CustomerID: FK_CustomerID03, AvailableBal: Float32(AvailableBal04), UnClrBal: Float32(UnClrBal05))

            }
            coredatafunction.cusDetails(customerId: customerId1, customerNo: customerNo2, customerName: customerName3, customerAddress1: customerAddress1a, customerAddress2: customerAddress2b, customerAddress3: customerAddress3c, mobileNo: mobileNo4, pin: pin5, default1s: default1, login: login6, TokenNo: TokenNo7, DMenu: DMenu8)
            let msgs = acInfo.value(forKey: "Messages") as! [NSDictionary]
            for msg in msgs
            {
                let msgType = msg.value(forKey: "messageType") as! Int
                let msgDate = msg.value(forKey: "messageDate") as! String
                let msgHead = msg.value(forKey: "messageHead") as! String
                let msgDetails = msg.value(forKey: "messageDetail") as! String
                
                coredatafunction.messagesData(type: msgType, date: msgDate, head: msgHead, detail: msgDetails)
            }
        }
//        if otpIsSelected == true
//        {
//            let acc = fullAccounts.fullAcc()[0]
//            // selected acc module settings
//            var module = acc.components(separatedBy: CharacterSet.decimalDigits).joined()
//            module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
//            module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
//            let oneAcc = String(acc.dropLast(5))
//            coredatafunction.settingsDetails(acc: oneAcc, accTypeShort: module, days: "30", hr: "12", min: "0")
//        }
    }
}
