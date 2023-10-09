//
//  QuickPayViewController.swift
//  mScoreNew
//
//  Created by Perfect on 10/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import DropDown

class QuickPayViewController: NetworkManagerVC,UITextFieldDelegate
{
    @IBOutlet weak var amountText       : UITextField!
    @IBOutlet weak var amountInWords    : UILabel!
    @IBOutlet weak var messageText      : UITextField!
    @IBOutlet weak var mPinText         : UITextField!
    @IBOutlet weak var accounts         : UIButton!
    @IBOutlet weak var selectSender     : UIButton!
    @IBOutlet weak var selectReceiver   : UIButton!
    @IBOutlet weak var blurView         : UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var payBtn               : UIButton!
    
    var accDrop = DropDown()
    lazy var accDropDowns: [DropDown] = {
        return[self.accDrop]
    } ()
    var senderDrop = DropDown()
    lazy var senderDropDowns: [DropDown] = {
        return[self.senderDrop]
    } ()
    var receiverDrop = DropDown()
    lazy var receiverDropDowns: [DropDown] = {
        return[self.receiverDrop]
    } ()
    var fetchedAccDetail:[Accountdetails] = []
    var module = ""

    var instanceOfEncryption: Encryption = Encryption()
    
    // set var for get data in the time of segue
    var TokenNo         = String()
    var customerId      = String()
    var pin             = String()
    var sectionName     = String()

    var receiverlist    = [senderreciverlistData]()
    var senderlist      = [senderreciverlistData]()
    var sList           = ["Select"]
    var rList           = ["Select"]
    
    var senderId        = String()
    var receiverId      = String()
    var otpReffNumb     = String()
    var otpType         = Int()
    var OwnAccountdetailsList               = [NSDictionary]()
    var AccountdetailsList                  = [String]()
    var fromAccBranchLtxt                   = String()
    
