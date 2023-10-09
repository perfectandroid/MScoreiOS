//
//  ReachargeViewController.swift
//  mScoreNew
//
//  Created by Perfect on 22/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import DropDown
import ContactsUI

class ReachargeViewController: NetworkManagerVC,UITextFieldDelegate,CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var rechaLabel           : UILabel!
    @IBOutlet weak var phoneNum             : UITextField! {
        didSet{
            phoneNum.setBottomBorder(UIColor.lightGray,1.0)
        }
    }
    @IBOutlet weak var contacts             : UIButton!
    @IBOutlet weak var bsnlView             : UIView!
    @IBOutlet weak var bsnlViewHt           : NSLayoutConstraint!
    @IBOutlet weak var bsnlAccNum           : UITextField! {
        didSet{
            bsnlAccNum.setBottomBorder(UIColor.lightGray,1.0)
        }
    }
    @IBOutlet weak var operators            : UIButton!
    @IBOutlet weak var circles              : UIButton!
    @IBOutlet weak var amount               : UITextField! {
        didSet{
            amount.leftView            = UIImageView(image: #imageLiteral(resourceName: "rupee"))
            amount.leftView?.frame     = CGRect(x: 0, y: 5, width: 15 , height: 15)
            amount.leftViewMode        = .always
            amount.setBottomBorder(UIColor.lightGray,1.0)
        }
    }
    @IBOutlet weak var accounts             : UIButton!
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    @IBOutlet weak var noIdHdrL             : UILabel!
    @IBOutlet weak var clrBtn               : UIButton! {
        didSet{
            clrBtn.curvedButtonWithBorder(#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1))
        }
    }
    @IBOutlet weak var offerSelectionBtn    : UIButton! {
        didSet {
            offerSelectionBtn.isHidden = true
        }
    }
    @IBOutlet weak var recentView           : UIView! {
        didSet {
            recentView.isHidden = true
        }
    }
    @IBOutlet weak var historyTbl           : UITableView!
    @IBOutlet weak var historyTblHt         : NSLayoutConstraint! {
        didSet {
            historyTblHt.constant = 0
        }
    }
    @IBOutlet weak var amountInWords        : UILabel!
    @IBOutlet weak var payBtn               : UIButton!
    
    private let group = DispatchGroup()
    private var parserViewModel : ParserViewModel = ParserViewModel()
    var url: URL!
    var fetchedAccDetail:[Accountdetails]   = []
    var module                              = String()
    var opDrop                              = DropDown()
    lazy var opDropDowns: [DropDown]        = {return[self.opDrop]} ()
    var accDrop                             = DropDown()
    lazy var accDropDowns: [DropDown]       = {return[self.accDrop]} ()
    var cirDrop                             = DropDown()
    lazy var cirDropDowns: [DropDown]       = {return[self.cirDrop]} ()
    let fullCircles                         = fullCircleValues
    var fullOp                              = [String]()
    var AccountdetailsList                  = [String]()
    var opInt                               = Int()
    var rechargeTypeV                       = Int()
    var cirIndex                            = 11
    var customerId                          = String()
    var TokenNo                             = String()
    var rechargeType                        = String()
    var pin                                 = String()
    var opIndex                             = String()
    var opName                              = String()
    var oneAcc                              = String()
    var phoneNumb                           = String()
    var fromAccBranchLtxt                   = String()
    var offerAmount                         = String()
    var responseValueSettings               = [responseValue]()
    var errorResponseValueSettings          = [errorResponseValue]()
    var instanceOfEncryption: Encryption    = Encryption()
    var RechargeHistoryList                 = [NSDictionary]()
    var OwnAccountdetailsList               = [NSDictionary]()
    var ShareImg                            = UIImage()
    var ShareB                              = UIButton()
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // keyboard hide settings
        self.hideKeyboardWhenTappedAround()
        
       
       
        OwnAccounDetails()
       // circleApiList()
        
        opDropDowns.forEach { $0.dismissMode = .onTap }
        opDropDowns.forEach { $0.direction = .any }
        
        cirDropDowns.forEach { $0.dismissMode = .onTap }
        cirDropDowns.forEach { $0.direction = .any }
        
        accDropDowns.forEach { $0.dismissMode = .onTap }
        accDropDowns.forEach { $0.direction = .any }
        
        setOpDropDown(fullOp)
        operators.setTitle(fullOp[0], for: .normal)
        if let range = self.operators.currentTitle?.range(of: "\n")
        {
            self.opIndex = (self.operators.currentTitle?[range.upperBound...].trimmingCharacters(in: .whitespaces))!
            self.opName = self.operators.currentTitle!
        }
        setCirDropDown()
        circles.setTitle(fullCircles[10], for: .normal)
                
        rechaLabel.text = rechargeType
        
        phoneNum.setBottomBorder(UIColor.lightGray,1.0)
        bsnlAccNum.setBottomBorder(UIColor.lightGray,1.0)
        //udid generation
        UDID = udidGeneration.udidGen()
        if rechargeType == "Prepaid"
        {
            hideAndShowBsnlView(0.0)
            bsnlAccNum.isHidden  = true
            phoneNum.placeholder = "Mobile Number"
            noIdHdrL.text        = "Mobile Number"
            offerSelectionBtn.isHidden = false
            rechargeTypeV = 0
        }
        else if rechargeType == "PostPaid"
        {
            
            bsnlAccNum.isHidden  = false
            if opIndex == "36" || opIndex == "37"
            {
                hideAndShowBsnlView(40.0)
            }
            else{
                hideAndShowBsnlView(0.0)
            }
            phoneNum.placeholder = "Mobile Number"
            noIdHdrL.text        = "Mobile Number"
            rechargeTypeV = 1
        }
        else if rechargeType == "Landline"
        {
            
            bsnlAccNum.isHidden  = false
            if opIndex == "36" || opIndex == "37"
            {
                hideAndShowBsnlView(40.0)
            }
            else{
                hideAndShowBsnlView(0.0)
            }
            phoneNum.placeholder = "Phone Number"
            noIdHdrL.text        = "Phone Number"
            rechargeTypeV = 2
        }
        else if rechargeType == "DTH" || rechargeType == "Data Card"
        {
            if rechargeType == "DTH" {
                offerSelectionBtn.isHidden = false
                rechargeTypeV = 3
            }
            else{
                rechargeTypeV = 4
            }
            hideAndShowBsnlView(0.0)
            bsnlAccNum.isHidden  = true
            phoneNum.placeholder = "Subscriber ID"
            noIdHdrL.text        = "Subscriber ID"
        }
        blurView.isHidden          = true
        
        nextButtonInClick.load().addTarget(self,
                                           action: #selector(self.mobilePadNextAction(_:)),
                                           for: UIControl.Event.touchUpInside)
        if offerAmount != "" {
            amount.text = offerAmount
        }
    }
    
    //FIXME: ========= accountUIUpdateDetails() ==========
    fileprivate func accountUIUpdateDetails(info:[NSDictionary]) {
        parserViewModel.mainThreadCall {
            self.accounts.setTitle((info.first!.value(forKey: "AccountNumber") as? String ?? ""), for: .normal)
            self.RechargeListHistory()
            self.fromAccBranchLtxt = info.first!.value(forKey: "BranchName") as? String ?? ""
            self.setAccDropDown()
        }
        
    }
    
    
    //FIXME: =========OLD OWN_ACCOUNT_DETAILS_API() ==========
//    fileprivate func oldOwnBeneficiaryDetailApi() {
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
//        request.httpMethod  = "post"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody    = jsonData
//        let session = URLSession(configuration: .default,
//                                 delegate: self,
//                                 delegateQueue: nil)
//        let task = session.dataTask(with: request) { [self] data, response, error in
//            guard let data = data, error == nil else {
//                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                self.blurView.isHidden = true
//                self.activityIndicator.stopAnimating()
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    DispatchQueue.main.async { [weak self] in
//                        self!.blurView.isHidden = true
//                        self!.activityIndicator.stopAnimating()
//                    }
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//                    if sttsCode==0 {
//                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
//                        OwnAccountdetailsList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as! [NSDictionary]
//                        DispatchQueue.main.async {
//                            self.accounts.setTitle((OwnAccountdetailsList[0].value(forKey: "AccountNumber") as! String), for: .normal)
//                            self.fromAccBranchLtxt = self.OwnAccountdetailsList[0].value(forKey: "BranchName") as! String
//                            self.RechargeHistory()
//                        }
//                        for Accountdetails in OwnAccountdetailsList {
//                            AccountdetailsList.append(Accountdetails.value(forKey: "AccountNumber") as! String)
//                        }
//                        setAccDropDown()
//                    }
//                    else {
//
//                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as Any
//                        if OwnAccountdetails as? String != nil {
//                            let OwnAccountdetail  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
//                            let ResponseMessage =  OwnAccountdetail.value(forKey: "ResponseMessage") as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
//                            }
//                        }
//                        else {
//                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
//                            }
//                        }
//                    }
//                }
//                catch{
//                    DispatchQueue.main.async { [weak self] in
//                        self!.blurView.isHidden = true
//                        self!.activityIndicator.stopAnimating()
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
    
    //FIXME: ========= OWN_ACCOUNT_DETAILS_API() ==========
    fileprivate func OwnAccounDetails() {
         
        
        
        parserViewModel.ownAccountDetails(subMode: 1, token: TokenNo, custID: customerId) { getResult in
            
            switch getResult{
            case .success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas,modelKey:"OwnAccountdetails")
                    let exMsg = response.0 // error message
                    let modelInfo = response.1 as? NSDictionary ?? [:]    // get model response
                    
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg,vc:self) { status in
                        let ownAccountDList = modelInfo.value(forKey: "OwnAccountdetailsList") as? [NSDictionary] ?? []
                        self.OwnAccountdetailsList = ownAccountDList.compactMap{$0}
                        self.AccountdetailsList = []
                        self.AccountdetailsList.append(contentsOf: self.OwnAccountdetailsList.map{ $0.value(forKey: "AccountNumber") as? String ?? "" })
                        self.accountUIUpdateDetails(info: self.OwnAccountdetailsList)
                    }
                }
            case .failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
            }
            self.removeIndicator(showMessagge: false, message: "",activityView: self.activityIndicator, blurview: self.blurView)
            
            
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RechargeHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentRechListCell") as! recentRechListTableViewCell
        cell.recentOperatorL.text = (RechargeHistoryList[indexPath.row].value(forKey: "OperatorName") as! String)
        cell.recentNumberL.text = RechargeHistoryList[indexPath.row].value(forKey: "MobileNo") as? String
        cell.recentDateStatusL.text = "Last Recharge On \(RechargeHistoryList[indexPath.row].value(forKey: "RechargeDate") as! String) ,  \(RechargeHistoryList[indexPath.row].value(forKey: "StatusType") as! String)"
        cell.recentAmountL.setTitle("  \((RechargeHistoryList[indexPath.row].value(forKey: "RechargeRs") as! Double).currencyIN)  ", for: .normal)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        circles.setTitle(fullCircles[(RechargeHistoryList[indexPath.row].value(forKey: "Circle") as! Int)-1], for: .normal)
        cirIndex = (RechargeHistoryList[indexPath.row].value(forKey: "Circle") as! Int)
        

        opIndex = String(RechargeHistoryList[indexPath.row].value(forKey: "Operator") as! Int)
        opName = (RechargeHistoryList[indexPath.row].value(forKey: "OperatorName") as! String)
        operators.setTitle(opName, for: .normal)
        
        if rechargeType == "Landline" || rechargeType == "Postpaid"
        {
            if opIndex == "36" || opIndex == "37"
            {
                hideAndShowBsnlView(40.0)

            }
            else{
                hideAndShowBsnlView(0.0)
            }
        }
        amount.text = String(RechargeHistoryList[indexPath.row].value(forKey: "RechargeRs") as! Double)
        amountInWords.text = (RechargeHistoryList[indexPath.row].value(forKey: "RechargeRs") as! Double).InWords
        
        payBtn.setTitle("PAY\((RechargeHistoryList[indexPath.row].value(forKey: "RechargeRs") as! Double).currencyIN)", for: .normal)
        phoneNum.text = RechargeHistoryList[indexPath.row].value(forKey: "MobileNo") as? String
    }
    
    //FIXME: ========= RechargeHistoryHeight() ==========
    func RechargeHistoryHeight(count:Int){
        if count > 0{
            self.historyTblHt.constant = CGFloat((64 * RechargeHistoryList.count) + 40)
            self.recentView.isHidden = false
        }else{
            
            self.recentView.isHidden = true
            self.historyTblHt.constant = 0
            
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
  //FIXME: ========= RechargeListHistory() ==========
    fileprivate func RechargeListHistory(){
        // network reachability checking
        
        if Reachability.isConnectedToNetwork() {
            
            self.present(messages.msg(networkMsg), animated: true, completion: nil)
            return
        }
        
        let urlPath = "/AccountSummary/RechargeHistory"
        let arguMents = ["ReqMode"        : "21",
                        "Token"          : TokenNo,
                        "FK_Customer"    : customerId,
                        "BranchCode"     : "0",
                        "BankKey"        : BankKey,
                        "BankHeader"     : BankHeader]
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                  let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "RechargeHistory")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg,vc:self,msgShow: false) { status in
                        
                        let list = modelInfo.value(forKey: "RechargeHistoryList") as? [NSDictionary] ?? []
                        self.RechargeHistoryList = []
                        self.RechargeHistoryList = list.compactMap{$0}
                        
                        self.RechargeHistoryHeight(count: self.RechargeHistoryList.count)
                        
                        self.parserViewModel.mainThreadCall {
                            self.historyTbl.reloadData()
                        }
                        
                    }
                }
            case.failure(let errorCatched): self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
            }
            
            
            
            
        }
    }
    
