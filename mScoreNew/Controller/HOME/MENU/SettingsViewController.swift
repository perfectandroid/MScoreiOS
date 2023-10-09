//
//  SettingsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 26/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import DropDown

class SettingsViewController: UIViewController,URLSessionDelegate
{
    
    @IBOutlet weak var accounts : UIButton!
    @IBOutlet weak var hour     : UIButton!
    @IBOutlet weak var min      : UIButton!
    @IBOutlet weak var days     : UIButton!
    @IBOutlet weak var curlView : UIView!
    
    @IBOutlet weak var blurView         : UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var settingsViewConstraint: NSLayoutConstraint!
    
    var transDate = ["7","10","14","30","60","120","150","180"]
    var updateIntH = updationHour
    var updateIntM = ["00","15","30","45"]
    var dayDrop = DropDown()
    lazy var daysDropDowns: [DropDown] = {
        return[
            self.dayDrop]
    } ()
    var hrDrop = DropDown()
    lazy var hrDropDowns: [DropDown] = {
        return[
            self.hrDrop]
    } ()
    var minDrop = DropDown()
    lazy var minDropDowns: [DropDown] = {
        return[
            self.minDrop]
    } ()
    var accDrop = DropDown()
    lazy var accDropDowns: [DropDown] = {
        return[
            self.accDrop]
    } ()
    // instance of encryption settings
    var instanceOfEncryption: Encryption = Encryption()
    
    // for fetch settings detail
    var fetchedSettings:[Settings] = []

    // set var for pass data in the time of segue
    var TokenNo = String()
    var customerId = String()
    var pin = String()
    
    var OwnAccountdetailsList   = [NSDictionary]()
    var AccountdetailsList      = [String]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // udid generation
        UDID = udidGeneration.udidGen()
        
        cardView(curlView)

        daysDropDowns.forEach { $0.dismissMode = .onTap }
        daysDropDowns.forEach { $0.direction = .any }
        setDayDropDown()
        days.setTitle(transDate[3], for: .normal)
        
        hrDropDowns.forEach { $0.dismissMode = .onTap }
        hrDropDowns.forEach { $0.direction = .any }
        setHrDropDown()
        hour.setTitle(updateIntH[11], for: .normal)
        
        minDropDowns.forEach { $0.dismissMode = .onTap }
        minDropDowns.forEach { $0.direction = .any }
        setMinDropDown()
        min.setTitle(updateIntM[0], for: .normal)
        
        accDropDowns.forEach { $0.dismissMode = .onTap }
        accDropDowns.forEach { $0.direction = .any }
//        setAccDropDown()
        accounts.setTitle(fullAccounts.buttonTitle(), for: .normal)

        blurView.isHidden = true
        accBtnAction(sender: accounts)
        OwnAccounDetails()
    }
    
    func OwnAccounDetails() {
        // network reachability checking
        
        self.blurView.isHidden = false
        self.activityIndicator.startAnimating()
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.blurView.isHidden = true
                self?.activityIndicator.stopAnimating()
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/OwnAccounDetails")!
//        let encryptedReqMode    = instanceOfEncryptionPost.encryptUseDES("13", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
//        let encryptedSubMode    = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
        
        let reqmode = "13"
        let token = "\(TokenNo)"
        let custId = "\(customerId)"
        let subMode = "1"
        let jsonDict            = ["ReqMode" : reqmode,
                                   "Token" : token,
                                   "FK_Customer" : custId ,
                                   "SubMode" : subMode,
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]
        
        print(jsonDict)
        
        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
        let task = session.dataTask(with: request) { [self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { [weak self] in
                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self?.blurView.isHidden = true
                    self?.activityIndicator.stopAnimating()
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    
                        // alert message for check expiry date of the bill
                    DispatchQueue.main.async { [weak self] in
                        self!.blurView.isHidden = true
                        self!.activityIndicator.stopAnimating()
                    }
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
                        OwnAccountdetailsList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as! [NSDictionary]
                        for Accountdetails in OwnAccountdetailsList {
                            AccountdetailsList.append(Accountdetails.value(forKey: "AccountNumber") as! String)
                        }
                        DispatchQueue.main.async { [weak self] in
                            self!.setAccDropDown()
                        }
                    }
                    else {
                        
                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as Any
                        if OwnAccountdetails as? String != nil {
                                let OwnAccountdetail  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
                            let ResponseMessage =  OwnAccountdetail.value(forKey: "ResponseMessage") as! String

                            DispatchQueue.main.async { [weak self] in
                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
                            }
                        }
                        else {
                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String

                            DispatchQueue.main.async { [weak self] in
                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
                            }
                        }
                    }
                }
                catch{
                    
                        // alert message for check expiry date of the bill
                    DispatchQueue.main.async { [weak self] in
                        self!.blurView.isHidden = true
                        self!.activityIndicator.stopAnimating()
                    }
                }
            }
            else{
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
                }
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setDayDropDown()
    {
        dayDrop.anchorView = days
        dayDrop.bottomOffset = CGPoint(x:0, y:30)
        dayDrop.dataSource = transDate
        dayDrop.backgroundColor = UIColor.white
        dayDrop.selectionAction = {[weak self] (index, item) in
            self?.days.setTitle(item, for: .normal)
        }
    }
    func setHrDropDown()
    {
        hrDrop.anchorView = hour
        hrDrop.bottomOffset = CGPoint(x:0, y:30)
        hrDrop.dataSource = updateIntH
        hrDrop.backgroundColor = UIColor.white
        hrDrop.selectionAction = {[weak self] (index, item) in
            self?.hour.setTitle(item, for: .normal)
        }
    }
    func setMinDropDown()
    {
        minDrop.anchorView = min
        minDrop.bottomOffset = CGPoint(x:0, y:30)
        minDrop.dataSource = updateIntM
        minDrop.backgroundColor = UIColor.white
        minDrop.selectionAction = {[weak self] (index, item) in
            self?.min.setTitle(item, for: .normal)
        }
    }
    func setAccDropDown()
    {
        accDrop.anchorView      = accounts
        accDrop.bottomOffset    = CGPoint(x:0, y:30)
        accDrop.dataSource      = AccountdetailsList
        accDrop.backgroundColor = UIColor.white
        accDrop.selectionAction = {[weak self] (index, item) in
            self?.accounts.setTitle(item, for: .normal)
//            self?.accBtnAction(sender: (self?.accounts)!)
        }
    }
    
    @IBAction func Back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dayAction(_ sender: UIButton) {
        dayDrop.show()
    }
    
    @IBAction func hrAction(_ sender: UIButton) {
        hrDrop.show()
    }
    
    @IBAction func minAction(_ sender: UIButton) {
        minDrop.show()
    }
    
    @IBAction func accAction(_ sender: UIButton) {
        accDrop.show()
    }
    
    @IBAction func settingsApply(_ sender: UIButton)
    {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        let acc = accounts.currentTitle!
        let oneAcc = String(acc.dropLast(5))

        var module = acc.components(separatedBy: CharacterSet.decimalDigits).joined()
            module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
            module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)

        blurView.isHidden = false
        activityIndicator.startAnimating()
        
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.blurView.isHidden = true
           // saveCoreData.data(acInfos, false)
            coredatafunction.settingsUpdate(oneAcc,
                                            module,
                                            (self?.days.currentTitle!)!,
                                            (self?.hour.currentTitle!)!,
                                            (self?.min.currentTitle!)!)
            self?.performSegue(withIdentifier: "toHomeScreen", sender: self)
        }
    
