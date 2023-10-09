//
//  DropDown.swift
//  mScoreNew
//
//  Created by Perfect on 14/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation
import DropDown

public class fullAccounts
{
    class func buttonTitle() -> String
    {
        var AccNumbers = String()
        DispatchQueue.main.async{
        do
        {
            
                let fetchSet = try coredatafunction.fetchObjectofSettings()
            
           
            for setDetail in fetchSet
            {
                AccNumbers = ((setDetail.value(forKey: "accounts")! as? String)! + " (" + (setDetail.value(forKey: "accTypeShort")! as? String)! + ")")
             }
            
        }
        catch{
        }
        }
        return AccNumbers
        
    }
    class func fullAcc() -> [String]
    {
        var fullAccNumbers = [String]()
        var accountTypeShort = [String]()
        var accountType = [String]()
        
        do
        {
            let fetchAcc = try coredatafunction.fetchObjectofAcc()
            for accDetail in fetchAcc
            {
                if accDetail.value(forKey: "accTypeShort") as! String != "ML"
                {
                    
                    fullAccNumbers.append(accDetail.value(forKey: "accNum")! as! String)
                    accountTypeShort.append(accDetail.value(forKey: "accTypeShort") as! String)
                    accountType.append(accDetail.value(forKey: "accType") as! String)
                }
                
            }
        }
        catch
        {
            
        }
        let zipped = zip(fullAccNumbers, accountTypeShort)
        fullAccNumbers = zipped.map { $0.0 + " (" + $0.1 + ")"}
       return fullAccNumbers
        
    }
    class func SbCaOdAcc() -> [String]
    {
        var sbAccNumbers = [String]()
        var accountTypeShort = [String]()
        
        do
        {
            let fetchAcc = try coredatafunction.fetchObjectofAcc()
            for accDetail in fetchAcc
            {
                if accDetail.value(forKey: "accTypeShort") as! String == "SB" || accDetail.value(forKey: "accTypeShort") as! String == "CA" || accDetail.value(forKey: "accTypeShort") as! String == "OD"
                {
                    sbAccNumbers.append(accDetail.value(forKey: "accNum")! as! String)
                    accountTypeShort.append(accDetail.value(forKey: "accTypeShort") as! String)
                    
                }
                
            }
        }
        catch
        {
            
        }
        let zipped = zip(sbAccNumbers, accountTypeShort)
        sbAccNumbers = zipped.map { $0.0 + " (" + $0.1 + ")"}
        return sbAccNumbers
        
    }
    
}


