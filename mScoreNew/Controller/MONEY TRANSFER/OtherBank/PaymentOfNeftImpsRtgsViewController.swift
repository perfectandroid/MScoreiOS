
//
//  PaymentOfNeftImpsRtgsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 10/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import DropDown

class PaymentOfNeftImpsRtgsViewController: NetworkManagerVC,UITextFieldDelegate
{
    @IBOutlet weak var backButton           : UIBarButtonItem!
    @IBOutlet weak var accounts             : UIButton!
    @IBOutlet weak var secName              : UILabel!
    @IBOutlet weak var beneficiaryName      : UITextField!
    @IBOutlet weak var beneficiaryAccNo     : UITextField!
    @IBOutlet weak var confirmBeneAccNo     : UITextField!
    @IBOutlet weak var ifsCode              : UITextField!
    @IBOutlet weak var BeneficiarySelection : UIButton!
    @IBOutlet weak var beneficiaryImg       : UIImageView!
    @IBOutlet weak var beneficiaryLabel     : UILabel!
    @IBOutlet weak var amount               : UITextField!
    @IBOutlet weak var amountInWords        : UILabel!
    @IBOutlet weak var payBtn               : UIButton!
    @IBOutlet weak var clear                : UIButton!
    @IBOutlet weak var submit               : UIButton!
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    @IBOutlet weak var beneButtonHeight     : NSLayoutConstraint!
    @IBOutlet weak var clrBtnWidth          : NSLayoutConstraint!
    
    // set var for get data in the time of segue
    var TokenNo                = String()
    var customerId             = String()
    var pin                    = String()
    var sectionName            = String()
    var name                   = String()
    var acc                    = String()
    var ifsc                   = String()
    var module                 = String()
    var beneAdd                = "0"
    var paymentDetails         = [ImpsNeftRtgsPaymentValues]()
    var statuscode             = Int()
    var OwnAccountdetailsList  = [NSDictionary]()
    var AccountdetailsList     = [String]()
    var fromAccBranchLtxt      = String()
    var SubMode                = String()
    var mode                   = String()
    var oneAcc                 = String()
    var ShareImg               = UIImage()
    var ShareB                 = UIButton()
    var Balance                = String()
    var fromAcc                = String()
    var confirmBeneAccNoT      = String()
    var amountT                = String()
    
    // dropdown model settings
    var accDrop = DropDown()
    lazy var accDropDowns: [DropDown] = {return[self.accDrop]} ()
    // Encryption
    var instanceOfEncryption: Encryption = Encryption()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        accounts.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 2)

        // Do any additional setup after loading the view.
        textfieldBorder()
        blurView.isHidden           = true
        // button corner radius
        clear.layer.cornerRadius    = 5
        submit.layer.cornerRadius   = 5
        //  textfield count is setting
        beneficiaryName.delegate    = self
        beneficiaryAccNo.delegate   = self
        confirmBeneAccNo.delegate   = self
        ifsCode.delegate            = self
        amount.delegate             = self
        // keyboard hiding in the case of touch the screen.
        self.hideKeyboardWhenTappedAround()
        // number typing in the text field is not shown
        beneficiaryAccNo.isSecureTextEntry = !beneficiaryAccNo.isSecureTextEntry
        secName.text = sectionName
        if sectionName == "" {
            SubMode = "1"
        }
        switch sectionName {
            case "IMPS":
                SubMode = "1"
            case "NEFT":
                SubMode = "2"
            case "RTGS":
                SubMode = "3"
            default:
                SubMode = "0"
        }
        // button border settings
        accounts.backgroundColor    = .clear
        accounts.layer.cornerRadius = 5
        accounts.layer.borderWidth  = 1
        accounts.layer.borderColor  = lightGreyColor.cgColor
        
        if name != ""
        {
            beneficiaryName.isUserInteractionEnabled    = false
            beneficiaryAccNo.isUserInteractionEnabled   = false
            confirmBeneAccNo.isUserInteractionEnabled   = false
            ifsCode.isUserInteractionEnabled            = false
            beneficiaryName.text                        = name
            beneficiaryAccNo.text                       = acc
            confirmBeneAccNo.text                       = acc
            ifsCode.text                                = ifsc
            clear.isHidden                              = true
            
            let newConstraint = clrBtnWidth.constraintWithMultiplier(0.0)
            self.view.removeConstraint(clrBtnWidth)
            self.view.addConstraint(newConstraint)
            self.view.layoutIfNeeded()
            beneButtonHeight.constant = 0
        }
        // dropdown settings
        accDropDowns.forEach { $0.dismissMode = .onTap }
        accDropDowns.forEach { $0.direction = .any }
        // set dropdowns
       // OwnAccounDetails()
        OwnAccountDetails()
