//
//  Coredata.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class coredatafunction: NSObject
{
    fileprivate class func getcontext()-> NSManagedObjectContext
    {
        
    
       
        let delegate = UIApplication.shared.delegate as! AppDelegate
       
        
        
        return delegate.databaseContext
//        return delegate.persistentContainer.viewContext
    }
    class func messagesData(type:Int, date:String, head: String, detail:String)
    {
        DispatchQueue.main.async {
            let context = getcontext()
        
            let entity = NSEntityDescription.entity(forEntityName: "Messages", in: context)
            let object = NSManagedObject(entity: entity!, insertInto: context)
                object.setValue(type, forKey: "messagType")
                object.setValue(date, forKey: "messagDate")
                object.setValue(head, forKey: "messagHead")
                object.setValue(detail, forKey: "messagDetail")
            
            do
            {
                try context.save()

            }
            catch
            {
                print("Message saving fail")
            }
        }
       
    }
    class func fetchObjectofMessage() throws -> [Messages]
    {
        let context = getcontext()
        return try context.fetch(Messages.fetchRequest())
    }
    
    
    class func imageData(custPhoto:String)
    {
        let context = getcontext()
        let entity = NSEntityDescription.entity(forEntityName: "CustomerPhoto", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context)
        object.setValue(custPhoto, forKey: "custPhoto")
        
        do
        {
            try context.save()
            
        }
        catch
        {
            print("Message saving fail")
        }
    }
    class func fetchObjectofImage() throws -> [CustomerPhoto]
    {
        let context = getcontext()
        return try context.fetch(CustomerPhoto.fetchRequest())
    }
    
    
    
    
    
    
    
    
    
    class func settingsDetails(acc: String, accTypeShort:String, days: String, hr:String, min:String)
    {
        let context = getcontext()
        let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context)
        object.setValue(acc, forKey: "accounts")
        object.setValue(accTypeShort, forKey: "accTypeShort")
        object.setValue(days, forKey: "days")
        object.setValue(hr, forKey: "hours")
        object.setValue(min, forKey: "minutes")
        do
        {
            try context.save()
        }
        catch
        {
            print("Settings saving fail")
        }
    }
    class func fetchObjectofSettings() throws -> [Settings]
    {
        let context = getcontext()
        return try context.fetch(Settings.fetchRequest())
    }
    class func cusDetails(customerId:Int,customerNo:String,customerName:String,customerAddress1:String,customerAddress2:String,customerAddress3:String,mobileNo:String,pin:String,default1s:NSNull,login:Int,TokenNo:String,DMenu:String)
    {
        let context = getcontext()
        let entity = NSEntityDescription.entity(forEntityName: "Customerdetails", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context)
        object.setValue(customerId, forKey: "customerId")
        object.setValue(customerNo, forKey: "customerNum")
        object.setValue(customerName, forKey: "name")
        object.setValue(customerAddress1, forKey: "address1")
        object.setValue(customerAddress2, forKey: "address2")
        object.setValue(customerAddress3, forKey: "address3")
        object.setValue(mobileNo, forKey: "mobileNum")
        object.setValue(pin, forKey: "pin")
        object.setValue(default1s, forKey: "defaults")
        object.setValue(login, forKey: "login")
        object.setValue(TokenNo, forKey: "tokenNum")
        object.setValue(DMenu, forKey: "dMenu")
        do
        {
            try context.save()

        }
        catch
        {
            print("Customerdetails saving fail")
        }
    }
    class func fetchObjectofCus() throws -> [Customerdetails]
    {
        let context = getcontext()
        return try context.fetch(Customerdetails.fetchRequest())
    }

    class func accDetails (account:Int,demandDeposit_id:Int,acno:String,lastacessdate:String,module:String,acType:String,typeShort:String,branchCode:String,branchName:String,branchShort:String,depositDate:String,oppmode:String,FK_CustomerID:String,AvailableBal:Float32,UnClrBal:Float32)
    {
        let context = getcontext()
        let entity = NSEntityDescription.entity(forEntityName: "Accountdetails", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context)
        object.setValue(account, forKey: "acc")
        object.setValue(demandDeposit_id, forKey: "depositId")
        object.setValue(acno, forKey: "accNum")
        object.setValue(lastacessdate, forKey: "lastAcessDate")
        object.setValue(module, forKey: "module")
        object.setValue(acType, forKey: "accType")
        object.setValue(typeShort, forKey: "accTypeShort")
        object.setValue(branchCode, forKey: "codeOfBranch")
        object.setValue(branchName, forKey: "branch")
        object.setValue(branchShort, forKey: "branchCodeShort")
        object.setValue(depositDate, forKey: "dateOfDeposit")
        object.setValue(oppmode, forKey: "oppMode")
        object.setValue(FK_CustomerID, forKey: "fkCustomerId")
        object.setValue(AvailableBal, forKey: "availableBalance")
        object.setValue(UnClrBal, forKey: "unClearBalance")
        do
        {
            try context.save()

        }
        catch
        {
            print("Accountdetails saving fail")
        }
    }
    class func fetchObjectofAcc() throws -> [Accountdetails]
    {
        let context = getcontext()        
        return try context.fetch(Accountdetails.fetchRequest())
    }

    class func transDetails(accnum:String,transaction:Int,fk_DemandDeposit:String,effectDate:String,amount:String,chequeNo:String,chequeDate:String,narration:String,transType:String,remarks:String,OpeningBal:NSNull)
    {
        let context = getcontext()
        let entity = NSEntityDescription.entity(forEntityName: "Transactiondetails", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context)
        object.setValue(accnum, forKey: "accNum")
        object.setValue(transaction, forKey: "transactionId")
        object.setValue(fk_DemandDeposit, forKey: "fkDemandDeposit")
        object.setValue(effectDate, forKey: "effectDate")
        object.setValue(amount, forKey: "amount")
        object.setValue(chequeNo, forKey: "chequeNum")
        object.setValue(chequeDate, forKey: "dateOfCheque")
        object.setValue(narration, forKey: "narration")
        object.setValue(transType, forKey: "transactionType")
        object.setValue(remarks, forKey: "remark")
        object.setValue(OpeningBal, forKey: "openingBalance")

        do
        {
            try context.save()

        }
        catch
        {
            print("Transactiondetails saving fail")
        }
    }
    class func fetchObjectofTrans() throws -> [Transactiondetails]
    {
        let context = getcontext()
        return try context.fetch(Transactiondetails.fetchRequest())
    }
    
    class func newPin(_ newPin:String)
    {
        let context = getcontext()
        let use = try! fetchObjectofCus()
        for one in use
        {
            one.pin = newPin as NSObject
        }
        do
        {
            try context.save()
        }
        catch
        {
            print("saving fail")
        }
    }
    class func settingsUpdate(_ newAcc:String, _ newAccTypeShort:String, _ newDate:String, _ newHr:String, _ newMin:String)
    {
        let context = getcontext()
        let setUpdate = try! fetchObjectofSettings()
        for one in setUpdate
        {
            one.accounts = newAcc as NSObject
            one.accTypeShort = newAccTypeShort as NSObject
            one.days = newDate as NSObject
            one.hours = newHr as NSObject
            one.minutes = newMin as NSObject
            
        }
        do
        {
            try context.save()

        }
        catch
        {
            print("saving fail")
        }
    }
    class func delete(_ entity: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let context = getcontext()
            let results = try context.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                context.delete(managedObjectData)
            }
            do
            {
                try context.save()

            }
            catch
            {
            }
        }
        catch let error as NSError
        {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
}