//    func RechargeHistory() {
//        // network reachability checking
//
//        self.blurView.isHidden = false
//        self.activityIndicator.startAnimating()
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//            }
//            return
//        }
//        let url                     = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/RechargeHistory")!
//        let encryptedReqMode        = instanceOfEncryptionPost.encryptUseDES("21", key: "Agentscr")
//        let encryptedTocken         = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum         = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
//        let encryptedBranchCode     = instanceOfEncryptionPost.encryptUseDES("0", key: "Agentscr")
//        let encryptedRechargeTypeV     = instanceOfEncryptionPost.encryptUseDES(String(rechargeTypeV), key: "Agentscr")
//        let jsonDict            = ["ReqMode"        : encryptedReqMode,
//                                   "Token"          : encryptedTocken,
//                                   "FK_Customer"    : encryptedCusNum,
//                                   "BranchCode"     : encryptedBranchCode,
//                                   "RechargeType"   : encryptedRechargeTypeV,
//                                   "BankKey"        : BankKey,
//                                   "BankHeader"     : BankHeader]
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
//                    self!.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self!.blurView.isHidden = true
//                    self!.activityIndicator.stopAnimating()
//                }
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    DispatchQueue.main.async { [weak self] in
//                        self!.blurView.isHidden = true
//                        self!.activityIndicator.stopAnimating()
//                    }
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//                    if sttsCode==0 {
//                        let RechargeHistory  = responseJSONData.value(forKey: "RechargeHistory") as! NSDictionary
//                        RechargeHistoryList = RechargeHistory.value(forKey: "RechargeHistoryList") as! [NSDictionary]
//                        DispatchQueue.main.async { [weak self] in
////                            self!.historyTbl.reloadData()
////                            self!.historyTbl.contentSize.height = CGFloat((60 * RechargeHistoryList.count) + 40)
////                            self!.historyTbl.layoutIfNeeded()
//
//                            self!.historyTbl.reloadData()
//                            self!.historyTbl.layoutIfNeeded()
//
////                            var contentSizeTemp = self!.historyTbl.contentSize
//                            self!.historyTblHt.constant = CGFloat((64 * RechargeHistoryList.count) + 40)
////                            self!.historyTbl.contentSize = contentSizeTemp
//                            self!.recentView.isHidden = false
//                        }
//                    }
//                    else {
//                        DispatchQueue.main.async { [weak self] in
//                            self!.recentView.isHidden = true
//                            self!.historyTblHt.constant = 0
//                        }
////                        let RechargeHistory  = responseJSONData.value(forKey: "RechargeHistory") as Any
////                        if RechargeHistory as? NSDictionary != nil {
////                                let RechargeHistor  = responseJSONData.value(forKey: "RechargeHistory") as! NSDictionary
////                            let ResponseMessage =  RechargeHistor.value(forKey: "ResponseMessage") as! String
////
////                            DispatchQueue.main.async { [weak self] in
////                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
////                            }
////                        }
////                        else {
////                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String
////
////                            DispatchQueue.main.async { [weak self] in
////                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
////                            }
////                        }
//                    }
//                }
//                catch {
//                    DispatchQueue.main.async { [weak self] in
//                        self!.blurView.isHidden = true
//                        self!.activityIndicator.stopAnimating()
//                    }
//                }
//            }
//            else{
//                DispatchQueue.main.async { [weak self] in
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                }
//                print(httpResponse.statusCode)
//            }
//        }
//        task.resume()
//    }
    
    
    
    
    
    func keyboardWillShow()
    {
        
        if phoneNum.isFirstResponder
        {
            DispatchQueue.main.async { () -> Void in
                nextButtonInClick.ShowKeyboard(view: self.view)
            }
        }
        else if amount.isFirstResponder
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
    @objc func mobilePadNextAction(_ sender : UIButton){
        
        //Click action
        if phoneNum.isFirstResponder{
            amount.becomeFirstResponder()
        }
        else if amount.isFirstResponder{
            mobilePadNextButton.isHidden = true
            view.endEditing(true)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OffersBtn(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: "rechOffersSegue", sender: nil)
        }
    }
    
    func hideAndShowBsnlView(_ height: CGFloat)
    {
        bsnlViewHt.constant = height
        
//        let newConstraint = bsnlAccNumbConstraint.c
//        self.view.removeConstraint(bsnlAccNumbConstraint)
//        self.view.addConstraint(newConstraint)
        self.view.layoutIfNeeded()
    }
    func setOpDropDown(_ fullOperators:[String])
    {
        let Y = fullOperators.count * 15
        opDrop.anchorView      = operators
        opDrop.bottomOffset    = CGPoint(x:0, y:-Y)
        opDrop.dataSource      = fullOperators
        opDrop.backgroundColor = UIColor.white
        opDrop.selectionAction = {[weak self] (index, item) in
            self?.operators.setTitle(item, for: .normal)
            if let range = self?.operators.currentTitle?.range(of: "\n")
            {
                self?.opIndex = (self?.operators.currentTitle?[range.upperBound...].trimmingCharacters(in: .whitespaces))!
                self?.opName = (self?.operators.currentTitle!)!
                if self?.rechargeType == "Landline" 
                {
                    if self?.opIndex == "36" || self?.opIndex == "37"
                    {
                        self?.hideAndShowBsnlView(40.0)
                    }
                    else{
                        self?.hideAndShowBsnlView(0.0)
                    }
                }
            }
        }
    }
    
    func setCirDropDown()
    {
        let Y = fullCircles.count * 10
        cirDrop.anchorView      = circles
        cirDrop.bottomOffset    = CGPoint(x:0, y:-Y)
        cirDrop.dataSource      = fullCircles
        cirDrop.backgroundColor = UIColor.white
        cirDrop.selectionAction = {[weak self] (index, item) in
            self?.circles.setTitle(item, for: .normal)
            self?.cirIndex = (self?.cirDrop.indexForSelectedRow!)! + 1
        }
    }
    func setAccDropDown()
    {
        accDrop.anchorView      = accounts
        accDrop.bottomOffset    = CGPoint(x:0, y:0)
        accDrop.dataSource      = AccountdetailsList
        accDrop.backgroundColor = UIColor.white
        accDrop.selectionAction = {[weak self] (index, item) in
            self?.accounts.setTitle(item, for: .normal)
            self?.fromAccBranchLtxt = self?.OwnAccountdetailsList[index].value(forKey: "BranchName") as! String
        }
    }
    
    @IBAction func displayContacts(_ sender: UIButton)
    {
        addExistingContact()
    }
    
    func addExistingContact()
    {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact)
    {
        // You can fetch selected name and number in the following way
        
        // user phone number
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        if userPhoneNumbers.capacity == 0{
            showToast(message: "Mobile number is empty.", controller: self)
            phoneNum.text = ""
        }
        else{
            let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
            
            // user phone number string
            var primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
            //remove +91, " " & - from string
            primaryPhoneNumberStr = primaryPhoneNumberStr.replacingOccurrences(of: "+91", with: "", options: NSString.CompareOptions.literal, range: nil)
            primaryPhoneNumberStr = primaryPhoneNumberStr.trimmingCharacters(in: .whitespaces)
            primaryPhoneNumberStr = primaryPhoneNumberStr.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
            phoneNum.text = primaryPhoneNumberStr
        }
    }
    @IBAction func operatorsDropDown(_ sender: UIButton) {
        opDrop.show()
    }
    @IBAction func circleDropDown(_ sender: UIButton) {
        cirDrop.show()
    }
    
    @IBAction func accDropDown(_ sender: UIButton) {
        accDrop.show()
    }
    @IBAction func proceedToPay(_ sender: UIButton)
    {
        // selected acc number without module
        let acc = accounts.currentTitle!
        oneAcc = String(acc.dropLast(5))
        phoneNumb = self.phoneNum.text!

        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        // phone number checking
        if rechargeType == "Prepaid" || rechargeType == "Postpaid"
        {
            if phoneNumb.count != 10 || Int(phoneNumb) == nil
            {
                self.present(messages.msg(invalidMobNumMsg), animated: true, completion: nil)
                return
            }
        }
        else if rechargeType == "Landline"
        {
            if Int(phoneNumb) == nil || phoneNumb.count <= 10
            {
                self.present(messages.msg("Please enter valid Landline Number"), animated: true, completion: nil)
                return
            }
        }
        else if rechargeType == "DTH"
        {
            if Int(phoneNumb) == nil || (phoneNumb.count > 15 && phoneNumb.count < 5)
            {
                self.present(messages.msg("Please enter valid Subscriber ID"), animated: true, completion: nil)
                return
            }
        }
        // amount checking
        let amountValue = Double(self.amount.text!)
        if amountValue == nil
        {
            self.present(messages.msg(amountToReachargeMsg), animated: true, completion: nil)
            return
        }
        if amountValue! < 10.00 || amountValue! > 10000.00
        {
            self.present(messages.msg(amountLimitMsgForRech), animated: true, completion: nil)
            return
        }
        // bsnl acc number checking
        if rechargeType == "Landline"
        {
            if self.opIndex == "36" || self.opIndex == "37"
            {
                let bsnlAccValue = self.bsnlAccNum.text!
                if bsnlAccValue == "" || bsnlAccValue.count <= 5
                {
                    self.present(messages.msg("Please Enter Valid Account Number"), animated: true, completion: nil)
                    return
                }
            }
        }

        // acc detail expantion
        do
        {
            fetchedAccDetail = try coredatafunction.fetchObjectofAcc()
            for accDetail in fetchedAccDetail
            {
                if accDetail.value(forKey: "accNum")! as? String == oneAcc
                {
                    module = (accDetail.value(forKey: "accTypeShort")! as? String)!
                }
            }
        }
        catch
        {

        }
        RechargeConfirmation()
    }
    
    func RechargeConfirmation() {
        let customRCAlert = self.storyboard?.instantiateViewController(withIdentifier: "RConfirmationAlert") as! rechargeConfirmationAlertViewController
        customRCAlert.providesPresentationContextTransitionStyle = true
        customRCAlert.definesPresentationContext = true
        customRCAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customRCAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customRCAlert.delegate = self
        let oper    = String((operators.currentTitle!)).components(separatedBy: "\n")[0]
        let fromAcc = accounts.currentTitle!
        customRCAlert.fromAccLtxt = fromAcc
        customRCAlert.fromAccBranchLtxt = fromAccBranchLtxt
        customRCAlert.rechHdrLtxt = "Recharge Number & Details"
        customRCAlert.rechNumbLtxt = phoneNumb
        customRCAlert.rechNumDetailsLtxt = "\(String(oper)) \n\(String(describing: circles.currentTitle!))"
        customRCAlert.rechAmountHdrLtxt = "Recharge Amount"
        customRCAlert.rechAmountLtxt = Double(amount.text!)!.currencyIN
        customRCAlert.rechAmountDetailsLtxt = Double(amount.text!)!.InWords
        self.present(customRCAlert, animated: true, completion: nil)
    }
//    rechargeSuccessAlertViewController
    
    func RechargeSuccess(_ RTitle : String, _ RDate : String, _ RTime : String, _ transAmount : String) {
        let customRSAlert = self.storyboard?.instantiateViewController(withIdentifier: "rechargeSuccessAlert") as! rechargeSuccessAlertViewController
        customRSAlert.providesPresentationContextTransitionStyle = true
        customRSAlert.definesPresentationContext = true
        customRSAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customRSAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customRSAlert.delegate = self
        customRSAlert.sucHdrLtxt = RTitle
        customRSAlert.rechDateLtxt = "Date : \(RDate)"
        customRSAlert.rechTimeLtxt = "Time : \(RTime)"
        let fromAcc = accounts.currentTitle!
        let oper    = String((operators.currentTitle!)).components(separatedBy: "\n")[0]
        customRSAlert.fromAccLtxt = fromAcc
        customRSAlert.fromAccBranchLtxt = fromAccBranchLtxt
        customRSAlert.rechHdrLtxt = "Recharge Number & Details"
        customRSAlert.rechNumbLtxt = phoneNumb
        customRSAlert.rechNumDetailsLtxt = "\(String(oper)) \n\(String(describing: circles.currentTitle!))"
        customRSAlert.rechAmountHdrLtxt = "Recharge Amount"
        customRSAlert.rechAmountLtxt = Double(transAmount)!.currencyIN
        customRSAlert.rechAmountDetailsLtxt = Double(transAmount)!.InWords
        self.present(customRSAlert, animated: true, completion: nil)
    }
    
    func RechargeNumberApi() {
        
        // network reachability checking
       
        if Reachability.isConnectedToNetwork() {
            parserViewModel.mainThreadCall {
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        
        let arguMents = checkRecharge_Param(self.rechargeType)
        let urlPath = checkRecharge_url(self.rechargeType)
        
        
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            
            switch getResult{
            case.success(let datas):
                let modelKey = self.rechargeType == "Prepaid" ? "CommonRecharge" : "CommonRecharge"
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: modelKey)
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    let exMsg = response.0
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, showFailure: .show, vc: self, msgShow: true) { status in
                        let CDate = Date().currentDate(format: "dd-MM-yyyy")
                        let CTime = Date().currentDate(format: "h:mm a")
                        let responseMsg = modelInfo.value(forKey: "ResponseMessage") as? String ?? ""
                        let StatusMessage = responseMsg == "" ? exMsg : responseMsg
                        let RefID = modelInfo.value(forKey: "RefID") as? Int ?? 00
                        var transAmount = ""
                        DispatchQueue.main.async {
                            transAmount = self.amount.text!
                        }
                        
                        switch status{
                        case true:
                            print("success_info == \(modelInfo)")
                        case false :
                            print("error_info == \(modelInfo)")
                            switch statusCode{
                            case 1:
                                 
                                self.parserViewModel.mainThreadCall {
                                    self.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
                                  }
                            case 2:
                                self.parserViewModel.mainThreadCall {
                                    self.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
//                                    let successMsg = StatusMessage + " and your reference number is \(RefID)."
//                                    self.RechargeSuccess(successMsg, CDate, CTime, transAmount)
                                }
                            case 3:
                                
                                self.parserViewModel.mainThreadCall {
                                    let successMsg = StatusMessage + " and your reference number is \(RefID)."
                                    self.RechargeSuccess(successMsg, CDate, CTime, transAmount)
                                }
                                
                            default:
                                self.parserViewModel.mainThreadCall {
                                    self.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
                                }
                            }
                        }
                    }
                    
                }
            case.failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
            }
            self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
            
        }
        
    }
    
    //FIXME: - circleApiList()
    fileprivate func circleApiList(){
        
        // network reachability checking
       
        if Reachability.isConnectedToNetwork() {
            parserViewModel.mainThreadCall {
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        
        let urlPath = "/Recharge/RechargeCircleDetails"
        let arguMents = ["Reqmode":"31",
                         "Token":"\(self.TokenNo)",
                         "FK_Customer":"\(customerId)",
                         "BankKey":BankKey,
                         "BankHeader":BankHeader]
        
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "RechargeCircleDetails")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        
                    }
                    self.group.leave()
                }
            case.failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
                self.group.leave()
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            
            self.group.wait()
            DispatchQueue.main.async {
                print("successfully completed")
            }
        }
        
        
    }
    
    
    //FIXME: - SELECT PARAM BASED ON RECHARGE TYPE("PREPAID,POSTPAID,DTH,DATA CARD,LANDLINE")
    func checkRecharge_Param(_ rechargeType:String) -> [String:String]{
        
        
        var arguments = [String:String]()
        
        let RechargeNum = self.phoneNumb
        let Amount = self.amount.text ?? ""
        var BsnlAccNum = String()
        if self.rechargeType == "Landline"
        {
            
            BsnlAccNum = self.opIndex == "36" || self.opIndex == "37" ? self.bsnlAccNum.text ?? "" : "0000"
           
        }
        let Operator = self.opIndex
        let Circle = self.cirIndex
        let Acc = self.oneAcc
        let Module = self.module
        let Pin = self.pin
        
        let Type = "\(self.rechargeTypeV)"
        let OperatorName = self.rechargeType
    
        
        
        switch rechargeType{
        case "Prepaid" :
            arguments = ["MobileNumer":RechargeNum,
                         "Operator":Operator,
                         "Circle":"\(Circle)",
                         "Amount":Amount,
                         "AccountNo":Acc,
                         "Module":Module,
                         "Pin":Pin,
                         "Type":Type,
                         "OperatorName":OperatorName,
                         "token":self.TokenNo,
                         "BankKey":BankKey,
                         "BankHeader":BankHeader]
        case "DTH","Data Card":
            
            
            arguments = ["SUBSCRIBER_ID":RechargeNum,
                         "Operator":Operator,
                         "Circle":"\(Circle)",
                         "Amount":Amount,
                         "AccountNo":Acc,
                         "Module":Module,
                         "Pin":Pin,
                         "Type":Type,
                         "OperatorName":OperatorName,
                         "token":self.TokenNo,
                         "BankKey":BankKey,
                         "BankHeader":BankHeader]
            
        case "Landline","Postpaid":
            
            
            
            arguments = ["MobileNumer":RechargeNum,
                         "Operator":Operator,
                         "Circle":"\(Circle)",
                         "Circleaccount":BsnlAccNum,
                         "Amount":Amount,
                         "AccountNo":Acc,
                         "Module":Module,
                         "Pin":Pin,
                         "Type":Type,
                         "OperatorName":OperatorName,
                         "token":self.TokenNo,
                         "BankKey":BankKey,
                         "BankHeader":BankHeader]
            
        default:
            print("recharge argument not found")
        }
        
        
        return arguments
    }
    
    //FIXME: - CHECK_RECHARGE_URL() RECHARGE_TYPE("PREPAID,POSTPAID,DTH,DATA CARD,LANDLINE")
    func checkRecharge_url(_ rechargeType:String) -> String {
        var urlString = ""
        switch rechargeType{
        case "Prepaid": urlString = "/Recharge/MobileRecharge"
        case "DTH": urlString = "/Recharge/DTHRecharge"
        case "Data Card": urlString = "/Recharge/DTHRecharge"
        case "Landline": urlString = "/Recharge/POSTPaidBilling"
        case "Postpaid": urlString = "/Recharge/POSTPaidBilling"
        default:
            print("not matching")
        }
        return urlString
    }
    
    func RechargeNumber() { 
        
        //after user press ok, the following code will be execute
        self.blurView.isHidden = false
        self.activityIndicator.startAnimating()
        let encryptedNum = self.instanceOfEncryption.encryptUseDES(self.phoneNumb, key: "Agentscr") as String
        let encryptedAmount = self.instanceOfEncryption.encryptUseDES(self.amount.text, key: "Agentscr") as String
        var encryptedBsnlAccNum = String()
        if self.rechargeType == "Landline"
        {
            if self.opIndex == "36" || self.opIndex == "37"
            {
                encryptedBsnlAccNum = self.instanceOfEncryption.encryptUseDES(self.bsnlAccNum.text, key: "Agentscr") as String
            }
            else
            {
                encryptedBsnlAccNum = self.instanceOfEncryption.encryptUseDES("0000", key: "Agentscr") as String
            }
        }
        let encryptedOperator = self.instanceOfEncryption.encryptUseDES(self.opIndex, key: "Agentscr") as String
        let encryptedCircle = self.instanceOfEncryption.encryptUseDES(String(self.cirIndex), key: "Agentscr") as String
        let encryptedAcc = self.instanceOfEncryption.encryptUseDES(self.oneAcc, key: "Agentscr") as String
        let encryptedModule = self.instanceOfEncryption.encryptUseDES(self.module, key: "Agentscr") as String
        let encryptedPin = self.instanceOfEncryption.encryptUseDES(self.pin, key: "Agentscr") as String
        
        let encryptedType = self.instanceOfEncryption.encryptUseDES(String(self.rechargeTypeV), key: "Agentscr") as String
        let encryptedOperatorName = self.instanceOfEncryption.encryptUseDES(self.rechargeType, key: "Agentscr") as String
        if self.rechargeType == "Prepaid"
        {
            self.url = URL(string: BankIP + APIBaseUrlPart + "/MobileRecharge?MobileNumer=\(encryptedNum)&Operator=\(encryptedOperator)&Circle=\(encryptedCircle)&Amount=\(encryptedAmount)&AccountNo=\(encryptedAcc)&Module=\(encryptedModule)&Pin=\(encryptedPin)&Type=\(encryptedType)&OperatorName=\(encryptedOperatorName)&imei=\(UDID)&token=\(self.TokenNo)&BankKey=\(BankKey)")
        }
        else if self.rechargeType == "DTH" || self.rechargeType == "Data Card"
        {
            self.url = URL(string: BankIP + APIBaseUrlPart + "/DTHRecharge?SUBSCRIBER_ID=\(encryptedNum)&Operator=\(encryptedOperator)&Circle=\(encryptedCircle)&Amount=\(encryptedAmount)&AccountNo=\(encryptedAcc)&Module=\(encryptedModule)&Pin=\(encryptedPin)&Type=\(encryptedType)&OperatorName=\(encryptedOperatorName)&imei=\(UDID)&token=\(self.TokenNo)&BankKey=\(BankKey)")
        }
        else if self.rechargeType == "Landline" || self.rechargeType == "Postpaid"
        {
            if self.opIndex == "36" || self.opIndex == "37"
            {
                self.url = URL(string: BankIP + APIBaseUrlPart + "/POSTPaidBilling?MobileNumer=\(encryptedNum)&Operator=\(encryptedOperator)&Circle=\(encryptedCircle)&Circleaccount=\(encryptedBsnlAccNum)&Amount=\(encryptedAmount)&AccountNo=\(encryptedAcc)&Module=\(encryptedModule)&Pin=\(encryptedPin)&Type=\(encryptedType)&OperatorName=\(encryptedOperatorName)&imei=\(UDID)&token=\(self.TokenNo)&BankKey=\(BankKey)")
            }
            else
            {
               self.url = URL(string: BankIP + APIBaseUrlPart + "/POSTPaidBilling?MobileNumer=\(encryptedNum)&Operator=\(encryptedOperator)&Circle=\(encryptedCircle)&Circleaccount=\(encryptedBsnlAccNum)&Amount=\(encryptedAmount)&AccountNo=\(encryptedAcc)&Module=\(encryptedModule)&Pin=\(encryptedPin)&Type=\(encryptedType)&OperatorName=\(encryptedOperatorName)&imei=\(UDID)&token=\(self.TokenNo)&BankKey=\(BankKey)")
            }
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: self.url!) { data,response,error in
            if error != nil
            {
                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)

                self.activityIndicator.stopAnimating()
                self.blurView.isHidden = true
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
                        var transAmount = ""
                        DispatchQueue.main.async {
                            transAmount = self.amount.text!
                        }
                        let datas = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        print(datas)
                        let StatusCode = datas.value(forKey: "StatusCode") as! Int
                        let StatusMessage = datas.value(forKey: "StatusMessage") as! String
                        let CDate = Date().currentDate(format: "dd-MM-yyyy")
                        let CTime = Date().currentDate(format: "h:mm a")
                        
                        if StatusCode == 1
                        {
//                            let RefID = datas.value(forKey: "RefID") as! Int
//                            let MobileNumber = datas.value(forKey: "MobileNumber") as AnyObject
//                            let Amount = datas.value(forKey: "Amount") as AnyObject

                            DispatchQueue.main.async { [weak self] in
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                self?.RechargeSuccess(StatusMessage, CDate, CTime, transAmount)
                            }
                        }
                        else if StatusCode == 2
                        {

                            DispatchQueue.main.async { [weak self] in
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                self?.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
                            }
                        }
                        else if StatusCode == 3
                        {

                            DispatchQueue.main.async { [weak self] in
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                self?.present(messages.pendingMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!,self!), animated: true,completion: nil)

                            }
                        }
                        else{
                            DispatchQueue.main.async { [weak self] in
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                self?.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
                            }
                            
                        }
                    }
                    catch
                    {
                        DispatchQueue.main.async { [self] in
                            self.blurView.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    
    @IBAction func clear(_ sender: UIButton)
    {
        phoneNum.text = ""
        amount.text   = ""
        amountInWords.text = ""
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
        if textField.isEqual(amount)
        {
            let amn = amount.text!
            if amn.count != 0 && amn.count < 5 {
                amountInWordsTxt = Double(String(amn))!.InWords
                payAmount = (Double(amn)!.currencyIN)
                amountInWords.text = amountInWordsTxt
                payBtn.setTitle("PAY \(payAmount)", for: .normal)
            }
            else if amn.count > 4 {
                amountInWords.text = amountInWordsTxt
                payBtn.setTitle("PAY \(payAmount)", for: .normal)
            }
            else{
                payBtn.setTitle("PAY", for: .normal)
                amountInWords.text = ""
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
        if textField.isEqual(phoneNum)
        {
            if rechargeType == "Prepaid" || rechargeType == "Postpaid"
            {
                maxLength = 10
            }
            else if rechargeType == "DTH"
            {
                maxLength = 20
            }
            else if rechargeType == "Data Card"
            {
                maxLength = 20
            }
            else if rechargeType == "Landline"
            {
                maxLength = 13
            }
        }
        else if textField.isEqual(amount)
        {
            maxLength = 4
            
        }
        else if textField.isEqual(bsnlAccNum)
        {
            maxLength = 15
        }
        return newLength <= maxLength
    }
    
    @IBAction func amountEditing(_ sender: Any) {
        let amn = amount.text
        if amn?.count != 0 {
            amountInWords.text = Double(String(amn!))?.InWords
            payBtn.setTitle("PAY \(Double(amn!)!.currencyIN)", for: .normal)
        }
        else{
            payBtn.setTitle("PAY", for: .normal)
            amountInWords.text = ""
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "rechOffersSegue"
        {
            let vw = segue.destination as! RechOffersViewController
            opName = opName.components(separatedBy: " \n ")[0]
            vw.operIds      = opIndex
            vw.operatext    = opName
            vw.rechargeType = rechargeType
            vw.TokenNo      = TokenNo
            vw.pin          = pin
            vw.custID = customerId
            vw.delegate = self
            vw.fullOp       = fullOp
        }
    }

}

extension ReachargeViewController:custIDDelegate{
    func getCustId(id: String) {
        customerId = id
    }
    
    
}


extension ReachargeViewController: rechargeConfSuccessAlertDelegate{

    func ShareScreenShot(_ img: UIImage, _ Share : UIButton) {
        self.ShareImg = img
        self.ShareB = Share
    }
    
    //self.RechargeNumber()
    func okButtonTapped() {
        print("OK")

        self.RechargeNumberApi()
        
        
    }
    func cancelButtonTapped() {
        print("cancel")
    }
    
    func shareButtonTapped() {
        print("share")
        
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

}