//        let encryptedAll = instanceOfEncryption.encryptUseDES("true", key: "Agentscr") as String
//        let encryptedCusId = instanceOfEncryption.encryptUseDES(customerId, key: "Agentscr") as String
//        let encryptedPin = instanceOfEncryption.encryptUseDES(pin, key: "Agentscr") as String
//
//        let encryptedNoOfDays = instanceOfEncryption.encryptUseDES(days.currentTitle!, key: "Agentscr") as String
//
//       let url = URL(string: BankIP + APIBaseUrlPart + "/SyncNormal?All=\(encryptedAll)&IDCustomer=\(encryptedCusId)&Pin=\(encryptedPin)&NoOfDays=\(encryptedNoOfDays)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//        let task = session.dataTask(with: url!) { data,response,error in
//            if error != nil
//            {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                }
//                return
//            }
//            if let datas = data
//            {
//                let dataInString = String(data: datas, encoding: String.Encoding.utf8)
//                let responseData = dataInString?.range(of: "{\"acInfo\":null")
//                if responseData == nil
//                {
//                    do
//                    {
//                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
//                        let acInfos = data1.value(forKey: "acInfo") as? [NSDictionary] ?? []
//
//                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
//                            saveCoreData.data(acInfos, false)
//                            coredatafunction.settingsUpdate(oneAcc,
//                                                            module,
//                                                            (self?.days.currentTitle!)!,
//                                                            (self?.hour.currentTitle!)!,
//                                                            (self?.min.currentTitle!)!)
//                            self?.performSegue(withIdentifier: "toHomeScreen", sender: self)
//                        }
//                    }
//                    catch
//                    {
//                        DispatchQueue.main.async{
//                            self.blurView.isHidden = true
//                            self.activityIndicator.stopAnimating()
//                        }
//                    }
//                }
//                else
//                {
//                    DispatchQueue.main.async { [weak self] in
//                        self?.present(messages.msg("Error occurred"), animated: true, completion: nil)
//                        self?.activityIndicator.stopAnimating()
//                        self?.blurView.isHidden = true
//                    }
//                }
//            }
//        }
//        task.resume()
    }
   
    func accBtnAction(sender: UIButton)
    {
        let acc = sender.currentTitle!
        // selected acc module settings
        var module = acc.components(separatedBy: CharacterSet.decimalDigits).joined()
        module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
        module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
        let oneAcc = String(acc.dropLast(5))
        do
        {
            let fetchSet = try coredatafunction.fetchObjectofSettings()
            for setDetail in fetchSet
            {
                if setDetail.value(forKey: "accounts")! as? String == oneAcc
                {
                    if setDetail.value(forKey: "accTypeShort")! as? String == module
                    {
                        days.setTitle(setDetail.value(forKey: "days")! as? String, for: .normal)
                        hour.setTitle(setDetail.value(forKey: "hours")! as? String, for: .normal)
                        min.setTitle(setDetail.value(forKey: "minutes")! as? String, for: .normal)
                    }
                }
            }
        }
        catch
        {
        }
    }
}

