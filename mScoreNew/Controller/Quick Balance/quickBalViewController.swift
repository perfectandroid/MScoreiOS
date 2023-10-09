//
//  quickBalViewController.swift
//  mScoreNew
//
//  Created by Perfect on 07/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit
import DropDown

class quickBalViewController: NetworkManagerVC {
    
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    @IBOutlet weak var accListingBtn        : UIButton!
    @IBOutlet weak var accTypeL             : UILabel!
    @IBOutlet weak var avalBalanceL         : UILabel!

    var customerId  = String()
    var pin         = String()
    var TokenNo     = String()
    
    var AccArray    = [String]()
    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()
    var accDrop     = DropDown()
    lazy var accDropDowns: [DropDown] = { return[self.accDrop] } ()
    var FK_Account = Int64()
    var SubModule = ""
    var NoOfDays = ""
    var PassBookAccountDetailsList = [NSDictionary]()
    var PassBookAccountStatementList = [NSDictionary]()
    // for fetch settings detail
    var fetchedSettings:[Settings]       = []
    private let parserViewModel:ParserViewModel = ParserViewModel()
    private let group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        do
        {
            fetchedSettings = try coredatafunction.fetchObjectofSettings()
            for fetchedSetting in fetchedSettings
            {
                NoOfDays = (fetchedSetting.value(forKey: "days") as? String)!
            }
        }
        catch{
        }
        blurView.isHidden = false
        activityIndicator.startAnimating()
        AccountNumberList()

    }
    
    func setDropDown()
    {
        accDrop.anchorView      = accListingBtn
        accDrop.bottomOffset    = CGPoint(x: 0, y:40)
        accDrop.dataSource      = AccArray
        accDrop.backgroundColor = UIColor.white
        accDrop.selectionAction = {[weak self] (index, item) in
            DispatchQueue.main.async { [weak self] in
                self?.accListingBtn.setTitle(item, for: .normal)
                for PassbookAcc in self!.PassBookAccountDetailsList {
                    if item == PassbookAcc.value(forKey: "AccountNumber") as! String {
                        self!.accTypeL.text           = (PassbookAcc.value(forKey: "AccountType") as! String)
                        self!.avalBalanceL.text       = (PassbookAcc.value(forKey: "AvailableBalance") as! Double).currencyIN
                    }
                }
            }
        }
    }
    
    func AccountNumberList() {
        
        var isshowbal = false
        
        // network reachability checking
        self.displayIndicator(activityView: self.activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork(){
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
           return
        }
        
        
        let urlPath = "/AccountSummary/PassBookAccountDetails"
        let arguMents = ["ReqMode" : "27",
                         "Token" : TokenNo,
                         "FK_Customer" : customerId ,
                         "BankKey" : BankKey,
                         "BankHeader" : BankHeader]
        
        self.group.enter()
        
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "PassBookAccountDetails")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        self.PassBookAccountDetailsList = []
                        self.PassBookAccountDetailsList = modelInfo.value(forKey: "PassBookAccountDetailsList") as? [NSDictionary] ?? []
                        
                        self.AccArray = []
                        self.PassBookAccountDetailsList.forEach { item in
                            if let isShowBalance = item.value(forKey: "IsShowBalance") as? Int{
                            if isShowBalance == 1{
                               let appendItem = item.value(forKey: "AccountNumber") as? String ?? ""
                                self.AccArray.append(appendItem)
                            }
                        }
                    }
                }
                    
                    self.group.leave()
                }
            case.failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
                self.group.leave()
            }
            
            DispatchQueue.global(qos: .default).async {
                self.group.wait()
                
                DispatchQueue.main.async {
                    
                    self.PassBookAccountDetailsList.forEach { item in
                        
                        if isshowbal != true {
                            if let isShowBalance = item.value(forKey: "IsShowBalance") as? Int{
                            if isShowBalance == 1{
                                let values = (item.value(forKey: "AvailableBalance") as? Double ?? 0.00).currencyIN
                                if values.contains("-₹") {
                                      
                                    
                                       self.avalBalanceL.text = "\(values)"
                                    
                                    }else{
                                         
                                        self.avalBalanceL.text = "\(values)"
                                    }
                                }
                                
                              
                                self.accListingBtn.setTitle((item.value(forKey: "AccountNumber") as? String ?? ""), for: .normal)
                                self.accTypeL.text  = (item.value(forKey: "AccountType") as? String ?? "")
                                isshowbal = true
                                return
                            }
                        }
                        
                    }
                    
                    self.setDropDown()
                    self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
                }
            }
        }

        
    }
    
    func accountNumberListApi() {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.activityIndicator.startAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/PassBookAccountDetails")!
        
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("27", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
        let jsonDict            = ["ReqMode" : "27",
                                   "Token" : TokenNo,
                                   "FK_Customer" : customerId ,
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]
    
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
                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
                self.blurView.isHidden = true
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let PassBookAccountDetails  = responseJSONData.value(forKey: "PassBookAccountDetails") as! NSDictionary
                        PassBookAccountDetailsList = PassBookAccountDetails.value(forKey: "PassBookAccountDetailsList") as! [NSDictionary]
                        var isshowbal = false

                        for PassbookAcc in PassBookAccountDetailsList{
                            if PassbookAcc.value(forKey: "IsShowBalance") as! Int == 1 {
                                AccArray.append(PassbookAcc.value(forKey: "AccountNumber") as! String)
                            }
                        }
                        for PassbAcc in PassBookAccountDetailsList{
                            DispatchQueue.main.async { [weak self] in
                                
                                self?.activityIndicator.stopAnimating()
                                self?.blurView.isHidden = true
                                if isshowbal != true {
                                    if PassbAcc.value(forKey: "IsShowBalance") as! Int == 1 {
                                        if (PassbAcc.value(forKey: "AvailableBalance") as! Double).currencyIN.contains("-₹") {
                                            avalBalanceL.text       = (PassbAcc.value(forKey: "AvailableBalance") as! Double).currencyIN
                                        }
                                        else{
                                            avalBalanceL.text       = (PassbAcc.value(forKey: "AvailableBalance") as! Double).currencyIN
                                        }
                                        accListingBtn.setTitle((PassbAcc.value(forKey: "AccountNumber") as! String), for: .normal)
                                        accTypeL.text           = (PassbAcc.value(forKey: "AccountType") as! String)
                                        isshowbal = true
                                        return
                                    }
                                }
                                
                            }

                        }
                        DispatchQueue.main.async {
                            setDropDown()
                        }
                        

                    }
                    
                    else {
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                        let PassBookAccountDetails  = responseJSONData.value(forKey: "PassBookAccountDetails") as Any
                        if PassBookAccountDetails as? NSDictionary != nil {
                                let PassBookAccountDetail  = responseJSONData.value(forKey: "PassBookAccountDetails") as! NSDictionary
                            let ResponseMessage =  PassBookAccountDetail.value(forKey: "ResponseMessage") as! String

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
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                        self?.blurView.isHidden = true
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
    
    
    
    
    @IBAction func accList(_ sender: UIButton)
    {
        accDrop.show()
    }
}