//        setAccDropDown()
        // acc button settings
//        let str = fullAccounts.buttonTitle()
//        if str.rangeOfCharacter(from: CharacterSet(charactersIn: "SB")) != nil
//        {
//            accounts.setTitle(fullAccounts.buttonTitle(), for: .normal)
//        }
//        else if str.rangeOfCharacter(from: CharacterSet(charactersIn: "CA")) != nil
//        {
//            accounts.setTitle(fullAccounts.buttonTitle(), for: .normal)
//        }
//        else if str.rangeOfCharacter(from: CharacterSet(charactersIn: "OD")) != nil
//        {
//            accounts.setTitle(fullAccounts.buttonTitle(), for: .normal)
//        }
//
//        else
//        {
//            accounts.setTitle(fullAccounts.SbCaOdAcc()[0], for: .normal)
//        }
        // udid generation
        UDID = udidGeneration.udidGen()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayIndicator() {
        
        
        
        DispatchQueue.main.async {
            
            self.activityIndicator.startAnimating()
            self.blurView.isHidden = false
        }
      
        
    }
    
    func removeIndicator(showMessagge:Bool,message:String){
        
        DispatchQueue.main.async{
            if showMessagge == true{
                self.present(messages.msg(message), animated: true, completion: nil)
            }
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func fetchModule(accountNo:String,list:[NSDictionary]) -> String? {
        
        let searchAccount = list.filter { item in
            let accountSearch  = item.value(forKey: "AccountNumber") as? String ?? ""
            return accountNo == accountSearch
        }
        
        let searchedModule = searchAccount[0].value(forKey: "typeShort") as? String ?? ""
       return searchedModule
    }
    
    func OwnAccountDetails(){
        
        self.displayIndicator()
        
        if Reachability.isConnectedToNetwork() { self.removeIndicator(showMessagge: true, message: networkMsg)
            return
        }
        
        let urlString = APIBaseUrlPart1 + "/AccountSummary/OwnAccounDetails"
        let arguments = ["ReqMode":"13",
                         "FK_Customer" : "\(customerId)",
                         "token": TokenNo,
                         "BankKey": BankKey,
                         "SubMode" :  "\(SubMode)",
                         "BankHeader": BankHeader]
        
        APICallHandler(urlString: urlString, method: .post, parameter: arguments) { [self] getResult in
            
            switch getResult{
            case.success(let responseJSONData):
                 
                let sttsCode = responseJSONData.value(forKey: "StatusCode")! as? Int ?? -1
                if sttsCode==0 {
                    let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
                    let list = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as? [NSDictionary] ?? []
                    self.OwnAccountdetailsList = list.map{ $0 }
                    DispatchQueue.main.async {
                        self.accounts.setTitle((self.OwnAccountdetailsList[0].value(forKey: "AccountNumber") as! String), for: .normal)
                    let GetModule =  self.fetchModule(accountNo: self.OwnAccountdetailsList.first?.value(forKey: "AccountNumber") as! String, list: self.OwnAccountdetailsList)
                        
                        self.module = GetModule ?? ""
                        self.fromAccBranchLtxt = self.OwnAccountdetailsList[0].value(forKey: "BranchName") as! String
                        
                        self.Balance = (self.OwnAccountdetailsList[0].value(forKey: "Balance") as! Double).currencyIN
                    }
                    self.AccountdetailsList = []
                    DispatchQueue.main.async {
                        for Accountdetails in self.OwnAccountdetailsList {
                            self.AccountdetailsList.append(Accountdetails.value(forKey: "AccountNumber") as! String)
                    }
                    
                        self.setAccDropDown()
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
            case.failure(let errResponse):
                
                var msg = ""
                
                let response = self.apiErrorResponseResult(errResponse: errResponse)
                msg = response.1
                
                    
        
                
                DispatchQueue.main.async {
                    self.present(messages.msg(msg), animated: true, completion: nil)
                }
                
            }
            
            self.removeIndicator(showMessagge: false, message: "")
        }
    }
    
    
    
//    func OwnAccounDetails() {
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
//                        DispatchQueue.main.async { [weak self] in
//                            self!.accounts.setTitle((OwnAccountdetailsList[0].value(forKey: "AccountNumber") as! String), for: .normal)
//                            self?.fromAccBranchLtxt = self?.OwnAccountdetailsList[0].value(forKey: "BranchName") as! String
//
//                            Balance = (self?.OwnAccountdetailsList[0].value(forKey: "Balance") as! Double).currencyIN
//                        }
//                        for Accountdetails in OwnAccountdetailsList {
//                            AccountdetailsList.append(Accountdetails.value(forKey: "AccountNumber") as! String)
//                        }
//                        DispatchQueue.main.async { [weak self] in
//                            self!.setAccDropDown()
//                        }
//                    }
//                    else {
//
//                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as Any
//                        if OwnAccountdetails as? String != nil {
//                                let OwnAccountdetail  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
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
//
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
    
    func setAccDropDown()
    {
        accDrop.anchorView      = accounts
        accDrop.bottomOffset    = CGPoint(x:0, y:30)
        accDrop.dataSource      = AccountdetailsList
        accDrop.backgroundColor = UIColor.white
        accDrop.selectionAction = {[weak self] (index, item) in
            self?.accounts.setTitle(item, for: .normal)
            
            self?.fromAccBranchLtxt = self?.OwnAccountdetailsList[index].value(forKey: "BranchName") as! String
            self?.Balance = (self?.OwnAccountdetailsList[0].value(forKey: "Balance") as! Double).currencyIN
            let GetModule =  self?.fetchModule(accountNo: item, list: self!.OwnAccountdetailsList)
                
            self?.module = GetModule ?? ""
        }
    }
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectAccNo(_ sender: UIButton)
    {
        accDrop.show()
    }
    
    @IBAction func saveBeneficiary(_ sender: UIButton)
    {
        if beneficiaryImg.image == UIImage(imageLiteralResourceName: "nonTick.png") {
            beneficiaryImg.image = UIImage(imageLiteralResourceName: "tick.png")
            beneAdd = "1"
            return
        }
        else
        {
            beneficiaryImg.image = UIImage(imageLiteralResourceName: "nonTick.png")
            beneAdd = "0"
            return
        }
    }
    
    @IBAction func clearData(_ sender: UIButton)
    {
        beneficiaryName.text    = ""
        beneficiaryAccNo.text   = ""
        confirmBeneAccNo.text   = ""
        ifsCode.text            = ""
        amount.text             = ""
        if beneficiaryImg.image == #imageLiteral(resourceName: "PIN3")
        {
            beneficiaryImg.image = #imageLiteral(resourceName: "PIN1")
        }
    }
    
    @IBAction func submitIfscNeftRtgs(_ sender: UIButton)
    {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        // selected acc number without module
        let acc = accounts.currentTitle!
        oneAcc = String(acc.dropLast(5))
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
        if beneficiaryName.text == ""
        {
            
            self.present(messages.msg("Please enter Beneficiary Name"), animated: true, completion: nil)
            beneficiaryName.layer.borderColor = UIColor.red.cgColor
            return
        }
        else if beneficiaryAccNo.text == ""
        {

            self.present(messages.msg("Beneficiary account number is required"), animated: true, completion: nil)

            beneficiaryAccNo.layer.borderColor = UIColor.red.cgColor
            return
        }
        else if confirmBeneAccNo.text == ""
        {

            self.present(messages.msg("Confirm Beneficiary account number is required"), animated: true, completion: nil)

            confirmBeneAccNo.layer.borderColor = UIColor.red.cgColor
            return
        }
        else if confirmBeneAccNo.text !=  beneficiaryAccNo.text
        {

            self.present(messages.msg("Beneficiary account numbers don't match"), animated: true, completion: nil)
            
            confirmBeneAccNo.layer.borderColor = UIColor.red.cgColor
            return
        }
        else if ifsCode.text == "" || ifsCode.text?.count != 11
        {

            self.present(messages.msg("Please valid enter IFSCode"), animated: true, completion: nil)

            ifsCode.layer.borderColor = UIColor.red.cgColor
            return
        }
        else if amount.text! == ""
        {
            DispatchQueue.main.async { [weak self] in
                self?.amount.layer.borderColor = UIColor.red.cgColor
            }
            self.present(messages.msg("Invalid amount"), animated: true, completion: nil)
            return
        }
        if sectionName == "IMPS"
        {
            mode = "3"
        }
        else if sectionName == "RTGS"
        {
            mode = "1"
        }
        else if sectionName == "NEFT"
        {
            mode = "2"
        }
        
        if beneficiaryImg.image == #imageLiteral(resourceName: "PIN1")
        {
            beneAdd = "0"
        }
        else if beneficiaryImg.image == #imageLiteral(resourceName: "PIN3")
        {
            beneAdd = "1"
        }
        
        
        PaymentConfirmation()
        
    }
    
    func PaymentConfirmation() {
        let customRCAlert = self.storyboard?.instantiateViewController(withIdentifier: "RConfirmationAlert") as! rechargeConfirmationAlertViewController
        customRCAlert.providesPresentationContextTransitionStyle = true
        customRCAlert.definesPresentationContext = true
        customRCAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customRCAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customRCAlert.delegate = self
        fromAcc = "A/C No : \(accounts.currentTitle ?? "")"
        customRCAlert.fromAccLtxt = fromAcc
        customRCAlert.fromAccBranchLtxt = "Branch : \(fromAccBranchLtxt)\nAvailable Balance : \(Balance)"
        customRCAlert.rechHdrLtxt = "Paying To "
        confirmBeneAccNoT = (confirmBeneAccNo.text!)
        customRCAlert.rechNumbLtxt = "A/C No : \(confirmBeneAccNoT)"
        customRCAlert.rechNumDetailsLtxt = ""
        customRCAlert.rechAmountHdrLtxt = "Payable Amount"
        amountT = (amount.text!)
        customRCAlert.rechAmountLtxt = Double(amountT)!.currencyIN
        customRCAlert.rechAmountDetailsLtxt = Double(amountT)!.InWords
        DispatchQueue.main.async {
            self.present(customRCAlert, animated: true, completion: nil)
        }
    }
    
    
     //FIXME: - NEFTRTGSPayment()
    func NEFTRTGSPayment() {
    
        self.displayIndicator()
        // network reachability checking
        if Reachability.isConnectedToNetwork() { self.removeIndicator(showMessagge: true, message: networkMsg)
            return
        }
//        let encryptedMode       = self.instanceOfEncryption.encryptUseDES(mode, key: "Agentscr") as String
//        let encryptedAcc        = self.instanceOfEncryption.encryptUseDES(oneAcc, key: "Agentscr") as String
//        let encryptedModule     = self.instanceOfEncryption.encryptUseDES(module, key: "Agentscr") as String
//        let encryptedBeneName   = self.instanceOfEncryption.encryptUseDES(beneficiaryName.text, key: "Agentscr") as String
//        let encryptedBeneAcc    = self.instanceOfEncryption.encryptUseDES(confirmBeneAccNo.text, key: "Agentscr") as String
//        let encryptedIFSC       = self.instanceOfEncryption.encryptUseDES(ifsCode.text, key: "Agentscr") as String
//        let encryptedAmount     = self.instanceOfEncryption.encryptUseDES(amount.text, key: "Agentscr") as String
//        let encryptedBeneAdd    = self.instanceOfEncryption.encryptUseDES(beneAdd, key: "Agentscr") as String
//        let encryptedPin        = self.instanceOfEncryption.encryptUseDES(self.pin, key: "Agentscr") as String
        
        let benename = beneficiaryName.text ?? ""
        let ifsc = ifsCode.text ?? ""
        let urlString = APIBaseUrlPart1 + "/AccountSummary/NEFTRTGSPayment"
        let confirmAC = confirmBeneAccNo.text ?? ""
        let amountTxt = amount.text ?? ""
        let arguments = ["AccountNo":"\(oneAcc)",
                         "BeneName":"\(benename)",
                         "BeneIFSC":"\(ifsc)",
                         "BeneAccountNumber":"\(confirmAC)",
                         "amount":"\(amountTxt)",
                         "EftType" : "\(mode)",
                         "BeneAdd":"\(beneAdd)",
                         "Pin":"\(self.pin)",
                         "token": TokenNo,
                         "BankKey": BankKey,
                         "Module" :  "\(module)",
                         "BankHeader": BankHeader,
                         "BankVerified":""]
        // url searching
        
        self.APICallHandler(urlString: urlString, method: .post, parameter: arguments) { getResult in
            switch getResult{
            case.success(let datas):
                //print(datas)
                
                let httpStatuscode = datas.value(forKey: "HttpStatusCode") as! Int
                let StatusCode = datas.value(forKey: "StatusCode") as? NSNumber
                let message = datas.value(forKey: "Message") as? String ?? ""
                let exMessage = datas.value(forKey: "ExMessge") as? String ?? ""
                DispatchQueue.main.async {
                    if httpStatuscode == 1 && StatusCode != nil{
                        
                        self.statuscode = datas.value(forKey: "StatusCode") as! Int
                        self.paymentDetails.append(ImpsNeftRtgsPaymentValues(encryAcc: self.oneAcc,
                        encryAccModule: self.module,encryBeneName:benename,encryBeneAccNumber: confirmAC,encryIFSC: ifsc,
                        encryAmount: amountTxt,encryMode: self.mode,encryBeneAdd: self.beneAdd,encryPin: self.pin,imei: UDID,
                        token: self.TokenNo))
                        self.performSegue(withIdentifier: "paymentOTP", sender: self)
                        
                    }else if httpStatuscode < 0 {
                        self.present(messages.msg(datas.value(forKey: "Message") as! String), animated: true, completion: nil)
                    }else{
                        let messagesData = exMessage == "" ? message : exMessage
                        self.present(messages.msg(messagesData), animated: true, completion: nil)
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
            
            self.removeIndicator(showMessagge: false, message: "")
        }
//        let url = URL(string: BankIP + APIBaseUrlPart + "/NEFTRTGSPayment?AccountNo=\(encryptedAcc)&Module=\(encryptedModule)&BeneName=\(encryptedBeneName)&BeneIFSC=\(encryptedIFSC)&BeneAccountNumber=\(encryptedBeneAcc)&amount=\(encryptedAmount)&EftType=\(encryptedMode)&BeneAdd=\(encryptedBeneAdd)&Pin=\(encryptedPin)&OTPRef=&OTPCode=&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
//
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//        let task = session.dataTask(with: url!) { data,response,error in
//            if error != nil
//            {
//                DispatchQueue.main.async { [weak self] in
//
//                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                }
//                return
//            }
//            if let datas = data
//            {
//
//                do
//                {
//                    let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
//                    let httpStatuscode = data1.value(forKey: "HttpStatusCode") as! Int
//                    if httpStatuscode == 1 && data1.value(forKey: "StatusCode") as? Int != nil
//                    {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.blurView.isHidden = true
//                            self?.activityIndicator.stopAnimating()
//                            self?.statuscode = data1.value(forKey: "StatusCode") as! Int
//                            self?.paymentDetails.append(ImpsNeftRtgsPaymentValues(encryAcc: encryptedAcc,
//                                                                                  encryAccModule: encryptedModule,
//                                                                                  encryBeneName: encryptedBeneName,
//                                                                                  encryBeneAccNumber: encryptedBeneAcc,
//                                                                                  encryIFSC: encryptedIFSC,
//                                                                                  encryAmount: encryptedAmount,
//                                                                                  encryMode: encryptedMode,
//                                                                                  encryBeneAdd: encryptedBeneAdd,
//                                                                                  encryPin: encryptedPin,
//                                                                                  imei: UDID,
//                                                                                  token: (self?.TokenNo)!))
//                            self?.performSegue(withIdentifier: "paymentOTP", sender: self)
//
//                        }
//                    }
//                    else if httpStatuscode < 0
//                    {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.blurView.isHidden = true
//                            self?.activityIndicator.stopAnimating()
//                            self?.present(messages.msg(data1.value(forKey: "Message") as! String), animated: true, completion: nil)
//                        }
//                    }
//                    else
//                    {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.blurView.isHidden = true
//                            self?.activityIndicator.stopAnimating()
//                            self?.present(messages.msg(data1.value(forKey: "ExMessge") as! String), animated: true, completion: nil)
//                        }
//                    }
//                }
//                catch
//                {
//                }
//            }
//        }
//        task.resume()
    }
    @IBAction func statusIfscNeftRtgs(_ sender: UIButton){
        performSegue(withIdentifier: "fundTransferStatusIndivitualSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from home screen to search screen
        if segue.identifier == "paymentOTP"
        {
            let vw = segue.destination as! PaymentOTPViewController
                vw.fullDetails  = paymentDetails
                vw.statusReff   = String(statuscode)
                vw.otpType      = 1
            
                vw.fromAccBranchLtxt = fromAccBranchLtxt
                vw.fromAcc = fromAcc
                vw.confirmBeneAccNo = confirmBeneAccNoT
                vw.amount = amountT
                    }
        else if segue.identifier == "fundTransferStatusIndivitualSegue"
        {
            let vw = segue.destination as! FundTransferStatusViewController
            vw.customerId   = customerId
            vw.TokenNo      = TokenNo
            vw.SubMode      = SubMode
        }

    }
    // textfield border color
    func textfieldBorder()
    {
        beneficiaryName.layer.borderColor   = lightGreyColor.cgColor
        beneficiaryName.layer.borderWidth   = 1.0
        beneficiaryName.layer.cornerRadius  = 5
        beneficiaryAccNo.layer.borderColor  = lightGreyColor.cgColor
        beneficiaryAccNo.layer.borderWidth  = 1.0
        beneficiaryAccNo.layer.cornerRadius = 5

        confirmBeneAccNo.layer.borderColor  = lightGreyColor.cgColor
        confirmBeneAccNo.layer.borderWidth  = 1.0
        confirmBeneAccNo.layer.cornerRadius = 5

        ifsCode.layer.borderColor   = lightGreyColor.cgColor
        ifsCode.layer.borderWidth   = 1.0
        ifsCode.layer.cornerRadius  = 5

        amount.layer.borderColor    = lightGreyColor.cgColor
        amount.layer.borderWidth    = 1.0
        amount.layer.cornerRadius   = 5

    }
    
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        moveTextField(textField, moveDistance: -140, up: true)
//        self.keyboardWillShow()

    }
    
   
    
    
    

    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        moveTextField(textField, moveDistance: -140, up: false)
    }
    
    // to next txtfld when the keyboard return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if beneficiaryName.isFirstResponder
        {
            beneficiaryAccNo.becomeFirstResponder()
        }
        else if beneficiaryAccNo.isFirstResponder
        {
            confirmBeneAccNo.becomeFirstResponder()
        }
        else if confirmBeneAccNo.isFirstResponder
        {
            ifsCode.becomeFirstResponder()
        }
        else if ifsCode.isFirstResponder
        {
            amount.becomeFirstResponder()
        }
        return true
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
    
    
    var amountInWordsTxt = String()
    var payAmount = String()
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.isEqual(amount)
        {
            var length = Int()
            if sectionName == "RTGS" || sectionName == "NEFT"{
                length = 7
            }
            else{
                length = 6
            }
            let amn = amount.text!
            if amn.count != 0 && amn.count < length + 1 {
                amountInWordsTxt = Double(String(amn))!.InWords
                payAmount = (Double(amn)!.currencyIN)
                amountInWords.text = amountInWordsTxt
                payBtn.setTitle("PAY \(payAmount)", for: .normal)
            }
            else if amn.count > length {
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
        if textField.isEqual(beneficiaryAccNo)
        {
            maxLength = 20
        }
        else if textField.isEqual(confirmBeneAccNo)
        {
            maxLength = 20
        }
        else if textField.isEqual(ifsCode)
        {
            maxLength = 11
        }
        else if textField.isEqual(amount)
        {
            if sectionName == "RTGS" || sectionName == "NEFT"{
                maxLength = 7
            }
            else{
                maxLength = 6
            }
        }
        else if textField.isEqual(beneficiaryName)
        {
            maxLength = 100
        }
        return newLength <= maxLength
    }
}


extension PaymentOfNeftImpsRtgsViewController: rechargeConfSuccessAlertDelegate{

    func ShareScreenShot(_ img: UIImage, _ Share : UIButton) {
        self.ShareImg = img
        self.ShareB = Share
    }
    
    
    func okButtonTapped() {
        print("OK")

        self.NEFTRTGSPayment()
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