    // otp screen
    var transcationID   = String()
    var urlString       = String()
    var ShareImg        = UIImage()
    var ShareB          = UIButton()
    var senName = String()
    var senMob = String()
    var recName = String()
    var recMob = String()
    var recAcc = String()
    override func viewDidLoad()
    {
        super.viewDidLoad()
    //// Do any additional setup after loading the view.
        // keyboard hiding in the case of touch the screen.
        self.hideKeyboardWhenTappedAround()
        self.blurView.isHidden = false
        self.activityIndicator.startAnimating()
        // bottomBorder
        amountText.setBottomBorder(UIColor.lightGray,1.0)
        messageText.setBottomBorder(UIColor.lightGray,1.0)
        mPinText.setBottomBorder(UIColor.lightGray,1.0)
        // udid generation
        UDID = udidGeneration.udidGen()
        
        accDropDowns.forEach { $0.dismissMode = .onTap }
        accDropDowns.forEach { $0.direction = .any }
        
            
        OwnAccountDetailsInfo(subMode: 1,activityView:self.activityIndicator,blurview:self.blurView)

        senderDropDowns.forEach { $0.dismissMode = .onTap }
        senderDropDowns.forEach { $0.direction = .any }
        selectSender.setTitle("Select", for: .normal)

        receiverDropDowns.forEach { $0.dismissMode = .onTap }
        receiverDropDowns.forEach { $0.direction = .any }
        selectReceiver.setTitle("Select", for: .normal)
        setReceiverDropDown()
        nextButtonInClick.load().addTarget(self, action: #selector(self.mobilePadNextAction(_:)), for: UIControl.Event.touchUpInside)
    }
    
    func keyboardWillShow()
    {
        if amountText.isFirstResponder
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
    @objc func mobilePadNextAction(_ sender : UIButton)
    {
        //Click action
        if amountText.isFirstResponder{
            messageText.becomeFirstResponder()
        }
    }
    override func viewWillAppear(_ animated: Bool)
    {
        receiverlist    = []
        senderlist      = []
        sList           = ["Select"]
        rList           = ["Select"]
        //// whenever the view will appear this func works
        
            self.generateSenderReceiverListApi()
            //self.savedSenderReceiver()
    
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func accSelection(_ sender: UIButton)
    {
        accDrop.show()
    }
    @IBAction func senderSelection(_ sender: UIButton)
    {
        senderDrop.show()
    }
    @IBAction func receiverSelection(_ sender: UIButton)
    {
        receiverDrop.show()
    }
    @IBAction func addReceiver(_ sender: UIButton)
    {
        if sList.count != 1
        {
            self.performSegue(withIdentifier: "addReceiver", sender: self)
        }
        else
        {
            self.present(messages.msg("Please add sender first."), animated: true, completion: nil)

        }
    }
    @IBAction func addSender(_ sender: UIButton)
    {
        
        self.performSegue(withIdentifier: "addSender", sender: self)

    }
    
    @IBAction func mPin(_ sender: UIButton)
    {
        blurView.isHidden = false
        self.activityIndicator.startAnimating()

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
        
        if let range = self.selectSender.currentTitle?.range(of: "\n")
        {
            senderId = (self.selectSender.currentTitle?[range.upperBound...].trimmingCharacters(in: .whitespaces))!
        }
        let url = URL(string: BankIP + APIBaseUrlPart + "/MTResendMPIN?senderid=\(senderId)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url!) { data,response,error in
            DispatchQueue.main.async {
                self.blurView.isHidden = true
                self.activityIndicator.stopAnimating()
                if error != nil
                {
                    DispatchQueue.main.async {
                        self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    }
                    return
                }
                let dataInString = String(data: data!, encoding: String.Encoding.utf8)
                if dataInString == "1"
                {
                    DispatchQueue.main.async { [weak self] in
                        self?.present(messages.msg("Internal Server Error ! Please Try Again Later."), animated: true, completion: nil)
                    }
                }
                else{
                    DispatchQueue.main.async { [weak self] in
                        self?.present(messages.msg("mPin Successfully Sended To Your Registered Mobile Number."), animated: true, completion: nil)
                    }

                }
            }
        }
        task.resume()
    }
    @IBAction func makePayment(_ sender: UIButton)
    {
        
        // n/w reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [self] in
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        // selected acc
        let oneAcc = String(accounts.currentTitle!.dropLast(4))
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
        if let range = self.selectSender.currentTitle?.range(of: "\n")
        {
            senderId = (self.selectSender.currentTitle?[range.upperBound...].trimmingCharacters(in: .whitespaces))!
        }
        if let range = self.selectReceiver.currentTitle?.range(of: "\n")
        {
            receiverId = (self.selectReceiver.currentTitle?[range.upperBound...].trimmingCharacters(in: .whitespaces))!
        }
        if senderId.count == 0 {
           
            self.present(messages.msg("Please Select Sender."), animated: true, completion: nil)
            return
        }
        if receiverId.count == 0 {
            
            self.present(messages.msg("Please Select Receiver."), animated: true, completion: nil)
            return
        }
        // amount settings
        if amountText.text! == "" || Int(amountText.text!)! > 1000000
        {
            self.present(messages.msg(invalidAmount), animated: true, completion: nil)
            return

        }
        if mPinText.text! == "" || mPinText.text?.count != 4
        {
            self.present(messages.msg(invalidAmount), animated: true, completion: nil)
            return
        }
        self.PaymentConfirmation()
    }
    
    
    func PaymentConfirmation() {
        let customQPCAlert = self.storyboard?.instantiateViewController(withIdentifier: "qpConfirmationAlert") as! qpConfirmationAlertViewController
        customQPCAlert.providesPresentationContextTransitionStyle = true
        customQPCAlert.definesPresentationContext = true
        customQPCAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customQPCAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customQPCAlert.delegate = self
        customQPCAlert.senderNameLtxt = senName
        customQPCAlert.senderAccDetaLtxt = "\(accounts.currentTitle!)\n\(fromAccBranchLtxt)"
        customQPCAlert.senderMobLtxt = senMob
        customQPCAlert.receiverNameLtxt = recName
        customQPCAlert.receiverAccDetaLtxt = recAcc
        customQPCAlert.receiverMobLtxt = recMob
        customQPCAlert.qpAmountLtxt = Double(amountText.text!)!.currencyIN
        customQPCAlert.qpAmountDetailsLtxt = Double(amountText.text!)!.InWords
        self.present(customQPCAlert, animated: true, completion: nil)
    }
        
    func PaymentSuccess(_ RTitle : String,_ RefNo : String, _ RDate : String, _ RTime : String) {
        let customQPSAlert = self.storyboard?.instantiateViewController(withIdentifier: "qpSuccessAlert") as! qpSuccessAlertViewController
        customQPSAlert.providesPresentationContextTransitionStyle = true
        customQPSAlert.definesPresentationContext = true
        customQPSAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customQPSAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customQPSAlert.delegate = self
        customQPSAlert.sucHdrLtxt = RTitle
        customQPSAlert.qpDateLtxt = "Date : \(RDate)"
        customQPSAlert.qpTimeLtxt = "Time : \(RTime)"
        customQPSAlert.qpReffNoLtxt = RefNo
        customQPSAlert.senderNameLtxt = senName
        customQPSAlert.senderAccDetaLtxt = "\(accounts.currentTitle!)\n\(fromAccBranchLtxt)"
        customQPSAlert.senderMobLtxt = senMob
        customQPSAlert.receiverNameLtxt = recName
        customQPSAlert.receiverAccDetaLtxt = recAcc
        customQPSAlert.receiverMobLtxt = recMob
        customQPSAlert.qpAmountLtxt = Double(amountText.text!)!.currencyIN
        customQPSAlert.qpAmountDetailsLtxt = Double(amountText.text!)!.InWords
        DispatchQueue.main.async {
            self.present(customQPSAlert, animated: true, completion: nil)
        }
       
    }
    
    func MoneyTransferPaymentQuickPay() {
        DispatchQueue.main.async { [self] in
            self.blurView.isHidden = false
            self.activityIndicator.startAnimating()
        }
        // n/w reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [self] in
                self.blurView.isHidden = true
                self.activityIndicator.stopAnimating()
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }

    //after user press ok, the following code will be execute
        let oneAcc = String(accounts.currentTitle!.dropLast(4))

        
         // encryption of all data
         let encryptedSenderId   = instanceOfEncryption.encryptUseDES(senderId,
                                                                      key: "Agentscr") as String
         let encryptedReceiverId = instanceOfEncryption.encryptUseDES(receiverId,
                                                                      key: "Agentscr") as String
         let encryptedCusID      = instanceOfEncryption.encryptUseDES(customerId,
                                                                      key: "Agentscr") as String
         let encryptedAmount     = instanceOfEncryption.encryptUseDES(amountText.text,
                                                                      key: "Agentscr") as String
         let encryptedMessage    = instanceOfEncryption.encryptUseDES(messageText.text,
                                                                      key: "Agentscr") as String
         let encryptedAccNo      = instanceOfEncryption.encryptUseDES(oneAcc,
                                                                 key: "Agentscr") as String
         let encryptedModule     = instanceOfEncryption.encryptUseDES(module,
                                                                  key: "Agentscr") as String
         let encryptedPin        = instanceOfEncryption.encryptUseDES(pin,
                                                               key: "Agentscr") as String
         
         var recAccount = String()
         let recAcc = selectReceiver.currentTitle!
         if let index = recAcc.range(of: "\n")?.lowerBound
         {
             let substring = recAcc[..<index]
             recAccount = String(substring)
         }
        // url searching
        self.urlString = BankIP + APIBaseUrlPart + "/MoneyTransferPayment?senderid=\(encryptedSenderId)&receiverid=\(encryptedReceiverId)&IDCustomer=\(encryptedCusID)&amount=\(encryptedAmount)&Messages=\(encryptedMessage)&AccountNo=\(encryptedAccNo)&Module=\(encryptedModule)&Pin=\(encryptedPin)&MPIN=\(self.mPinText.text!)&imei=\(UDID)&token=\(self.TokenNo)&BankKey=\(BankKey)"
        let url = URL(string: self.urlString)
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url!) { data,response,error in
            if error != nil
            {
                DispatchQueue.main.async { [self] in
                    self.blurView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                }
                return
            }
            if let datas = data
            {
                do
                {
                    let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                    if data1.value(forKey: "StatusCode") as? Int == 200
                    {
                        if data1.value(forKey: "StatusCode") as! Int == 200 && data1.value(forKey: "otpRefNo") as! String == "0" {
                            DispatchQueue.main.async{
                                self.blurView.isHidden = true
                                self.activityIndicator.stopAnimating()
                                
                                let CDate = Date().currentDate(format: "dd-MM-yyyy")
                                let CTime = Date().currentDate(format: "h:mm a")
                                self.PaymentSuccess(data1.value(forKey: "message") as! String,"",CDate,CTime)
                            }
                        }
                        else if data1.value(forKey: "StatusCode") as! Int == 200 && data1.value(forKey: "otpRefNo") as! String != "0"
                        {
                            DispatchQueue.main.async{
                                self.blurView.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.transcationID = data1.value(forKey: "TrasactionID") as! String
                                self.otpReffNumb = data1.value(forKey: "otpRefNo") as! String
                                self.performSegue(withIdentifier: "quickpayOtp", sender: self)
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async{
                                self.blurView.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.present(messages.failureMsg(data1.value(forKey: "message") as! String), animated: true, completion: nil)
                            }
                        }
                    }
                    else if data1.value(forKey: "StatusCode") as? Int == 500
                    {
                        DispatchQueue.main.async { [self] in
                            self.blurView.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.present(messages.failureMsg(data1.value(forKey: "message") as! String), animated: true, completion: nil)
                        }
                    }
                    
                }
                catch
                {
                    DispatchQueue.main.async{
                        self.blurView.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from home screen to accInfo screen
        if segue.identifier == "addReceiver"
        {
            let vw = segue.destination as! addReceiverViewController
            vw.pin = pin
            vw.customerId = customerId
            vw.TokenNo = TokenNo
            vw.sList = sList
        }
        // from home screen to search screen
        else if segue.identifier == "addSender"
        {
            let vw = segue.destination as! addSenderViewController
            vw.pin = pin
            vw.customerId = customerId
            vw.TokenNo = TokenNo
        }
        if segue.identifier == "quickpayOtp"
        {
            let vw = segue.destination as! PaymentOTPViewController
            vw.senderId = senderId
            vw.receverId = receiverId
            vw.statusReff = otpReffNumb
            vw.transcationID = transcationID
            vw.urlString = urlString
            vw.otpType = 4
            
            vw.senName = senName
            vw.senMob = senMob
            vw.recName = recName
            vw.recMob = recMob
            vw.recAcc = recAcc
            vw.accounts = accounts.currentTitle!
            vw.fromAccBranchLtxt = fromAccBranchLtxt
            vw.amountText = amountText.text!
        }
    }
    
    
    //FIXME: - OWNO_ACCOUNT_DETAILS_INFORMATION_API_CALL()
    func OwnAccountDetailsInfo(subMode:Int,activityView:UIActivityIndicatorView,blurview:UIView) {
        
        self.displayIndicator(activityView: activityView, blurview: blurview)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityView, blurview: blurview)
            return
        }
        
        let urlPath = APIBaseUrlPart1+"/AccountSummary/OwnAccounDetails"
        
        let arguments = ["FK_Customer":"\(customerId)","ReqMode":"13",
                         "token":"\(TokenNo)","BankKey":BankKey,
                         "BankHeader":BankHeader,
                         "SubMode":"\(subMode)"]
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            switch getResult{
            case.success(let datas):
                print(datas)
                self.apiResponsStatusCheck(of: Int.self,datas) { statusCode  in
                    
                    let exMessage = datas.value(forKey: self.EXMessage) as? String ?? ""
                    let OwnAccountdetails = datas.value(forKey: "OwnAccountdetails") as? NSDictionary ?? [:]
                    let ResponseMessage = OwnAccountdetails.value(forKey: self.ResponseMessage) as? String ?? ""
                    
                    if statusCode == 0{
                        
                        let ownAccountDList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as? [NSDictionary] ?? []
                        self.OwnAccountdetailsList = ownAccountDList.compactMap{$0}
                        
                        self.AccountdetailsList = []
                        self.AccountdetailsList.append(contentsOf: self.OwnAccountdetailsList.map{ $0.value(forKey: "AccountNumber") as? String ?? "" })
                        
                        DispatchQueue.main.async {
                            
                            let details = self.OwnAccountdetailsList[0]
                            let accountNumber = details.value(forKey: "AccountNumber") as? String ?? ""
                            self.accounts.setTitle(accountNumber, for: .normal)
                            self.fromAccBranchLtxt = details.value(forKey: "BranchName") as? String ?? ""
                            
                            self.setAccDropDown()
                        }
                        
                        
                    }else{
                        
                        let statusMessage = exMessage == "" ? ResponseMessage : exMessage
                        
                        DispatchQueue.main.async {
                            self.present(messages.msg(statusMessage), animated: true, completion: nil)
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
            self.removeIndicator(showMessagge: false, message: "",activityView: activityView, blurview: blurview)
        }
        
    }
    
//    func OwnAccounDetails() {
//        // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//                self?.blurView.isHidden = true
//                self?.activityIndicator.stopAnimating()
//            }
//            return
//        }
//        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/OwnAccounDetails")!
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("13", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
//        let encryptedSubMode     = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
//
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
//                    self?.blurView.isHidden = true
//                    self?.activityIndicator.stopAnimating()
//                }
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    print(responseJSONData)
//                    DispatchQueue.main.async { [weak self] in
//                        self!.blurView.isHidden = true
//                        self!.activityIndicator.stopAnimating()
//                    }
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode") as? Int ?? 100
//                    if sttsCode==0 {
//                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
//                        OwnAccountdetailsList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as! [NSDictionary]
//                        DispatchQueue.main.async { [weak self] in
//                            self!.accounts.setTitle((OwnAccountdetailsList[0].value(forKey: "AccountNumber") as! String), for: .normal)
//                            self?.fromAccBranchLtxt = self?.OwnAccountdetailsList[0].value(forKey: "BranchName") as! String
//                        }
//                        for Accountdetails in OwnAccountdetailsList {
//                            self.AccountdetailsList.append(Accountdetails.value(forKey: "AccountNumber") as! String)
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
        accDrop.anchorView = accounts
        accDrop.bottomOffset = CGPoint(x:0, y:40)
        accDrop.dataSource = AccountdetailsList
        accDrop.backgroundColor = UIColor.white
        accDrop.selectionAction = {[weak self] (index, item) in
            self?.accounts.setTitle(item, for: .normal)
            self?.fromAccBranchLtxt = self?.OwnAccountdetailsList[index].value(forKey: "BranchName") as! String
        }
    }
    func setSenderDropDown()
    {
        senderDrop.anchorView = selectSender
        senderDrop.bottomOffset = CGPoint(x:0, y:40)
        senderDrop.dataSource = sList
        senderDrop.backgroundColor = UIColor.white
        senderDrop.selectionAction = {[weak self] (index, item) in
            self?.selectSender.setTitle(item, for: .normal)
            self?.selectReceiver.setTitle("Select", for: .normal)
            
            for oneSender in self!.senderlist
            {
                if let range = item.range(of: "\n")
                {
                    if String(oneSender.UserID) == (item[range.upperBound...].trimmingCharacters(in: .whitespaces)) {
                        self?.senName = oneSender.SenderName
                        self?.senMob = oneSender.SenderMobile
                    }
                }
            }
            
            if self?.receiverlist.count != 0
            {
                self?.rList = ["Select"]
                for oneReceiver in (self?.receiverlist)!
                {
                    if let range = self?.selectSender.currentTitle?.range(of: "\n")
                    {
                        let Index = (self?.selectSender.currentTitle?[range.upperBound...].trimmingCharacters(in: .whitespaces))!
                        if Index == String(oneReceiver.FK_SenderID)
                        {
                            self?.rList.append(oneReceiver.SenderName + "(" + oneReceiver.ReceiverAccountno + ") \n" + String(oneReceiver.UserID))
                        }
                    }
                }
            }
            self?.setReceiverDropDown()
        }
    }
    
    func setReceiverDropDown()
    {
        receiverDrop.anchorView = selectReceiver
        receiverDrop.bottomOffset = CGPoint(x:0, y:40)
        receiverDrop.dataSource = rList
        receiverDrop.backgroundColor = UIColor.white
        receiverDrop.selectionAction = {[weak self] (index, item) in
            self?.selectReceiver.setTitle(item, for: .normal)
            for oneReceiver in self!.receiverlist
            {
                if let range = item.range(of: "\n")
                {
                    if String(oneReceiver.UserID) == (item[range.upperBound...].trimmingCharacters(in: .whitespaces)) {
                        self?.recName = oneReceiver.SenderName
                        self?.recMob = oneReceiver.SenderMobile
                        self?.recAcc = oneReceiver.ReceiverAccountno
                    }
                }
            }
        }
    }
    
    //FIXME: - GENERATE_SENDER_RECEIVER_LIST_API()
    func generateSenderReceiverListApi(){
        
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = APIBaseUrlPart1+"/AccountSummary/GenerateSenderReceiverList"
        let arguments = ["FK_Customer":"\(customerId)","imei":"\(UDID)",
                         "token":"\(TokenNo)","BankKey":BankKey,
                         "BankHeader":BankHeader,
                         "BankVerified":""]
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            
            switch getResult{
            case.success(let datas):
                print(datas)
                self.apiResponsStatusCheck(of: Int.self,datas) { statusCode  in
                    
                    let exMessage = datas.value(forKey: self.EXMessage) as? String ?? ""
                    let GenerateSenderReceiverList = datas.value(forKey: "GenerateSenderReceiverList") as? NSDictionary ?? [:]
                    let ResponseMessage = GenerateSenderReceiverList.value(forKey: self.ResponseMessage) as? String ?? ""
                    
                    if statusCode == 0{
                        
                    }else{
                        
                        let statusMessage = exMessage == "" ? ResponseMessage : exMessage
                        
                        DispatchQueue.main.async {
                            self.present(messages.errorMsgWithAppIcon("\(statusMessage)",UIImage(named: "AppIcon")!), animated: true,completion: nil)
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
    func savedSenderReceiver()
    {
        blurView.isHidden = false
        activityIndicator.startAnimating()

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
        
        let encryptedCusID = instanceOfEncryption.encryptUseDES(customerId, key: "Agentscr") as String
        
        let url = URL(string: BankIP + APIBaseUrlPart + "/GenerateSenderReceiverList?ID_Customer=\(encryptedCusID)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url!) { data,response,error in
            if error != nil
            {
                DispatchQueue.main.async {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                }
                
                
                return
            }
            if let datas = data
            {
                let dataInString = String(data: data!, encoding: String.Encoding.utf8)
                if dataInString == "null" || dataInString == ""
                {
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.blurView.isHidden = true
                    }
                    print("error")
                }
                else
                {
                    do
                    {
                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        
                        let StatementOfAccountDet  = data1.value(forKey: "senderreciverlist") as Any
                        if StatementOfAccountDet as? [NSDictionary] != nil {
                            let srLists = data1.value(forKey: "senderreciverlist") as! [NSDictionary]
                            
                            if srLists.count == 0 {
                                DispatchQueue.main.async {
                                    self.sList = ["Select"]
                                    self.present(messages.errorMsgWithAppIcon("No list found. Please add sender.",UIImage(named: "AppIcon")!), animated: true,completion: nil)
                                    self.activityIndicator.stopAnimating()
                                    self.blurView.isHidden = true
                                }
                                return
                            }
                            for srList in srLists
                            {
                                if srList.value(forKey: "Mode") as! String == "1"
                                {
                                    let sID = srList.value(forKey: "UserID") as! Int
                                    let sFKID = srList.value(forKey: "FK_SenderID") as! Int
                                    let senderName = srList.value(forKey: "SenderName") as! String
                                    let senderMobNumb = srList.value(forKey: "SenderMobile") as! String
                                    let recAccNumb = srList.value(forKey: "ReceiverAccountno") as! String
                                    self.senderlist.append(senderreciverlistData(UserID: sID, FK_SenderID: sFKID, SenderName: senderName, SenderMobile: senderMobNumb, ReceiverAccountno: recAccNumb))
                                }
                                else if srList.value(forKey: "Mode") as! String == "2"
                                {
                                    let rID = srList.value(forKey: "UserID") as! Int
                                    let rFKID = srList.value(forKey: "FK_SenderID") as! Int
                                    let senderName = srList.value(forKey: "SenderName") as! String
                                    let senderMobNumb = srList.value(forKey: "SenderMobile") as! String
                                    let recAccNumb = srList.value(forKey: "ReceiverAccountno") as! String
                                    self.receiverlist.append(senderreciverlistData(UserID: rID, FK_SenderID: rFKID, SenderName: senderName, SenderMobile: senderMobNumb, ReceiverAccountno: recAccNumb))
                                }
                            }
                            
                            if self.senderlist.count != 0
                            {
                                self.sList = ["Select"]
                                for oneSender in self.senderlist
                                {
                                    self.sList.append(oneSender.SenderName + "(" + oneSender.SenderMobile + ") \n" + String(oneSender.UserID) )
                                }
                            }
                            else
                            {
                                self.sList = ["Select"]
                                self.present(messages.errorMsgWithAppIcon("No list found. Please add sender.",UIImage(named: "AppIcon")!), animated: true,completion: nil)
                            }
                            self.setSenderDropDown()

                        }
                        else{
                            self.sList = ["Select"]
                            self.present(messages.errorMsgWithAppIcon("No list found. Please add sender.",UIImage(named: "AppIcon")!), animated: true,completion: nil)
                        }
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.blurView.isHidden = true
                        }
                    }
                    catch
                    {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.blurView.isHidden = true
                        }
                    }
                }
            }
        }
        task.resume()
    }

    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(greenColour,2.0)
        moveTextField(textField, moveDistance: -150, up: true)
        self.keyboardWillShow()

    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(UIColor.lightGray,1.0)
        moveTextField(textField, moveDistance: -150, up: false)
    }
    
    var amountInWordsTxt = String()
    var payAmount = String()
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.isEqual(amountText)
        {
            let amn = amountText.text!
            if amn.count != 0 && amn.count < 6 {
                amountInWordsTxt = Double(String(amn))!.InWords
                payAmount = (Double(amn)!.currencyIN)
                amountInWords.text = amountInWordsTxt
                payBtn.setTitle("MAKE PAYMENT OF \(payAmount)", for: .normal)
            }
            else if amn.count > 5 {
                amountInWords.text = amountInWordsTxt
                payBtn.setTitle("MAKE PAYMENT OF \(payAmount)", for: .normal)
            }
            else{
                payBtn.setTitle("MAKE PAYMENT", for: .normal)
                amountInWords.text = ""
            }
        }
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if amountText.isFirstResponder {
            messageText.becomeFirstResponder()
        }
        if messageText.isFirstResponder{
            mPinText.becomeFirstResponder()
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let currentCharacterCount = textField.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount)
        {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        var maxLength = Int()
        if textField.isEqual(amountText)
        {
            maxLength = 5
        }
        else if textField.isEqual(mPinText)
        {
            maxLength = 4
        }
        else if textField.isEqual(messageText)
        {
            maxLength = 100
        }

        return newLength <= maxLength
    }
}



extension QuickPayViewController: qpConfSuccessAlertDelegate{

    func qpShareScreenShot(_ img: UIImage, _ Share : UIButton) {
        self.ShareImg = img
        self.ShareB = Share
    }
    
    
    func qpokButtonTapped() {
        print("OK")

        self.MoneyTransferPaymentQuickPay()
    }
    func qpcancelButtonTapped() {
        print("cancel")
    }
    
    func qpshareButtonTapped() {
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


