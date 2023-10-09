//
//  SplashViewController.swift
//  mScoreNew
//
//  Created by Perfect on 15/09/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit
import Foundation

class SplashViewController: NetworkManagerVC {
    
    var instanceOfEncryption: EncryptionPost = EncryptionPost()
   

    @IBOutlet weak var ivBankIcon : UIImageView!
    @IBOutlet weak var btnProceed : UIButton!{
        didSet {
            
            btnProceed.isHidden = true
            btnProceed.curvedButtonWithBorder(UIColor.white.cgColor)
        }
    }
    
    var isLogOutCalled : ((Bool)->Void) = { sessionOut in
        
        if sessionOut{
            
           
            
            print("============ Reached Logout page============== session status :\(sessionOut)")
            
            
        }
        
       
     
        
    }
    
   var outSession = Bool()
    
  
    
    @IBOutlet weak var lErrorMessage : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        certificates    = [Data]()
        ImageURL        = OriginalImageURL
        BankIP          = OriginalBankIP
        
//        BankHdr         = OriginalBankHeader
//        BankKe          = OriginalBankKey
//        certURL         = OriginalCertUrl
        certificates    = {
                            let url = Bundle.main.url(forResource: OriginalCertName, withExtension: "cer")
                            let data = try! Data(contentsOf: url!)
                            return [data]
                        }()
//        BankKey         = instanceOfEncryptionPost.encryptUseDES(OriginalBankKey, key: "Agentscr")
//        BankHeader      = instanceOfEncryptionPost.encryptUseDES(OriginalBankHeader, key: "Agentscr")
        BankKey         = OriginalBankKey
        BankHeader      = OriginalBankHeader
        

        
       
        
        setReseller()
    }
    

    @IBAction func ProceedAction(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: "SplashToLoginSection", sender: self)
        }
    }
    
    
    
    
    
    func setReseller() {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
//         let jsonDict            = ["ReqMode":instanceOfEncryption.encryptUseDES("20", key: "Agentscr"),
//        "BankKey" : BankKey,
//        "BankHeader" : BankHeader]
        
        
     
        
        let url   = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/ResellerDetails")!
        let jsonDict            = ["ReqMode":"20",
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]
        print(jsonDict)
        
       
        
        
        print(url)
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)
        
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { [weak self] in
                    self!.present(errorMessages.error(error! as NSError), animated: true, completion: nil)

//                    self!.activityIndicator.stopAnimating()
//                    self!.blurView.isHidden = true
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(responseJSONData)
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        
                        let ResellerDetails     = responseJSONData.value(forKey: "ResellerDetails") as! NSDictionary
                        AppIconImageCode        = ResellerDetails.value(forKey: "AppIconImageCode")! as! String
                        self.SetImage(ImageCode: AppIconImageCode, ImageView: self.ivBankIcon, Delegate: self)
                        appName                 = ResellerDetails.value(forKey: "ProductName")! as! String
                        CompanyLogoImageCode    = ResellerDetails.value(forKey: "CompanyLogoImageCode")! as! String
                        appLink                 = ResellerDetails.value(forKey: "AppStoreLink")! as! String
                        
                        TestingImageURL         = ResellerDetails.value(forKey: "TestingImageURL")! as! String
                        TestingMachineId        = ResellerDetails.value(forKey: "TestingMachineId")! as! String
                        TestingMobileNo         = ResellerDetails.value(forKey: "TestingMobileNo")! as! String
                        TestingURL              = ResellerDetails.value(forKey: "TestingURL")! as! String
                        
                        TestingBankHeader       = ResellerDetails.value(forKey: "BankHeader")! as! String
                        TestingBankKey          = ResellerDetails.value(forKey: "BankKey")! as! String
                        EwireCardService        = ResellerDetails.value(forKey: "EwireCardService")! as! String
                        
                        do {
                            if try coredatafunction.fetchObjectofCus().count != 0 {
                                let fetchedCusDetails = try coredatafunction.fetchObjectofCus()[0]
                                let MobileNo = (fetchedCusDetails.value(forKey: "mobileNum") as? String)!
                                if TestingImageURL != "" && TestingURL != "" && TestingBankHeader != "" && TestingBankKey != "" && TestingMobileNo == MobileNo {
                                    certificates    = [Data]()
                                    ImageURL    = TestingImageURL
                                    BankIP      = TestingURL
                                    certificates = {
                                                    let url = Bundle.main.url(forResource: TestingCertName, withExtension: "cer")
                                                    let data = try! Data(contentsOf: url!)
                                                    return [data] }()
//                                    BankKey     = instanceOfEncryptionPost.encryptUseDES(TestingBankKey, key: "Agentscr")
//                                    BankHeader  = instanceOfEncryptionPost.encryptUseDES(TestingBankHeader, key: "Agentscr")
                                    
                                    BankKey     = TestingBankKey
                                    BankHeader  = TestingBankHeader
                                }
                            }
                        }
                        catch {
                        }
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.3, execute: {
                            self.setMaintanence()
                        })
                    }
                    else {
                        let ResellerDetails  = responseJSONData.value(forKey: "ResellerDetails") as Any
                        if ResellerDetails as? NSDictionary != nil {
                            let ResellerDetail  = responseJSONData.value(forKey: "ResellerDetails") as! NSDictionary
                            let ResponseMessage =  ResellerDetail.value(forKey: "ResponseMessage") as! String
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
                catch let error{
                    print("get error--\(error.localizedDescription)")
                }
            }
            else{
                DispatchQueue.main.async {
                    self.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
                }
            }
        }
        task.resume()
    }
    

    func setMaintanence(){
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        
        //"ReqMode":instanceOfEncryption.encryptUseDES("15", key: "Agentscr")
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/MaintenanceMessage")!
        let jsonDict            = ["ReqMode":"15",
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]
        print(BankKey)

        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(responseJSONData)
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let MaintenanceMessage  = responseJSONData.value(forKey: "MaintenanceMessage") as! NSDictionary
                        let MaintenanceMessageList = MaintenanceMessage.value(forKey: "MaintenanceMessageList") as! [NSDictionary]
                        
                        if MaintenanceMessageList.count != 0 {
                            let Type = MaintenanceMessageList[0].value(forKey: "Type") as! Int
                            var Message = ""
                            if Type == -1 {
                                
                                DispatchQueue.main.async { [weak self] in
                                    self?.performSegue(withIdentifier: "SplashToLoginSection", sender: self)
                                }
                            }
                            else {
                                var i = -1
                                for MaintenanceMessages in MaintenanceMessageList {
                                    i += 1
                                    let msg = MaintenanceMessages.value(forKey: "Description") as! String

                                    if MaintenanceMessageList.count == 1 {
                                        Message = msg
                                    }
                                    else{

                                        if i == 0 {
                                            Message += String(i+1) + msg
                                        }
                                        else{
                                            Message += "\n" + String(i+1) + msg
                                        }
                                    }
                                }
                                DispatchQueue.main.async { [weak self] in
                                    self!.lErrorMessage.text = Message
                                }

                                if Type == 0 {
                                
                                    DispatchQueue.main.async { [weak self] in
                                        self!.btnProceed.isHidden = false
                                    }
                                }
                                else if Type == 1{
                                    
                                    DispatchQueue.main.async { [weak self] in
                                        self!.btnProceed.isHidden = true
                                    }
                                }

                            }
                        }
                    }
                    
                    else {
                        let MaintenanceMessage  = responseJSONData.value(forKey: "MaintenanceMessage") as Any
                        if MaintenanceMessage as? NSDictionary != nil {
                                let MaintenanceMessag  = responseJSONData.value(forKey: "MaintenanceMessage") as! NSDictionary
                            let ResponseMessage =  MaintenanceMessag.value(forKey: "ResponseMessage") as! String

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
                }
            }
            else{
                DispatchQueue.main.async { [weak self] in
                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
                }
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
}

extension SplashViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SplashToLoginSection"{
            if let loginVc = segue.destination as? Login{
                loginVc.sessionOut = outSession
            }
        }
        
    }
    
    
}
