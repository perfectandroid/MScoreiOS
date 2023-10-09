//
//  PassBookViewController.swift
//  mScoreNew
//
//  Created by Perfect on 13/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import DropDown

class PassBookViewController: NetworkManagerVC , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dataListingDateL     : UILabel!
    @IBOutlet weak var accListingBtn        : UIButton!
    @IBOutlet weak var accTypeL             : UILabel!
    @IBOutlet weak var avalBalanceL         : UILabel!
    @IBOutlet weak var unclearBalanceL      : UILabel!
    @IBOutlet weak var balanceViewHeight    : NSLayoutConstraint!
    @IBOutlet weak var hdrViewHeight        : NSLayoutConstraint!
    @IBOutlet weak var statementTable       : UITableView!
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    
    var customerId  = String()
    var pin         = String()
    var TokenNo     = String()
    var AccArray    = [String]()
    var accDrop     = DropDown()
    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()
    lazy var accDropDowns: [DropDown] = { return[self.accDrop] } ()
    var FK_Account = Int64()
    var SubModule = ""
    var NoOfDays = ""
    var PassBookAccountDetailsList = [NSDictionary]()
    var PassBookAccountStatementList = [NSDictionary]()
    // for fetch settings detail
    var fetchedSettings:[Settings]       = []
    private var parserViewModel : ParserViewModel = ParserViewModel()
    private let group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.blurView.isHidden = false
        self.activityIndicator.startAnimating()
        AccountNumberList()
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
//        self.statementTable.estimatedRowHeight = 80
//        self.statementTable.rowHeight = UITableView.automaticDimension

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
                        self!.FK_Account = PassbookAcc.value(forKey: "FK_Account") as! Int64
                        self!.SubModule = PassbookAcc.value(forKey: "SubModule") as! String
                        self!.accListingBtn.setTitle((PassbookAcc.value(forKey: "AccountNumber") as! String), for: .normal)
                        self!.accTypeL.text           = (PassbookAcc.value(forKey: "AccountType") as! String)
                        if PassbookAcc.value(forKey: "IsShowBalance") as! Int == 1 {
                            
                            self!.avalBalanceL.text       = (PassbookAcc.value(forKey: "AvailableBalance") as! Double).currencyIN
                            self!.unclearBalanceL.text    = (PassbookAcc.value(forKey: "UnclearAmount") as! Double).currencyIN

                            if PassbookAcc.value(forKey: "UnclearAmount") as! Double > Double(0) {
                                self!.unclearBalanceL.textColor = UIColor(red: 126/255.0, green: 88/255.0, blue: 88/255.0, alpha: 1.0)
                            }
                            else {
                                self!.unclearBalanceL.textColor = UIColor.red
                            }
                            self!.hdrViewHeight.constant = 130
                            self!.balanceViewHeight.constant = 65
                        }
                        else{
                            self!.hdrViewHeight.constant = 65
                            self!.balanceViewHeight.constant = 0
                        }
                    }
                }
                DispatchQueue.main.async{
                    self!.activityIndicator.startAnimating()
                    self!.blurView.isHidden = false
                    self!.selectedAccountDetails()
                }
                //self!.selectedAccDetails()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return PassBookAccountStatementList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transCell") as! TransactionTable
        
        cell.cd.text = Date().formattedDateFromString(dateString: PassBookAccountStatementList[indexPath.row].value(forKey: "TransDate") as! String, ipFormatter: "MM/dd/yyyy HH:mm:ss a", opFormatter: "dd-MM-yyyy")
        
        if PassBookAccountStatementList[indexPath.row].value(forKey: "TransType") as! String == "D" {
            cell.amount.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            cell.amount.text = (PassBookAccountStatementList[indexPath.row].value(forKey: "Amount") as! Double).currencyIN + " Dr"
        }
        else {
            cell.amount.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            cell.amount.text = (PassBookAccountStatementList[indexPath.row].value(forKey: "Amount") as! Double).currencyIN + " Cr"
        }
            cell.narration.text =  PassBookAccountStatementList[indexPath.row].value(forKey: "Narration") as! String + "\n \n"

        return cell
    }
    
