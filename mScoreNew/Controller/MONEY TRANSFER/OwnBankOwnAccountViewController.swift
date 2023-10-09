//
//  OwnBankOwnAccountViewController.swift
//  mScoreNew
//
//  Created by Perfect on 05/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import DropDown

class OwnBankOwnAccountViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var fromAccNoL: UILabel!
    @IBOutlet weak var fromBranchL: UILabel!
    @IBOutlet weak var fromBalance: UILabel!
    @IBOutlet weak var recAcc       : UIButton!{
        didSet{
            recAcc.setTitle("Select Account", for: .normal)
        }
    }
    @IBOutlet weak var balanceSplitTbl: UITableView!
    @IBOutlet weak var bSplitTableHt: NSLayoutConstraint!
    {
        didSet{
            bSplitTableHt.constant = 0
        }
    }
    @IBOutlet weak var dueAsOnView              : UIView!{
        didSet{
            dueAsOnView.isHidden = true
        }
    }
    @IBOutlet weak var dueAsOnViewHt: NSLayoutConstraint!{
        didSet{
            dueAsOnViewHt.constant = 4
        }
    }
    @IBOutlet weak var dueAsOnDate            : UILabel!
    @IBOutlet weak var dueAsOndata            : UILabel!
    @IBOutlet weak var dueAsOnAmount            : UILabel!

    @IBOutlet weak var amount           : UITextField!{
        didSet{
            amount.delegate         = self
            amount.setBottomBorder(UIColor.lightGray,1.0)
            
        }
    }
    @IBOutlet weak var amountInWords        : UILabel!

    @IBOutlet weak var needToChangePayableAmountBtn: UIButton!
    @IBOutlet weak var needToChangePayableAmountBtnHt: NSLayoutConstraint!
    @IBOutlet weak var noOfInstSelectionView: UIView!
    @IBOutlet weak var noOfInstSelectionViewHt: NSLayoutConstraint!
    @IBOutlet weak var instalmentNumbersBtn: UIButton!
    
    @IBOutlet weak var RemarkTF: UITextField! {
        didSet {
            RemarkTF.delegate         = self
            RemarkTF.setBottomBorder(UIColor.lightGray,1.0)
        }
    }
    
    @IBOutlet weak var payBtn               : UIButton!
    @IBOutlet weak var blurView         : UIView!{
        didSet{
            blurView.isHidden       = true
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{
        didSet{
            activityIndicator.stopAnimating()
        }
    }
    
    
    
    
    // set var for get data in the time of segue
    var TokenNo      = String()
    var customerId   = String()
    var pin          = String()
    var dmenuDic     = [String: String]()
    // values for reciver acc type drop down
    let recAccs     = [NSDictionary]()
    // acc dropdown settings
    var InstalmentDrop = DropDown()
    lazy var InstalmentDropDowns: [DropDown] = { return[self.InstalmentDrop] } ()
    // receiver acc type dropdown settings
    var recAccDrop = DropDown()
    lazy var recAccDropDowns: [DropDown] = { return[self.recAccDrop] } ()
    
    var instanceOfEncryption: Encryption = Encryption()
    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()

    var module                      = String()
    var payingFromAccDetails        = NSDictionary()
    var responseValueSettings       = [responseValue]()
    var errorResponseValueSettings  = [errorResponseValue]()
    var MaximumAmount               = Double()
    var ShareImg                    = UIImage()
    var ShareB                      = UIButton()
    var acc                         = String()
    var oneAcc                      = String()
    var receiverAccType             = String()
    var confAccNum                  = String()
    var OwnAccountdetailsList       = [NSDictionary]()
    var ToAccounts                  = ["Select Account"]
    var SplitUpDetails              = [NSDictionary]()
    var recBranchName               = String()
    var recFK_Account               = String()
    var recSubModule                = String()
    var Slimit                      = "0"
    var Advancelimit                = "0"
    var IsAdvance                   = "0"
    var pendinginsa                 = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // udid generation
        UDID = udidGeneration.udidGen()

        // keyboard hiding in the case of touch the screen.
        self.hideKeyboardWhenTappedAround()
        
        // rec acc type drop down value and drop down possitin settings
        recAccDropDowns.forEach { $0.dismissMode = .onTap }
        recAccDropDowns.forEach { $0.direction = .any }
        OwnAccountDetails()
        nextButtonInClick.load().addTarget(self, action: #selector(self.mobilePadNextAction(_:)),
                                           for: UIControl.Event.touchUpInside)
        fromAccNoL.text     = (payingFromAccDetails.value(forKey: "AccountNumber") as! String)
        fromBranchL.text    = (payingFromAccDetails.value(forKey: "BranchName") as! String)
        fromBalance.text    = (payingFromAccDetails.value(forKey: "Balance") as! Double).currencyIN
        
        InstalmentDropDowns.forEach { $0.dismissMode = .onTap }
        InstalmentDropDowns.forEach { $0.direction = .any }
        self.module = payingFromAccDetails.value(forKey: "typeShort") as? String ?? ""
        
    }
    
    func OwnAccountDetails() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.blurView.isHidden = false
        }
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.activityIndicator.stopAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/OwnAccounDetails")!
        
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("13", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedSubMode     = instanceOfEncryptionPost.encryptUseDES("2", key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
        
        let encryptedReqMode     = "13"
        let encryptedTocken     = TokenNo
        let encryptedSubMode     = "2"
        let encryptedCusNum     = customerId
        let jsonDict            = ["ReqMode" : encryptedReqMode,
                                   "Token" : encryptedTocken,
                                   "FK_Customer" : encryptedCusNum ,
                                   "SubMode":encryptedSubMode,
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
                DispatchQueue.main.async {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
                        OwnAccountdetailsList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as! [NSDictionary]
                        for OwnAccountdetailsL in OwnAccountdetailsList{
                            ToAccounts.append(OwnAccountdetailsL.value(forKey: "AccountNumber") as! String)
                        }
                        DispatchQueue.main.async {
                            self.setRecAccDropDown()
                        }
                    }
                    
                    else {
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as Any
                        if OwnAccountdetails as? NSDictionary != nil {
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
    
    @objc func mobilePadNextAction(_ sender : UIButton){
        
        //Click action
        if amount.isFirstResponder{
            RemarkTF.becomeFirstResponder()
        }
        else if RemarkTF.isFirstResponder{
            mobilePadNextButton.isHidden = true
            view.endEditing(true)
        }
    }

    // acc drop values settings
    func setRecAccDropDown()
    {
        recAccDrop.anchorView      = recAcc
        recAccDrop.bottomOffset    = CGPoint(x: 0, y:40)
        recAccDrop.dataSource      = ToAccounts
        recAccDrop.backgroundColor = UIColor.white
        recAccDrop.selectionAction = {[weak self] (index, item) in
            self?.recAcc.setTitle(item, for: .normal)
            
            self?.dueAsOnViewHt.constant = 4
            self?.dueAsOnView.isHidden = true
            self?.dueAsOnDate.text = ""
            self?.dueAsOndata.text = ""
            self?.dueAsOnAmount.text = ""
            self?.needToChangePayableAmountBtnHt.constant = 0
            self?.needToChangePayableAmountBtn.setTitle("", for: .normal)
            self?.bSplitTableHt.constant = 0
            self?.amount.text = ""
            self?.payBtn.setTitle("PAY", for: .normal)
            self?.amountInWords.text = ""
            self?.noOfInstSelectionView.isHidden = true
            self?.noOfInstSelectionViewHt.constant = 0
            self?.instalmentNumbersBtn.btnWithBorder(UIColor.clear.cgColor)
            self?.instalmentNumbersBtn.setTitle("", for: .normal)
            self?.view.layoutIfNeeded()
            
            if index != 0 {
                self?.receiverAccType = self?.OwnAccountdetailsList[index-1].value(forKey: "typeShort") as! String
                self?.recBranchName = self?.OwnAccountdetailsList[index-1].value(forKey: "BranchName") as! String
                self?.recFK_Account = String(self?.OwnAccountdetailsList[index-1].value(forKey: "FK_Account") as! Int)
                self?.recSubModule = self?.OwnAccountdetailsList[index-1].value(forKey: "SubModule") as! String
                self?.BalanceSplitUpDetails()
            }
            else {
                self!.SplitUpDetails = []
                self!.bSplitTableHt.constant =  0
                self!.balanceSplitTbl.reloadData()
                self!.view.layoutIfNeeded()
            }
        }
    }
var i = 0
    func BalanceSplitUpDetails() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.blurView.isHidden = false
        }
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.activityIndicator.stopAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/BalanceSplitUpDetails")!
        
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("24", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedSubModule     = instanceOfEncryptionPost.encryptUseDES(recSubModule, key: "Agentscr")
//        let encryptedFK_Account     = instanceOfEncryptionPost.encryptUseDES(recFK_Account, key: "Agentscr")
        
        let encryptedReqMode     = "24"
        let encryptedTocken     = TokenNo
        let encryptedSubModule     = recSubModule
        let encryptedFK_Account     = recFK_Account
        let jsonDict            = ["ReqMode" : encryptedReqMode,
                                   "Token" : encryptedTocken,
                                   "FK_Account" : encryptedFK_Account ,
                                   "SubModule":encryptedSubModule,
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
                DispatchQueue.main.async {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    SplitUpDetails = []
                    print(responseJSONData)
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.blurView.isHidden = true
                        }
                        i = 0

                        let BalanceSplitUpDetails  = responseJSONData.value(forKey: "BalanceSplitUpDetails") as! NSDictionary
                        let Data = BalanceSplitUpDetails.value(forKey: "Data") as! [NSDictionary]
                        SplitUpDetails = Data[0].value(forKey: "Details") as! [NSDictionary]
                        DispatchQueue.main.async { [weak self] in
                            self?.balanceSplitTbl.reloadData()
                        }

                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.blurView.isHidden = true
                            self.bSplitTableHt.constant = CGFloat((self.SplitUpDetails.count) * 35)
                            self.view.layoutIfNeeded()
                        
                            if self.recSubModule == "PDRD" || self.recSubModule == "ODGD" {
                                self.amount.isUserInteractionEnabled = false
                                self.Slimit = self.SplitUpDetails[0].value(forKey: "Value") as! String
                                if Int(self.Slimit)! > 0 {
                                    self.needToChangePayableAmountBtnHt.constant = 40
                                    self.needToChangePayableAmountBtn.setTitle("Need To Change Payable Amount", for: .normal)
                                    self.pendinginsa = []
                                    self.IsAdvance = "0"
                                    for i in 1...Int(self.Slimit)! {
                                        self.pendinginsa.append(String(i))
                                    }
                                }
                                else if Int(self.Slimit)! == 0  && self.Advancelimit != "0"{
                                    self.needToChangePayableAmountBtnHt.constant = 40
                                    self.needToChangePayableAmountBtn.setTitle("Need To Pay Advance Amount", for: .normal)
                                    self.pendinginsa = []
                                    self.IsAdvance = "1"

                                    for i in 1...Int(self.Advancelimit)! {
                                        self.pendinginsa.append(String(i))
                                    }
                                    
                                    
                                }
                                else{
                                    self.needToChangePayableAmountBtnHt.constant = 0
                                    self.needToChangePayableAmountBtn.setTitle("", for: .normal)
                                    
                                }
                            }
                            else{
                                self.amount.isUserInteractionEnabled = true
                                self.needToChangePayableAmountBtnHt.constant = 0
                                self.needToChangePayableAmountBtn.setTitle("", for: .normal)
                                
                            }
                            
                        }
                        
                    }
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                        let BalanceSplitUpDetails  = responseJSONData.value(forKey: "BalanceSplitUpDetails") as Any
                        if BalanceSplitUpDetails as? NSDictionary != nil {
                                let BalanceSplitUpDetail  = responseJSONData.value(forKey: "BalanceSplitUpDetails") as! NSDictionary
                            let ResponseMessage =  BalanceSplitUpDetail.value(forKey: "ResponseMessage") as! String

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
    
    func setInstalmentDropDowns() {
        InstalmentDrop.anchorView      = instalmentNumbersBtn
        InstalmentDrop.bottomOffset    = CGPoint(x: 0, y:40)
        InstalmentDrop.dataSource      = pendinginsa
        InstalmentDrop.backgroundColor = UIColor.white
        InstalmentDrop.selectionAction = {[weak self] (index, item) in
            self?.instalmentNumbersBtn.setTitle(item, for: .normal)
            self?.GetInstalmmentRemittanceAmount(String(index+1))
        }
    }
    
    @IBAction func NeedToChangeAmount(_ sender: UIButton) {
        if noOfInstSelectionView.isHidden == true {
            noOfInstSelectionView.isHidden = false
            noOfInstSelectionViewHt.constant = 30
            instalmentNumbersBtn.btnWithBorder(UIColor.black.cgColor)
            instalmentNumbersBtn.setTitle(pendinginsa[0], for: .normal)
            setInstalmentDropDowns()
            GetInstalmmentRemittanceAmount("1")
        }
        else {
            noOfInstSelectionView.isHidden = true
            noOfInstSelectionViewHt.constant = 0
            instalmentNumbersBtn.btnWithBorder(UIColor.clear.cgColor)
            self.instalmentNumbersBtn.setTitle("", for: .normal)
        }
    }
    
    @IBAction func RemittanceSettingsBtn(_ sender: UIButton) {
        InstalmentDrop.show()
    }
    
    
    func GetInstalmmentRemittanceAmount(_ InstalmentCount : String) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.blurView.isHidden = false
        }
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.activityIndicator.stopAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/GetInstalmmentRemittanceAmount")!
        
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("25", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedSubModule     = instanceOfEncryptionPost.encryptUseDES(recSubModule, key: "Agentscr")
//        let encryptedFK_Account     = instanceOfEncryptionPost.encryptUseDES(recFK_Account, key: "Agentscr")
//
//        let encryptedIsAdvance    = instanceOfEncryptionPost.encryptUseDES(IsAdvance, key: "Agentscr")
//        let encryptedInstalmentCount     = instanceOfEncryptionPost.encryptUseDES(InstalmentCount, key: "Agentscr")
        
        let encryptedReqMode     = "25"
        let encryptedTocken     = TokenNo
        let encryptedSubModule     = recSubModule
        let encryptedFK_Account     = recFK_Account
        
        let encryptedIsAdvance    = IsAdvance
        let encryptedInstalmentCount     = InstalmentCount
        let jsonDict            = ["ReqMode" : encryptedReqMode,
                                   "Token" : encryptedTocken,
                                   "FK_Account" : encryptedFK_Account ,
                                   "SubModule":encryptedSubModule,
                                   "IsAdvance" : encryptedIsAdvance ,
                                   "InstalmentCount":encryptedInstalmentCount,
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
                DispatchQueue.main.async {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        
                        let GetInstalmmentRemittanceAmount  = responseJSONData.value(forKey: "GetInstalmmentRemittanceAmount") as! NSDictionary
                        let RemittanceAmount = GetInstalmmentRemittanceAmount.value(forKey: "RemittanceAmount") as! Double
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.blurView.isHidden = true
                            var SRemittanceAmount = String(RemittanceAmount)
                            if let dotRange = SRemittanceAmount.range(of: ".") {
                                SRemittanceAmount.removeSubrange(dotRange.lowerBound..<SRemittanceAmount.endIndex)
                            }
                            self.amount.text = SRemittanceAmount
                            self.amountInWordsTxt = RemittanceAmount.InWords
                            self.payAmount = (RemittanceAmount.currencyIN)
                            self.amountInWords.text = self.amountInWordsTxt
                            self.payBtn.setTitle("PAY \(self.payAmount)", for: .normal)
                        }
                        
                    }
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.amount.text = ""
                            
                            self?.amountInWords.text = ""
                            self?.payBtn.setTitle("PAY", for: .normal)
                        }
                        let GetInstalmmentRemittanceAmount  = responseJSONData.value(forKey: "GetInstalmmentRemittanceAmount") as Any
                        if GetInstalmmentRemittanceAmount as? NSDictionary != nil {
                                let GetInstalmmentRemittanceAmoun  = responseJSONData.value(forKey: "GetInstalmmentRemittanceAmount") as! NSDictionary
                            let ResponseMessage =  GetInstalmmentRemittanceAmoun.value(forKey: "ResponseMessage") as! String

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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SplitUpDetails.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (SplitUpDetails[indexPath.row].value(forKey: "Key") as! String) == "BalanceInstallment" || (SplitUpDetails[indexPath.row].value(forKey: "Key") as! String) == "NetAmount" {
            i = i + 1
            DispatchQueue.main.async { [self] in
                self.bSplitTableHt.constant = CGFloat((self.SplitUpDetails.count - self.i) * 35)
                
                print("height of table -- \(self.bSplitTableHt.constant)")
            }
        }
        if (SplitUpDetails[indexPath.row].value(forKey: "Key") as! String) == "BalanceInstallment"{
            Advancelimit = (SplitUpDetails[indexPath.row].value(forKey: "Value") as! String)
            return 0
        }
        if (SplitUpDetails[indexPath.row].value(forKey: "Key") as! String) == "NetAmount" {
            self.dueAsOnViewHt.constant = 40
            let CDate = Date().currentDate(format: "dd-MM-yyyy")
            self.dueAsOnView.isHidden = false
            self.dueAsOnDate.text = "Due As On \(CDate)"
            self.dueAsOndata.text = ":"
            var NetAmount = (SplitUpDetails[indexPath.row].value(forKey: "Value") as! String)
            self.dueAsOnAmount.text = NetAmount

            if let dotRange = NetAmount.range(of: ".") {
                NetAmount.removeSubrange(dotRange.lowerBound..<NetAmount.endIndex)
            }
            self.amount.text = NetAmount
            amountInWordsTxt = Double(NetAmount)!.InWords
            payAmount = (Double(NetAmount)!.currencyIN)
            self.amountInWords.text = amountInWordsTxt
            self.payBtn.setTitle("PAY \(payAmount)", for: .normal)
            self.view.layoutIfNeeded()
            return 0
        }
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "balanceSplitCell") as! balanceSplitTableViewCell
        if (SplitUpDetails[indexPath.row].value(forKey: "Key") as! String) == "Pending Installment" ||  (SplitUpDetails[indexPath.row].value(forKey: "Key") as! String) == "PendingInstallment"{
            //cell.backgroundColor = #colorLiteral(red: 0.6358288616, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            cell.backgroundColor = .red
        }
        cell.Key.text = (SplitUpDetails[indexPath.row].value(forKey: "Key") as! String)
        cell.Value.text = (SplitUpDetails[indexPath.row].value(forKey: "Value") as! String)
        return cell
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func receiverAcc(_ sender: UIButton)
    {
        recAccDrop.show()
    }
    
    @IBAction func ReSet(_ sender: UIButton) {
        
        self.amount.text!           = ""
        amountInWords.text          = ""
        self.RemarkTF.text!         = ""
        payBtn.setTitle("PAY", for: .normal)
        viewDidLoad()
    }
    
    
    @IBAction func submit(_ sender: UIButton)
    {
        // selected acc number without module
        acc             = payingFromAccDetails.value(forKey: "AccountNumber") as! String
        oneAcc          = String(acc.dropLast(5))
       
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        // acc detail expantion
        do
        {
            let fetchedAccDetail = try coredatafunction.fetchObjectofAcc()
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
        if recAcc.currentTitle == "Select Account"{
            showToast(message: "Please Select Paying To Account Number.", controller: self)
            return
        }
        
        let fromAccount = fromAccNoL.text!
        if fromAccount == recAcc.currentTitle{
            
            showToast(message: "Paying from and to account cannot be same", controller: self)
            return
            
        }
        if amount.text?.count == 0 {
            showToast(message: "Please Enter Valid Amount.", controller: self)
            return
        }
        var recAccoun = recAcc.currentTitle
        if let spaceRange = recAccoun!.range(of: " ") {
            recAccoun!.removeSubrange(spaceRange.lowerBound..<recAccoun!.endIndex)
        }
        else if let dotRange = recAccoun!.range(of: "(") {
            recAccoun!.removeSubrange(dotRange.lowerBound..<recAccoun!.endIndex)
        }
        self.confAccNum = recAccoun!
        self.PaymentConfirmation()

    }
    
    func FundTransferIntraBank() {
        
        DispatchQueue.main.async { [weak self] in
            self?.blurView.isHidden  = false
            self?.activityIndicator.startAnimating()
        }
//        let encryptedFromAcc    = self.instanceOfEncryption.encryptUseDES(oneAcc,
//                                                                          key: "Agentscr") as String
//        let encryptedFromModule = self.instanceOfEncryption.encryptUseDES(self.module ,
//                                                                          key: "Agentscr") as String
//        let encryptedRecAccType = self.instanceOfEncryption.encryptUseDES(receiverAccType ,
//                                                                          key: "Agentscr") as String
//        let encryptedToAcc      = self.instanceOfEncryption.encryptUseDES(confAccNum ,
//                                                                          key: "Agentscr") as String
//        let encryptedAmount     = self.instanceOfEncryption.encryptUseDES(self.amount.text! ,
//                                                                          key: "Agentscr") as String
//        let encryptedPin        = self.instanceOfEncryption.encryptUseDES(self.pin ,
//                                                                          key: "Agentscr") as String
//        let encryptedQrCode     = self.instanceOfEncryption.encryptUseDES("novalue" ,
//                                                                          key: "Agentscr") as String
//        let encryptedRemark     = self.instanceOfEncryption.encryptUseDES(RemarkTF.text ,
//                                                                          key: "Agentscr") as String
        
        let encryptedFromAcc    = oneAcc
                                                                         
        let encryptedFromModule = self.module
        let encryptedRecAccType = receiverAccType
        let encryptedToAcc      = confAccNum
                                                                          
        let encryptedAmount     = self.amount.text!
                                                                          
        let encryptedPin        = self.pin
                                                                          
        let encryptedQrCode     = "novalue"
                                                                          
        let encryptedRemark     = RemarkTF.text!
        
        let urlstring = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/FundTransferIntraBank")
        
        var Request = URLRequest(url: urlstring!)
        let parameter = ["AccountNo":encryptedFromAcc,"Module":"\(encryptedFromModule)","ReceiverModule":"\(encryptedRecAccType)","amount":"\(encryptedAmount)","ReceiverAccountNo":"\(encryptedToAcc)","Pin":"\(encryptedPin)","QRCode":"\(encryptedQrCode)","Remark":"\(encryptedRemark)","imei":"\(UDID)","token":"\(self.TokenNo)","BankKey":"\(BankKey)","BankHeader":"\(BankHeader)"]
        
        print(parameter)
        Request.httpMethod = "POST"
        Request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
//        let jsonData  = try! JSONSerialization.data(withJSONObject: parameter, options: [])
//        Request.httpBody =  jsonData
        
        Request.addValue("application/json", forHTTPHeaderField: "Accept")
          
          do {
            // convert parameters to Data and assign dictionary to httpBody of request
              Request.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
          } catch let error {
            print(error.localizedDescription + " (json error)")
            return
          }
        
                                                                          
      
        
        
        //let url = URL(string: BankIP + APIBaseUrlPart + "/FundTransferIntraBank?AccountNo=\(encryptedFromAcc)&Module=\(encryptedFromModule)&ReceiverModule=\(encryptedRecAccType)&ReceiverAccountNo=\(encryptedToAcc)&amount=\(encryptedAmount)&Pin=\(encryptedPin)&QRCode=\(encryptedQrCode)&Remark=\(encryptedRemark)&imei=\(UDID)&token=\(self.TokenNo)&BankKey=\(BankKey)")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: Request) { data,response,error in
            if error != nil
            {
                DispatchQueue.main.async{
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self.blurView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
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
                        let datas       = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        
                        let info  = datas.value(forKey: "FundTransferIntraBankList") as? NSDictionary ?? [:]
                        let detailList = info.value(forKey: "FundTransferIntraBankList") as? [NSDictionary] ?? []     
                        let StatusCode  = datas.value(forKey: "StatusCode") as? Int ?? 0
                        let StatusMessage = info.value(forKey: "StatusMessage") as? String ?? ""
                   let EXMessage = datas.value(forKey: "EXMessage") as? String ?? ""
                        let RefID       = detailList.first?.value(forKey: "RefID") as? Int ?? 00
                        let CDate = detailList.first?.value(forKey: "TransDate") as? String ??  Date().currentDate(format: "dd-MM-yyyy")
                        let CTime = Date().currentDate(format: "h:mm a")
                        if StatusCode == 1
                        {
                            DispatchQueue.main.async {
                                self.blurView.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.amount.text!                = ""
                                self.amountInWords.text          = ""
                                self.RemarkTF.text!              = ""
                                self.payBtn.setTitle("PAY", for: .normal)
                                self.PaymentSuccess(StatusMessage, String(RefID), CDate, CTime,transAmount,payeeAcc: encryptedToAcc, recActype: encryptedRecAccType)
                                
                            }
                        }
                        else if StatusCode == 4
                        {
                            
                            DispatchQueue.main.async {
                                self.blurView.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.present(messages.errorMsgWithAppIcon(EXMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
                            }
                        }
                        else if StatusCode == 5
                        {
                            DispatchQueue.main.async {
                                self.blurView.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.present(messages.errorMsgWithAppIcon(EXMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
                            }
                        }
                       
                        else
                        {
                            DispatchQueue.main.async { [weak self] in
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                self?.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
                            }
                        }
                    }
                    catch{
                        DispatchQueue.main.async{
                            self.blurView.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func PaymentConfirmation() {
        let customRCAlert = self.storyboard?.instantiateViewController(withIdentifier: "RConfirmationAlert") as! rechargeConfirmationAlertViewController
        customRCAlert.providesPresentationContextTransitionStyle = true
        customRCAlert.definesPresentationContext = true
        customRCAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customRCAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customRCAlert.delegate = self
        let fromAcc = "A/C No : \(payingFromAccDetails.value(forKey: "AccountNumber") as! String)"
        customRCAlert.fromAccLtxt = fromAcc
        customRCAlert.fromAccBranchLtxt = "Branch : \(payingFromAccDetails.value(forKey: "BranchName") as! String) \nAvailable Balance : \((payingFromAccDetails.value(forKey: "Balance") as! Double).currencyIN)"
        customRCAlert.rechHdrLtxt = "Paying To "
        customRCAlert.rechNumbLtxt = "A/C No : \(recAcc.currentTitle ?? "")"
        customRCAlert.rechNumDetailsLtxt = "Branch : \(recBranchName)"
        customRCAlert.rechAmountHdrLtxt = "Payable Amount"
        customRCAlert.rechAmountLtxt = Double(amount.text!)!.currencyIN
        customRCAlert.rechAmountDetailsLtxt = Double(amount.text!)!.InWords
        self.present(customRCAlert, animated: true, completion: nil)
    }
    
        
    func PaymentSuccess(_ RTitle : String,_ RefNo : String, _ RDate : String, _ RTime : String, _ transAmount : String,payeeAcc:String = "",recActype:String = "") {
        let customRSAlert = self.storyboard?.instantiateViewController(withIdentifier: "rechargeSuccessAlert") as! rechargeSuccessAlertViewController
        customRSAlert.providesPresentationContextTransitionStyle = true
        customRSAlert.definesPresentationContext = true
        customRSAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customRSAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customRSAlert.delegate = self
        customRSAlert.sucHdrLtxt = RTitle
        customRSAlert.rechDateLtxt = "Date : \(RDate)"
        customRSAlert.rechTimeLtxt = "Time : \(RTime)"
        let fromAcc = "A/C No : \(payingFromAccDetails.value(forKey: "AccountNumber") as! String)"
        customRSAlert.rechReffNoLtxt = "Reff No : \(RefNo)"
        customRSAlert.fromAccLtxt = fromAcc
        customRSAlert.fromAccBranchLtxt = "Branch : \(payingFromAccDetails.value(forKey: "BranchName") as! String)"
        customRSAlert.rechHdrLtxt = "Paying To "
        customRSAlert.rechNumbLtxt = "A/C No :  \(confAccNum == "" ? payeeAcc : confAccNum) (\(receiverAccType == "" ? recActype : receiverAccType))"
        customRSAlert.rechNumDetailsLtxt = ""
        customRSAlert.rechAmountHdrLtxt = "Paid Amount"
        customRSAlert.rechAmountLtxt = Double(transAmount)!.currencyIN
        customRSAlert.rechAmountDetailsLtxt = Double(transAmount)!.InWords
        self.present(customRSAlert, animated: true, completion: nil)
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
        if textField.isEqual(amount)
        {
            maxLength = 5
        }
        else if textField.isEqual(RemarkTF)
        {
            maxLength = 5000
        }
        return newLength <= maxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(amount) || textField.isEqual(RemarkTF)
        {
            moveTextField(textField, moveDistance: -150, up: true)
        }
        
        if textField.isEqual(amount) || textField.isEqual(RemarkTF)
        {
            textField.setBottomBorder(greenColour,2.0)
        }
        self.keyboardWillShow()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEqual(amount) || textField.isEqual(RemarkTF)
        {
            moveTextField(textField, moveDistance: -150, up: false)
        }
        if textField.isEqual(amount) || textField.isEqual(RemarkTF)
        {
            textField.setBottomBorder(UIColor.lightGray,1.0)
        }

    }
    
    var amountInWordsTxt = String()
    var payAmount = String()
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.isEqual(amount)
        {
            let amn = amount.text!
            if amn.count != 0 && amn.count < 6 {
                amountInWordsTxt = Double(String(amn))!.InWords
                payAmount = (Double(amn)!.currencyIN)
                amountInWords.text = amountInWordsTxt
                payBtn.setTitle("PAY \(payAmount)", for: .normal)
            }
            else if amn.count > 5 {
                amountInWords.text = amountInWordsTxt
                payBtn.setTitle("PAY \(payAmount)", for: .normal)
            }
            else{
                payBtn.setTitle("PAY", for: .normal)
                amountInWords.text = ""
            }
        }
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool)
    {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func keyboardWillShow()
    {
        if amount.isFirstResponder
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

}

extension OwnBankOwnAccountViewController: rechargeConfSuccessAlertDelegate{

    func ShareScreenShot(_ img: UIImage, _ Share : UIButton) {
        self.ShareImg = img
        self.ShareB = Share
    }
    
    
    func okButtonTapped() {
        print("OK")

        self.FundTransferIntraBank()
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
