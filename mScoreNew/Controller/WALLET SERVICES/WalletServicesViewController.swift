//
//  VirtualCardViewController.swift
//  mScoreNew
//
//  Created by Perfect on 17/09/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import Foundation
import DropDown
class WalletServicesViewController: NetworkManagerVC,UITextFieldDelegate, ksebConfSuccessAlertDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var walletView           : UIView!
    @IBOutlet weak var segmentedControl     : UISegmentedControl!
    @IBOutlet weak var bankIcon             : UIImageView! {
        didSet{
            bankIcon.layer.cornerRadius = bankIcon.frame.size.width/3
            bankIcon.clipsToBounds = true
            SetImage(ImageCode: AppIconImageCode, ImageView: bankIcon, Delegate: self)
        }
    }
    @IBOutlet weak var bankName             : UILabel! {
        didSet{
            bankName.text = appName
        }
    }
    @IBOutlet weak var cusName              : UILabel!
    @IBOutlet weak var cusID                : UILabel!
    @IBOutlet weak var totalBalanceL        : UILabel!
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    @IBOutlet weak var loadMoneyView        : UIView! {
        didSet{
            loadMoneyView.isHidden = true
        }
    }
    @IBOutlet var accSelectionBtn           : UIButton!
    @IBOutlet weak var accBalanceL          : UILabel!
    @IBOutlet var amountTF                  : UITextField!{
        didSet{
            amountTF.setBottomBorder(UIColor.lightGray,1.0)
            amountTF.delegate = self
        }
    }
    @IBOutlet var amountInWordsL            : UILabel!
    @IBOutlet var remarkTF                  : UITextField!{
        didSet{
            remarkTF.setBottomBorder(UIColor.lightGray,1.0)
        }
    }
    @IBOutlet var payBtn                    : UIButton!
    @IBOutlet weak var miniStatementView    : UIView! {
        didSet{
            miniStatementView.isHidden = true
        }
    }
    @IBOutlet var ministatementTbl          : UITableView!
    
    var accDrop                     = DropDown()
    lazy var accDropDowns           : [DropDown]         = {return[self.accDrop]} ()
    var fetchedCusDetails           : [Customerdetails]  = []
    var fetchedCusPhoto             : [CustomerPhoto]    = []
    var custoNum                    = String()
    var custoName                   = String()
    var custoPhoneNum               = String()
    var OwnAccountdetailsList       = [NSDictionary]()
    var customerId                  = String()
    var TokenNo                     = String()
    var fromAccBranchLtxt           = String()
    var AccountdetailsList          = ["Select Account"]
    var SubModule                   = ""
    var Fk_AccountCode              = ""
    var selectedAccBalance          = Double()
    var ShareImg                    = UIImage()
    var ShareB                      = UIButton()
    var CardMiniStatementDetailsData  = [NSDictionary]()
    var modelInfo = NSDictionary()
    private var parserViewModel : ParserViewModel = ParserViewModel()
    let group = DispatchGroup()

    
    fileprivate func initializeWallet() {
        
        parserViewModel.mainThreadCall {
            self.cusID.text       = "Cus Id : "+self.custoNum
            self.cusName.text     = self.custoName
            
            self.loadMoneyView.isHidden      = false
            self.miniStatementView.isHidden       = true
            
            self.blurView.isHidden       = false
            self.activityIndicator.startAnimating()
            
            self.ministatementTbl.dataSource = self
            self.ministatementTbl.delegate = self

        }
                OwnAccounDetails()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        
        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                custoNum      = (fetchedCusDetail.value(forKey: "customerNum") as? String)!
                custoName     = (fetchedCusDetail.value(forKey: "name") as? String)!
                custoPhoneNum = (fetchedCusDetail.value(forKey: "mobileNum") as? String)!

            }
        }
        catch
        {
        }
       
        initializeWallet()
    }
    
    //FIXME: ========= accountUIUpdateDetails() ==========
    fileprivate func accountUIUpdateDetails(info:[NSDictionary]) {
        parserViewModel.mainThreadCall {
            self.accSelectionBtn.setTitle((info.first!.value(forKey: "AccountNumber") as? String ?? ""), for: .normal)
            self.fromAccBranchLtxt = info.first!.value(forKey: "BranchName") as? String ?? ""
            self.setAccDropDown()
        }
        
    }
    
    
    //FIXME: ========= OWN_ACCOUNT_DETAILS_API() ==========
    func OwnAccounDetails() {
        // network reachability checking
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        
        
        parserViewModel.ownAccountDetails(subMode: 1, token: TokenNo, custID: customerId) { getResult in
            switch getResult{
            case.success(let datas):
                
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    
                    
                    let response = self.parserViewModel.resultHandler(datas: datas,modelKey:"OwnAccountdetails")
                    let exMsg = response.0
                    let OwnAccountdetails = response.1 as? NSDictionary ?? [:]
                    
                    
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: OwnAccountdetails, exmsg: exMsg,vc:self) { status in
                          
                        let ownAccountDList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as? [NSDictionary] ?? []
                        self.OwnAccountdetailsList = ownAccountDList.compactMap{$0}
                        
                        self.AccountdetailsList = []
                        self.AccountdetailsList.append(contentsOf: self.OwnAccountdetailsList.map{ $0.value(forKey: "AccountNumber") as? String ?? "" })
                        
                        self.accountUIUpdateDetails(info: self.OwnAccountdetailsList)
                        
                    }
                    
                }
                
                
            case.failure(let errResponse):
                
                self.parserViewModel.parserErrorHandler(errResponse, vc: self)
                
            }
            self.removeIndicator(showMessagge: false, message: "",activityView: self.activityIndicator, blurview: self.blurView)
                //self.checkCardBalance()
                self.checkCardBalances()
         }
    
       }
    
    
    
    