//    func formattedDateFromString(dateString: String) -> String?
//    {
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss a"
//        if let date = inputFormatter.date(from: dateString)
//        {
//            let outputFormatter = DateFormatter()
//            outputFormatter.dateFormat = "dd-MM-yyyy"
//            return outputFormatter.string(from: date)
//        }
//        return nil
//    }
    
    func accountNumberListApi(){
        
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
                        
                        self.AccArray = self.PassBookAccountDetailsList.map{$0.value(forKey: "AccountNumber") as? String ?? ""}
                        
                        self.FK_Account = self.PassBookAccountDetailsList[0].value(forKey: "FK_Account") as! Int64
                        self.SubModule = self.PassBookAccountDetailsList[0].value(forKey: "SubModule") as! String
                        
                        
                        
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
                    // ui update
                    
                    self.accListingBtn.setTitle((self.PassBookAccountDetailsList.first!.value(forKey: "AccountNumber") as! String), for: .normal)
                    self.accTypeL.text           = (self.PassBookAccountDetailsList.first!.value(forKey: "AccountType") as! String)
                    if self.PassBookAccountDetailsList.first!.value(forKey: "IsShowBalance") as! Int == 1 {
                        
                        self.avalBalanceL.text       = (self.PassBookAccountDetailsList.first!.value(forKey: "AvailableBalance") as! Double).currencyIN
                        self.unclearBalanceL.text    = (self.PassBookAccountDetailsList.first!.value(forKey: "UnclearAmount") as! Double).currencyIN

                        if self.PassBookAccountDetailsList.first!.value(forKey: "UnclearAmount") as! Double > Double(0) {
                            self.unclearBalanceL.textColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
                        }
                        else {
                            self.unclearBalanceL.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                        }
                        self.hdrViewHeight.constant = 130
                        self.balanceViewHeight.constant = 65
                    }
                    else{
                        self.hdrViewHeight.constant = 65
                        self.balanceViewHeight.constant = 0
                    }
                    self.setDropDown()
                    //self.selectedAccDetails()
                    self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
                    self.selectedAccountDetails()
                    
                    self.view.layoutIfNeeded()
                }
            }
        }
        
    }
    
    
    func AccountNumberList() {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.blurView.isHidden = true
                self?.activityIndicator.stopAnimating()
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/PassBookAccountDetails")!
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("27", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
        
        let encryptedReqMode     = "27"
        let encryptedTocken     = TokenNo
        let encryptedCusNum     = customerId
        let jsonDict            = ["ReqMode" : encryptedReqMode,
                                   "Token" : encryptedTocken,
                                   "FK_Customer" : encryptedCusNum ,
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]
    
        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { [self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { [weak self] in
                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                        self?.blurView.isHidden = true
                    }
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let PassBookAccountDetails  = responseJSONData.value(forKey: "PassBookAccountDetails") as! NSDictionary
                        PassBookAccountDetailsList = PassBookAccountDetails.value(forKey: "PassBookAccountDetailsList") as! [NSDictionary]
                        self.AccArray=[]
                        for PassbookAcc in PassBookAccountDetailsList{
                            AccArray.append(PassbookAcc.value(forKey: "AccountNumber") as! String)
                        }
                        DispatchQueue.main.async {
                            self.FK_Account = self.PassBookAccountDetailsList[0].value(forKey: "FK_Account") as! Int64
                            self.SubModule = self.PassBookAccountDetailsList[0].value(forKey: "SubModule") as! String
                            self.accListingBtn.setTitle((self.PassBookAccountDetailsList[0].value(forKey: "AccountNumber") as! String), for: .normal)
                            self.accTypeL.text           = (self.PassBookAccountDetailsList[0].value(forKey: "AccountType") as! String)
                            if self.PassBookAccountDetailsList[0].value(forKey: "IsShowBalance") as! Int == 1 {
                                
                                self.avalBalanceL.text       = (self.PassBookAccountDetailsList[0].value(forKey: "AvailableBalance") as! Double).currencyIN
                                self.unclearBalanceL.text    = (self.PassBookAccountDetailsList[0].value(forKey: "UnclearAmount") as! Double).currencyIN

                                if self.PassBookAccountDetailsList[0].value(forKey: "UnclearAmount") as! Double > Double(0) {
                                    self.unclearBalanceL.textColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
                                }
                                else {
                                    self.unclearBalanceL.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                                }
                                self.hdrViewHeight.constant = 130
                                self.balanceViewHeight.constant = 65
                            }
                            else{
                                self.hdrViewHeight.constant = 65
                                self.balanceViewHeight.constant = 0
                            }
                            self.setDropDown()
                            //self.selectedAccDetails()
                            self.selectedAccountDetails()
                            
                            self.view.layoutIfNeeded()
                        }
                    }
                    
                    else {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func selectedAccountDetails(){
        
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = APIBaseUrlPart1 + "/AccountSummary/PassBookAccountStatement"
        
        let arguments = ["ReqMode"    : "28",
                         "Token"      : "\(TokenNo)",
                         "FK_Account" : "\(FK_Account)",
                         "SubModule"  : "\(SubModule)",
                         "NoOfDays"   : "\(NoOfDays)",
                         "BankKey"    : BankKey,
                         "BankHeader" : BankHeader]
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let exMessage = self.responseParse(type:String.self, datas: datas, key: "EXMessage") ?? ""
                   let passBookInfo = datas.value(forKey: "PassBookAccountStatement") as? NSDictionary ?? [:]
                    if statusCode == 0{
                        
                        if let PassBookAccountStatement  = datas.value(forKey: "PassBookAccountStatement") as? NSDictionary{
                            
                            let infoList = PassBookAccountStatement.value(forKey: "PassBookAccountStatementList") as? [NSDictionary] ?? []
                            self.PassBookAccountStatementList = []
                            self.PassBookAccountStatementList.append(contentsOf: infoList.map{$0})
                            DispatchQueue.main.async {
                                self.statementTable.reloadData()
                                self.statementTable.isHidden = false
                                self.dataListingDateL.text = "** Listing Data For Past " + self.NoOfDays + " Days.\n You Can Change It From Settings."
                            }
                            
                        }else{
                            
                            let responseMsg =  passBookInfo.value(forKey: "ResponseMessage") as? String ?? ""
                            if responseMsg != ""{
                            DispatchQueue.main.async {
                                self.present(messages.msg(responseMsg), animated: true,completion: nil)
                            }}
                            
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            self.present(messages.msg(exMessage), animated: true,completion: nil)
                        }
                    }
                    
                    
                }
            case.failure(let errResponse):
                
                var msg = ""
                
                let response = self.apiErrorResponseResult(errResponse: errResponse)
                msg = response.1
                
                    
        
                
                DispatchQueue.main.async {
                    self.present(messages.msg(msg), animated: true, completion: nil)
                }
                
            }
            
            self.removeIndicator(showMessagge: false, message: "",activityView: self.activityIndicator, blurview: self.blurView)
        }
        
    }
    
    func selectedAccDetails() {
        // network reachability checking
        if Reachability.isConnectedToNetwork() {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.activityIndicator.stopAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/PassBookAccountStatement")!
        
//        let encryptedReqMode    = instanceOfEncryptionPost.encryptUseDES("28", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedFK_Account = instanceOfEncryptionPost.encryptUseDES(String(FK_Account), key: "Agentscr")
//        let encryptedSubModule  = instanceOfEncryptionPost.encryptUseDES(SubModule, key: "Agentscr")
//        let encryptedNoOfDays   = instanceOfEncryptionPost.encryptUseDES(NoOfDays, key: "Agentscr")
        
//        let encryptedReqMode    = "28"
//        let encryptedTocken     = TokenNo
//        let encryptedFK_Account = String(FK_Account)
//        let encryptedSubModule  = SubModule
//        let encryptedNoOfDays   = NoOfDays


        let jsonDict            = ["ReqMode"    : "28",
                                   "Token"      : "\(TokenNo)",
                                   "FK_Account" : "\(FK_Account)",
                                   "SubModule"  : "\(SubModule)",
                                   "NoOfDays"   : "\(NoOfDays)",
                                   "BankKey"    : BankKey,
                                   "BankHeader" : BankHeader]
    
        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
        let task = session.dataTask(with: request) {  data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { [weak self] in
                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                        self?.blurView.isHidden = true
                    }
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let PassBookAccountStatement  = responseJSONData.value(forKey: "PassBookAccountStatement") as! NSDictionary
                        let infoList = PassBookAccountStatement.value(forKey: "PassBookAccountStatementList") as? [NSDictionary] ?? []
                        self.PassBookAccountStatementList = []
                        self.PassBookAccountStatementList.append(contentsOf: infoList.map{$0})
                        DispatchQueue.main.async {
                            self.statementTable.reloadData()
                            self.statementTable.isHidden = false
                            self.dataListingDateL.text = "** Listing Data For Past " + self.NoOfDays + " Days.\n You Can Change It From Settings."
                        }
                    }
                    
                    else {
                        DispatchQueue.main.async {
                            self.statementTable.reloadData()
                            self.statementTable.isHidden = true
                            self.dataListingDateL.text = ""

                        }
                        
                        let PassBookAccountStatement  = responseJSONData.value(forKey: "PassBookAccountStatement") as Any
                        if PassBookAccountStatement as? NSDictionary != nil {
                                let PassBookAccountStatemen  = responseJSONData.value(forKey: "PassBookAccountStatement") as! NSDictionary
                            let ResponseMessage =  PassBookAccountStatemen.value(forKey: "ResponseMessage") as! String

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
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
                }
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    var chequeNum = String(), transChequeDate = String(), transAmount = String(), transType = String(), transNarration = String()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let currentCell       = tableView.cellForRow(at: indexPath) as! TransactionTable
        chequeNum = PassBookAccountStatementList[indexPath.row].value(forKey: "chequeNo") as! String
        transChequeDate = PassBookAccountStatementList[indexPath.row].value(forKey: "chequeDate") as! String
        transAmount = (PassBookAccountStatementList[indexPath.row].value(forKey: "Amount") as! Double).currencyIN
        transType = PassBookAccountStatementList[indexPath.row].value(forKey: "TransType") as! String
        transNarration = PassBookAccountStatementList[indexPath.row].value(forKey: "Narration") as! String
        
        performSegue(withIdentifier: "TransactionDetails",
                     sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "TransactionDetails"
        {
            let transDet = segue.destination as! TransactionDetails
                transDet.transChequeNum    = chequeNum
                transDet.transChequeDate   = transChequeDate
                transDet.transAmount       = transAmount
                transDet.transTypeDet      = transType
                transDet.transNarrationDet = transNarration
        }
    }
    @IBAction func accList(_ sender: UIButton)
    {
        accDrop.show()
    }
}