//    func OwnAccounDetails() {
//        // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//                self?.blurView.isHidden       = true
//                self?.activityIndicator.stopAnimating()
//            }
//            return
//        }
//        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/OwnAccounDetails")!
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("13", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
//        let encryptedSubMode     = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
//        let jsonDict            = ["ReqMode" : encryptedReqMode,
//                                   "Token" : encryptedTocken,
//                                   "FK_Customer" : encryptedCusNum ,
//                                   "SubMode" : encryptedSubMode,
//                                   "BankKey" : BankKey,
//                                   "BankHeader" : BankHeader]
//        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
//        var request             = URLRequest(url: url)
//            request.httpMethod  = "post"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody    = jsonData
//        let session = URLSession(configuration: .default,
//                                 delegate: self,
//                                 delegateQueue: nil)
//        let task = session.dataTask(with: request) { [self] data, response, error in
//            guard let data = data, error == nil else {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self?.blurView.isHidden       = true
//                    self?.activityIndicator.stopAnimating()
//                }
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    DispatchQueue.main.async {
//                        self.blurView.isHidden = true
//                        self.activityIndicator.stopAnimating()
//                    }
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//                    if sttsCode==0 {
//                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
//                        OwnAccountdetailsList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as! [NSDictionary]
//
//                        for Accountdetails in OwnAccountdetailsList {
//                            AccountdetailsList.append(Accountdetails.value(forKey: "AccountNumber") as! String)
//                        }
//                        DispatchQueue.main.async { [weak self] in
//                            self!.accSelectionBtn.setTitle(AccountdetailsList[0], for: .normal)
//                        }
//                        setAccDropDown()
//                    }
//                    else {
//
//                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as Any
//                        if OwnAccountdetails as? String != nil {
//                            let OwnAccountdetail  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
//                            let ResponseMessage =  OwnAccountdetail.value(forKey: "ResponseMessage") as! String
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
//                            }
//                        }
//                        else {
//                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
//                            }
//                        }
//                    }
//                }
//                catch{
//                    DispatchQueue.main.async {
//                        self.blurView.isHidden = true
//                        self.activityIndicator.stopAnimating()
//                    }
//                }
//            }
//            else{
//                DispatchQueue.main.async { [weak self] in
//                    self?.blurView.isHidden = true
//                    self?.activityIndicator.stopAnimating()
//                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
//                }
//                print(httpResponse.statusCode)
//            }
//        }
//        checkCardBalance()
//        task.resume()
//    }
    
    
    fileprivate func updateWalletUIDetails(info: NSDictionary,successCode:Int){
        
            self.totalBalanceL.text      = "Wallet Balance : " + Double(info.value(forKey: "Balance") as? String ?? "0.00")!.currencyIN
            self.loadMoneyView.isHidden  =   false
        if successCode == 1{
            self.walletView.isHidden = true
        }
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.view.layoutIfNeeded()
            }
        
    }
    
    
    //FIXME: - ==== checkCardBalances() ========
    func checkCardBalances(){
        
        var successCode = 0
        self.displayIndicator(activityView: self.activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork(){
            
            self.removeIndicator(showMessagge: true, message: networkMsg, activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = "/cbsMobile/CardBalance"
        let arguMents = ["ID_Customer":customerId,
                         "CorpCode":BankKey]
        
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "BalanceDetails")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    successCode = statusCode
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        self.modelInfo = modelInfo
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
                    self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
                    self.updateWalletUIDetails(info: self.modelInfo, successCode: successCode)
                }
            }
        }
        
}
    
    // old complete
    func checkCardBalance() {
        self.blurView.isHidden = false
        self.activityIndicator.startAnimating()
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.blurView.isHidden       = true
                self?.activityIndicator.stopAnimating()
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/cbsMobile/CardBalance")!
        let jsonDict            = ["ID_Customer" : instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr"),
                                   "CorpCode" : BankKey]
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
                    self!.present(errorMessages.error(error! as NSError), animated: true, completion: nil)

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
                        let BalanceDetails          = responseJSONData.value(forKey: "BalanceDetails") as! NSDictionary
                        DispatchQueue.main.async {
                            self.totalBalanceL.text      = "Wallet Balance : " + Double(BalanceDetails.value(forKey: "Balance")! as! String)!.currencyIN
                            self.loadMoneyView.isHidden  = false
                        }
                    }
                    else if sttsCode==1 {
                        DispatchQueue.main.async {
                            self.walletView.isHidden = true
//                            self.present(messages.msg("EXMessage"), animated: true,completion: nil)
                        }
                    }
                    else {
                        totalBalanceL.text          = ""
                        let BalanceDetails          = responseJSONData.value(forKey: "BalanceDetails") as Any
                        if BalanceDetails as? NSDictionary != nil {
                            let BalanceDetail       = responseJSONData.value(forKey: "BalanceDetails") as! NSDictionary
                            let ResponseMessage     =  BalanceDetail.value(forKey: "ResponseMessage") as! String
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
                catch {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.blurView.isHidden = true
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                    self.present(messages.msg(data.base64EncodedString()), animated: true,completion: nil)
                }
            }
        }
        task.resume()
    }
    
   
    @IBAction func segmentSelection(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                loadMoneyView.isHidden = false
                miniStatementView.isHidden  = true
            case 1:
               // CardMiniStatement()
                bankCardMiniStateMent()
                loadMoneyView.isHidden = true
                miniStatementView.isHidden  = false
            default:
                break;
        }
    }
    
    
    //FIXME: - ==== bankCardStatementUIUpdate() ========
    fileprivate func bankCardStatementUIUpdate(){
        
        self.ministatementTbl.reloadData()
        
    }
    
    //FIXME: - ==== bankCardMiniStateMent() ========
    func bankCardMiniStateMent(){
        
        self.displayIndicator(activityView: self.activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork(){
            
            self.removeIndicator(showMessagge: true, message: networkMsg, activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let acc                     = accSelectionBtn.currentTitle!
        let AccNo                   = String(acc.dropLast(5))
        
        let urlPath = "/cbsMobile/CardMiniStatement"
        let arguMents = ["ID_Customer"    : customerId,
                         "CorpCode"       : BankKey,
                         "SubModule"      : SubModule,
                         "Fk_AccountCode" : Fk_AccountCode,
                         "MobNo"          : custoPhoneNum,
                         "CustId"         : custoNum,
                         "AccNo"          : AccNo]
        
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler( datas: datas, modelKey: "CardMiniStatementDetails")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        self.CardMiniStatementDetailsData = []
                        self.CardMiniStatementDetailsData = modelInfo.value(forKey: "Data") as? [NSDictionary] ?? []
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
                    self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
                    self.bankCardStatementUIUpdate()
                }
            }
        }
    }

    // old completed
    func CardMiniStatement() {
        
        self.blurView.isHidden = false
        self.activityIndicator.startAnimating()
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.blurView.isHidden       = true
                self?.activityIndicator.stopAnimating()
            }
            return
        }
        
        let url                     = URL(string: BankIP + APIBaseUrlPart1 + "/cbsMobile/CardMiniStatement")!
        let acc                     = accSelectionBtn.currentTitle!
        let AccNo                   = String(acc.dropLast(5))
        let encryptedID_Customer    = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
        let encryptedSubModule      = instanceOfEncryptionPost.encryptUseDES(SubModule, key: "Agentscr")
        let encryptedFk_AccountCode = instanceOfEncryptionPost.encryptUseDES(Fk_AccountCode, key: "Agentscr")
        let encryptedMobNo          = instanceOfEncryptionPost.encryptUseDES(custoPhoneNum, key: "Agentscr")
        let encryptedCustId         = instanceOfEncryptionPost.encryptUseDES(custoNum, key: "Agentscr")
        let encryptedAccNo          = instanceOfEncryptionPost.encryptUseDES(AccNo, key: "Agentscr")
        let jsonDict                = ["ID_Customer"    : encryptedID_Customer,
                                       "CorpCode"       : BankKey,
                                       "SubModule"      : encryptedSubModule,
                                       "Fk_AccountCode" : encryptedFk_AccountCode,
                                       "MobNo"          : encryptedMobNo,
                                       "CustId"         : encryptedCustId,
                                       "AccNo"          : encryptedAccNo]
        let jsonData                = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request                 = URLRequest(url: url)
            request.httpMethod      = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody        = jsonData
        let session                 = URLSession(configuration: .default,
                                     delegate: self,
                                     delegateQueue: nil)
        let task = session.dataTask(with: request) { [self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { [weak self] in
                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self?.blurView.isHidden       = true
                    self?.activityIndicator.stopAnimating()
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    CardMiniStatementDetailsData  = [NSDictionary]()
                    DispatchQueue.main.async {
                        self.blurView.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let CardMiniStatementDetails  = responseJSONData.value(forKey: "CardMiniStatementDetails") as! NSDictionary
                        CardMiniStatementDetailsData  = CardMiniStatementDetails.value(forKey: "Data") as! [NSDictionary]
                        print(CardMiniStatementDetailsData)
                        DispatchQueue.main.async {
                            ministatementTbl.reloadData()
                        }
                        

                    }
                    else {
                        
                        let CardMiniStatementDetails  = responseJSONData.value(forKey: "CardMiniStatementDetails") as Any
                        if CardMiniStatementDetails as? String != nil {
                            let CardMiniStatementDetail  = responseJSONData.value(forKey: "CardMiniStatementDetails") as! NSDictionary
                            let ResponseMessage =  CardMiniStatementDetail.value(forKey: "ResponseMessage") as! String
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
                    DispatchQueue.main.async {
                        self.blurView.isHidden = true
                        self.activityIndicator.stopAnimating()
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(CardMiniStatementDetailsData.count)
        return CardMiniStatementDetailsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletTransactionCell", for: indexPath as IndexPath) as!  WalletTransactionTable
        
        cell.cd.text = CardMiniStatementDetailsData[indexPath.row].value(forKey: "DrCr") as? String
        
        cell.amount.text = Double(CardMiniStatementDetailsData[indexPath.row].value(forKey: "Amount") as! String)?.currencyIN
        cell.date.text =  CardMiniStatementDetailsData[indexPath.row].value(forKey: "Date") as? String
            
        
        return cell
    }

    @IBAction func clearBtn(_ sender: UIButton) {
        clear()
    }
    
    func clear(){
        DispatchQueue.main.async {
            self.accSelectionBtn.setTitle(self.AccountdetailsList[0], for: .normal)
            self.payBtn.setTitle("PAY", for: .normal)
            self.amountTF.text          = ""
            self.remarkTF.text          = ""
            self.amountInWordsL.text    = ""
            self.accBalanceL.text       = ""
            self.SubModule              = ""
            self.Fk_AccountCode         = ""
            self.fromAccBranchLtxt      = ""
        }
    }
    
    @IBAction func rechareWalletBtn(_ sender: UIButton) {
        if accSelectionBtn.title(for: .normal) == "Select Account" {
            DispatchQueue.main.async {
                self.present(messages.msg("Please Select Account."), animated: true, completion: nil)
            }
            return
        }
        if amountTF.text.flatMap(Double.init) ?? 0.0 <= 0.0 {
            DispatchQueue.main.async {
                self.present(messages.msg("Please Enter Valid Amount."), animated: true, completion: nil)
            }
            return
        }

        if Double(amountTF.text!)! > selectedAccBalance {
            DispatchQueue.main.async {
                self.present(messages.msg("Please Enter Amount Less Than Selected Account Balance."), animated: true, completion: nil)
            }
            return
        }
        
        walletConfirmation()
    }
    
    
    func walletConfirmation() {
        let customWAlert = self.storyboard?.instantiateViewController(withIdentifier: "walletTopUpConfirmationAlert") as! walletTopupConfirmationAlertViewController
        customWAlert.providesPresentationContextTransitionStyle = true
        customWAlert.definesPresentationContext = true
        customWAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customWAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customWAlert.delegate = self
        let fromAcc = accSelectionBtn.currentTitle!
        customWAlert.fromAccLtxt = fromAcc
        customWAlert.fromAccBranchLtxt = fromAccBranchLtxt
        customWAlert.conAmountLtxt = Double(amountTF.text!)!.currencyIN
        customWAlert.conAmountDetailsLtxt = Double(amountTF.text!)!.InWords
        self.present(customWAlert, animated: true, completion: nil)
    }
    
    
    //FIXME: - === walletTopUpApi() ===
    fileprivate func walletTopUpApi(){
        // network call
        self.displayIndicator(activityView: self.activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork(){
            
            self.removeIndicator(showMessagge: true, message: networkMsg, activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = "/cbsMobile/CardTopUpandReverse"
        
        let Amount = amountTF.text!
        let acc = accSelectionBtn.currentTitle!
        let AccNo = String(acc.dropLast(5))
        
        let arguMent = ["ID_Customer"    : customerId,
                        "CorpCode"       : BankKey,
                        "Amount"         : Amount,
                        "SubTranType"    : "P" ,
                        "SubModule"      : SubModule,
                        "Fk_AccountCode" : Fk_AccountCode,
                        "MobNo"          : custoPhoneNum,
                        "CustId"         : custoNum,
                        "AccNo"          : AccNo]
        
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMent) { getResult in
            var RFID = ""
            var ResponseMessage = ""
            var CDate = ""
            var CTime = ""
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "CardTopUpDetails")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        
                         RFID = modelInfo.value(forKey: "TransactonrefNo") as? String ?? ""
                         ResponseMessage = modelInfo.value(forKey: "ResponseMessage") as? String ?? ""
                         CDate           = Date().currentDate(format: "dd-MM-yyyy")
                         CTime           = Date().currentDate(format: "h:mm a")
                        
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
                    self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
                    self.RechargeWalletSuccess(ResponseMessage,String(RFID) ,CDate, CTime)
                    self.checkCardBalances()
                }
            }
        }
    }
    
//    func WalletTopUp() {
//
//        self.blurView.isHidden = false
//        self.activityIndicator.startAnimating()
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//
//                self?.blurView.isHidden       = true
//                self?.activityIndicator.stopAnimating()
//            }
//            return
//        }
//
//        let url                     = URL(string: BankIP + APIBaseUrlPart1 + "/cbsMobile/CardTopUpandReverse")!
//
//
//        let Amount = amountTF.text!
//        let acc = accSelectionBtn.currentTitle!
//        let AccNo = String(acc.dropLast(5))
//        let encryptedID_Customer    = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
//        let encryptedAmount         = instanceOfEncryptionPost.encryptUseDES(Amount, key: "Agentscr")
//        let encryptedSubTranType    = instanceOfEncryptionPost.encryptUseDES("P", key: "Agentscr")
//        let encryptedSubModule      = instanceOfEncryptionPost.encryptUseDES(SubModule, key: "Agentscr")
//        let encryptedFk_AccountCode = instanceOfEncryptionPost.encryptUseDES(Fk_AccountCode, key: "Agentscr")
//        let encryptedMobNo          = instanceOfEncryptionPost.encryptUseDES(custoPhoneNum, key: "Agentscr")
//        let encryptedCustId         = instanceOfEncryptionPost.encryptUseDES(custoNum, key: "Agentscr")
//        let encryptedAccNo          = instanceOfEncryptionPost.encryptUseDES(AccNo, key: "Agentscr")
//
//        let jsonDict                = ["ID_Customer"    : encryptedID_Customer,
//                                       "CorpCode"       : BankKey,
//                                       "Amount"         : encryptedAmount,
//                                       "SubTranType"    : encryptedSubTranType ,
//                                       "SubModule"      : encryptedSubModule,
//                                       "Fk_AccountCode" : encryptedFk_AccountCode,
//                                       "MobNo"          : encryptedMobNo,
//                                       "CustId"         : encryptedCustId,
//                                       "AccNo"          : encryptedAccNo]
//
//        let jsonData                = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
//        var request                 = URLRequest(url: url)
//            request.httpMethod      = "post"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody        = jsonData
//        let session                 = URLSession(configuration: .default,
//                                     delegate: self,
//                                     delegateQueue: nil)
//        let task = session.dataTask(with: request) { [self] data, response, error in
//            guard let data = data, error == nil else {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                    self?.blurView.isHidden       = true
//                    self?.activityIndicator.stopAnimating()
//                }
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    DispatchQueue.main.async {
//                        self.blurView.isHidden = true
//                        self.activityIndicator.stopAnimating()
//                    }
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//                    if sttsCode==0 {
//                        let OwnAccountdetails  = responseJSONData.value(forKey: "CardTopUpDetails") as! NSDictionary
//                        let RefID           = OwnAccountdetails.value(forKey: "TransactonrefNo") as! String
//                        let StatusMessage   = OwnAccountdetails.value(forKey: "ResponseMessage") as! String
//                        let CDate           = Date().currentDate(format: "dd-MM-yyyy")
//                        let CTime           = Date().currentDate(format: "h:mm a")
//                        DispatchQueue.main.async {
//                            RechargeWalletSuccess(StatusMessage,String(RefID) ,CDate, CTime)
//                        }
//                        checkCardBalance()
//
//                    }
//                    else {
//
//                        let OwnAccountdetails  = responseJSONData.value(forKey: "CardTopUpDetails") as Any
//                        if OwnAccountdetails as? String != nil {
//                            let OwnAccountdetail  = responseJSONData.value(forKey: "CardTopUpDetails") as! NSDictionary
//                            let ResponseMessage =  OwnAccountdetail.value(forKey: "ResponseMessage") as! String
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
//                            }
//                        }
//                        else {
//                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
//                            }
//                        }
//                    }
//                }
//                catch{
//                    DispatchQueue.main.async {
//                        self.blurView.isHidden = true
//                        self.activityIndicator.stopAnimating()
//                    }
//                }
//            }
//            else{
//                DispatchQueue.main.async { [weak self] in
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
//                }
//                print(httpResponse.statusCode)
//            }
//        }
//        task.resume()
//    }
    
    func RechargeWalletSuccess(_ RTitle : String,_ RefTitle : String, _ RDate : String, _ RTime : String) {
        let customRKSAlert = self.storyboard?.instantiateViewController(withIdentifier: "walletTopUpsuccessAlert") as! walletTopupSuccessAlertViewController
        customRKSAlert.providesPresentationContextTransitionStyle = true
        customRKSAlert.definesPresentationContext = true
        customRKSAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customRKSAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customRKSAlert.delegate = self
        customRKSAlert.sucHdrLtxt = RTitle
        customRKSAlert.wRechDateLtxt = "Date : \(RDate)"
        customRKSAlert.wRechTimeLtxt = "Time : \(RTime)"
        customRKSAlert.wRechReffeLtxt = "Ref.No : \(RefTitle)"
        let fromAcc = accSelectionBtn.currentTitle!
        customRKSAlert.fromAccLtxt = fromAcc
        customRKSAlert.fromAccBranchLtxt = fromAccBranchLtxt
//        customRKSAlert.kRechmobLtxt = mobNumber.text!
//        customRKSAlert.kRechNamLtxt = consumerName.text!
//        customRKSAlert.kRechDetaLtxt = "Consumer No : \(consumerNumber.text!) \nConsumer Section : \(selectSection.currentTitle!) \nBill No : \(billNum.text!)"
        customRKSAlert.wRechAmountLtxt = Double(amountTF.text!)!.currencyIN
        customRKSAlert.wRechAmountDetailsLtxt = Double(amountTF.text!)!.InWords
        self.present(customRKSAlert, animated: true, completion: nil)
    }
    
    func setAccDropDown()
    {
        accDrop.anchorView      = accSelectionBtn
        accDrop.bottomOffset    = CGPoint(x:0, y:0)
        accDrop.dataSource      = AccountdetailsList
        accDrop.backgroundColor = UIColor.white
        accDrop.selectionAction = {[weak self] (index, item) in
            if index != 0 {
                self?.fromAccBranchLtxt = self?.OwnAccountdetailsList[index-1].value(forKey: "BranchName") as! String
                self?.selectedAccBalance = self?.OwnAccountdetailsList[index-1].value(forKey: "Balance") as! Double
                self?.accBalanceL.text = "Available Balance : " + (self?.OwnAccountdetailsList[index-1].value(forKey: "Balance") as! Double).currencyIN
                self?.SubModule = self?.OwnAccountdetailsList[index-1].value(forKey: "SubModule") as! String
                self?.Fk_AccountCode = String(self?.OwnAccountdetailsList[index-1].value(forKey: "FK_Account") as! Int)
            }
            else {
                self?.fromAccBranchLtxt = ""
                self?.accBalanceL.text = ""
                self?.SubModule = ""
                self?.Fk_AccountCode = ""
            }
            self?.accSelectionBtn.setTitle(item, for: .normal)
        }
    }
        
    @IBAction func accDropList(_ sender: UIButton) {
        accDrop.show()
    }
    
    
    
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(greenColour,2.0)
        self.keyboardWillShow()
    }
   
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(UIColor.lightGray,1.0)
    }
    
    var amountInWordsTxt = String()
    var payAmount = String()
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.isEqual(amountTF)
        {
            let amn = amountTF.text!
            if amn.count != 0 && amn.count < 11 {
                amountInWordsTxt = Double(String(amn))!.InWords
                payAmount = (Double(amn)!.currencyIN)
                amountInWordsL.text = amountInWordsTxt
                payBtn.setTitle("PAY \(payAmount)", for: .normal)
            }
            else if amn.count > 10 {
                amountInWordsL.text = amountInWordsTxt
                payBtn.setTitle("PAY \(payAmount)", for: .normal)
            }
            else{
                payBtn.setTitle("PAY", for: .normal)
                amountInWordsL.text = ""
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount)
        {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        var maxLength = 0
        
        if textField.isEqual(amountTF)
        {
            maxLength = 10
            
        }
        return newLength <= maxLength
    }
    
    @IBAction func amountEditing(_ sender: Any) {
        let amn = amountTF.text
        if amn?.count != 0 {
            amountInWordsL.text = Double(String(amn!))?.InWords
            payBtn.setTitle("PAY \(Double(amn!)!.currencyIN)", for: .normal)
        }
        else{
            payBtn.setTitle("PAY", for: .normal)
            amountInWordsL.text = ""
        }
    }
    
    func keyboardWillShow() {
        
        if amountTF.isFirstResponder
        {
            DispatchQueue.main.async { () -> Void in
                nextButtonInClick.ShowKeyboard(view: self.view)
            }
        }
        else
        {
            mobilePadNextButton.isHidden = true
        }
        
    }
    @objc func mobilePadNextAction(_ sender : UIButton) {
        //Click action
        if amountTF.isFirstResponder{
            remarkTF.becomeFirstResponder()
        }
        else if remarkTF.isFirstResponder{
            mobilePadNextButton.isHidden = true
            view.endEditing(true)
        }
    }

}

extension WalletServicesViewController : walletTopupConfSuccessAlertDelegate {
    func okButtonTapped() {
        print("OK")
        //self.WalletTopUp()
        self.walletTopUpApi()
        
//        self.RechargeKSEB(self.consumerName.text!, self.mobNumber.text!, self.consumerNumber.text!, self.billNum.text!, billAmount.text!, self.accNumber.currentTitle!)
    }
    
    func cancelButtonTapped() {
        print("cancel")
    }
    
    func shareButtonTapped() {
        print("share")
        self.clear()
        if ShareImg.size.width != 0 {
            let firstActivityItem = ""
            let secondActivityItem  = ShareImg
            let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem,secondActivityItem], applicationActivities: nil)
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = (ShareB)
            
            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.unknown
            // UIPopoverArrowDirection.allZeros
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150,
                                                                                      y: 150,
                                                                                      width: 0,
                                                                                      height: 0)
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.postToWeibo,
                                                            UIActivity.ActivityType.print,
                                                            UIActivity.ActivityType.assignToContact,
                                                            UIActivity.ActivityType.saveToCameraRoll,
                                                            UIActivity.ActivityType.addToReadingList,
                                                            UIActivity.ActivityType.postToFlickr,
                                                            UIActivity.ActivityType.postToVimeo,
                                                            UIActivity.ActivityType.postToTencentWeibo]
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    func ShareScreenShot(_ img: UIImage, _ Share: UIButton) {
        self.ShareImg = img
        self.ShareB = Share
    }
    
    
}
