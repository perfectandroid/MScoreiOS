//
//  PaymentOTPViewController.swift
//  mScoreNew
//
//  Created by Perfect on 12/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class PaymentOTPViewController: NetworkManagerVC, UITextFieldDelegate
{
    @IBOutlet weak var otpText          : UITextField!{
        didSet{
            // number typing in the text field is not shown
            otpText.isSecureTextEntry   = !otpText.isSecureTextEntry
            otpText.delegate = self
            otpText.placeholder = "Enter OTP"
            
        }
    }
    @IBOutlet weak var confirmOTP       : UIButton!
    @IBOutlet weak var errorMsg         : UILabel!
    @IBOutlet weak var blurView         : UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    var fullDetails     = [ImpsNeftRtgsPaymentValues]()
    var otpType         = Int()
    var urlString       = String()
    var statusReff      = String()
    var senderId        = String()
    var receverId                   = String()
    var mobNumb                     = String()
    var instanceOfEncryption: Encryption = Encryption()
    var attempt                     = 3
    var pin                         = String()
    var TokenNo                     = String()
    var transcationID               = String()
    var responseValueSettings       = [responseValue]()
    var errorResponseValueSettings  = [errorResponseValue]()
    var senName                     = String()
    var senMob                      = String()
    var recName                     = String()
    var recMob                      = String()
    var recAcc                      = String()
    var accounts                    = String()
    var fromAccBranchLtxt           = String()
    var amountText                  = String()
    var ShareImg                    = UIImage()
    var ShareB                      = UIButton()
    var fromAcc                     = String()
    var confirmBeneAccNo            = String()
    var amount                      = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    //// Do any additional setup after loading the view.
        // keyboard hiding in the case of touch the screen.
        self.hideKeyboardWhenTappedAround()
        // button border settings
        confirmOTP.layer.cornerRadius   = 5
        confirmOTP.layer.borderWidth    = 1
        confirmOTP.layer.borderColor    = UIColor.black.cgColor
        //otp text settings
        blurView.isHidden               = true
        // udid generation
        UDID = udidGeneration.udidGen()
        
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
    
    //FIXME: - RESEND_OTP_API_CALL()
    func resendOtpApiCall(type:Int,urlPath:String){
        
        var arguments = [String:String]()
        
        self.displayIndicator()
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg)
            return
        }
        
        
        
        
        if type == 1{
            
    
            
            let datas = fullDetails[0]
            let accountNumber = datas.encryAcc
            let modules = datas.encryAccModule
            let BeneName = datas.encryBeneName
            let BeneIFSC = datas.encryIFSC
            let BeneAccountNumber = datas.encryBeneAccNumber
            let amount = datas.encryAmount
            let EftType = datas.encryMode
            let BeneAdd = datas.encryBeneAdd
            let OTPCode = self.otpText.text ?? ""
            let imei = ""
            
            let token = datas.token
            
            arguments = ["AccountNo":"\(accountNumber)",
                             "BeneName":"\(BeneName)",
                             "BeneIFSC":"\(BeneIFSC)",
                             "BeneAccountNumber":"\(BeneAccountNumber)",
                             "amount":"\(amount)",
                             "EftType" : "\(EftType)",
                             "BeneAdd":"\(BeneAdd)",
                             "OTPRef" : "",
                             "OTPCode" : "",
                             "token": token,
                             "BankKey": BankKey,
                             "imei":"\(imei)",
                             "Module" :  "\(modules)",
                             "BankVerified":"",
                             "BankHeader": BankHeader]
            
        }
        
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in

            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { StatusCode in
                    print("getResult:\(datas)")
                    let exMessage = datas.value(forKey: self.EXMessage) as? String ?? ""
                    let messageData = datas.value(forKey: "Message") as? String ?? ""
                    let HttpStatusCode = datas.value(forKey: "HttpStatusCode") as? Int ?? -100
                    
                    if HttpStatusCode == 1{
                        
                        DispatchQueue.main.async {
                            self.statusReff = "\(StatusCode)"
                            self.present(messages.msg(messageData), animated: true, completion: nil)
                        }
                        
                    }else{
                        let errMsg = exMessage == "" ? messageData : exMessage
                        DispatchQueue.main.async {
                            self.present(messages.msg(errMsg), animated: true, completion: nil)
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
    
//FIXME: - RESEND_OTP_CHECK_TYPE_API()
    func resendOTPCheckApi(type:Int) {
        switch type{
        case 1 :
            
            //neft/rtgs/impes resend otp to confirm payments
            resendOtpApiCall(type: 1, urlPath: APIBaseUrlPart1 + "/AccountSummary/NEFTRTGSPayment")
//        case 2 :
//            //not using right now
//            // resend new otp for new sender to confirm payment
//            resendOtpApiCall(type: type, urlPath:"/Customer/MTResendSenderOTP")
//            print(type)
//        case 3 :
//            // not using right now
//            // resend new otp for new receiver to confirm payment
//            resendOtpApiCall(type: 3, urlPath: "")
//        case 4 :
//            // not using right now
//            // quickpay payment otp screen
//            resendOtpApiCall(type: 4, urlPath: "")
        default:
            print(type)
        }
    }
    
    @IBAction func resend(_ sender: UIButton)
    {
        
        
        
        
        self.resendOTPCheckApi(type: otpType)
        
        
//        blurView.isHidden = false
//        activityIndicator.startAnimating()
//
//        // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//                self?.activityIndicator.startAnimating()
//                self?.blurView.isHidden = true
//            }
//            return
//        }
//
//
//
//
//
//        // imps/rtgs/neft payment otp screen
//        if otpType == 1
//        {
//            // url searching
//            let url = URL(string: BankIP + APIBaseUrlPart + "/NEFTRTGSPayment?AccountNo=\(fullDetails[0].encryAcc)&Module=\(fullDetails[0].encryAccModule)&BeneName=\(fullDetails[0].encryBeneName)&BeneIFSC=\(fullDetails[0].encryIFSC)&BeneAccountNumber=\(fullDetails[0].encryBeneAccNumber)&amount=\(fullDetails[0].encryAmount)&EftType=\(fullDetails[0].encryMode)&BeneAdd=\(fullDetails[0].encryBeneAdd)&Pin=\(fullDetails[0].encryPin)&OTPRef=&OTPCode=&imei=\(fullDetails[0].imei)&token=\(fullDetails[0].token)&BankKey=\(BankKey)")
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            let task = session.dataTask(with: url!) { data,response,error in
//                if error != nil
//                {
//                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    self.blurView.isHidden = true
//                    return
//                }
//                if let datas = data
//                {
//                    do
//                    {
//                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
//                        let httpStatuscode = data1.value(forKey: "HttpStatusCode") as! Int
//                        if httpStatuscode == 1 && data1.value(forKey: "StatusCode") as? Int != nil
//                        {
//                            DispatchQueue.main.async { [weak self] in
//                                self?.blurView.isHidden = true
//                                self?.activityIndicator.stopAnimating()
//
//                                self?.statusReff = String(data1.value(forKey: "StatusCode") as! Int)
//                            }
//                        }
//                        else if httpStatuscode < 0
//                        {
//                            DispatchQueue.main.async { [weak self] in
//                                self?.blurView.isHidden = true
//                                self?.activityIndicator.stopAnimating()
//                                self?.present(messages.msg(data1.value(forKey: "Message") as! String), animated: true, completion: nil)
//                            }
//                        }
//                        else
//                        {
//                            DispatchQueue.main.async { [weak self] in
//                                self?.blurView.isHidden = true
//                                self?.activityIndicator.stopAnimating()
//                                self?.present(messages.msg(data1.value(forKey: "ExMessge") as! String), animated: true, completion: nil)
//                            }
//                        }
//                    }
//                    catch{
//                        DispatchQueue.main.async { [self] in
//                            self.blurView.isHidden = true
//                            self.activityIndicator.stopAnimating()
//                        }
//                    }
//                }
//            }
//            task.resume()
//        }
//        // new sender adding otp screen
//        else if otpType == 2
//        {
//            let url = URL(string: urlString)
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            let task = session.dataTask(with: url!) { data,response,error in
//                if error != nil
//                {
//                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    self.blurView.isHidden = true
//                    return
//                }
//                if let datas = data
//                {
//                    let dataInString = String(data: data!, encoding: String.Encoding.utf8)
//                    if dataInString == "null"
//                    {
//                        DispatchQueue.main.async{
//                            self.blurView.isHidden = true
//                            self.activityIndicator.stopAnimating()
//                            print("error")
//
//                        }
//                    }
//                    else
//                    {
//                        do
//                        {
//                            let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
//                            if data1.value(forKey: "StatusCode") as! Int == 200 && data1.value(forKey: "otpRefNo") as! String == "0"
//                            {
//                                DispatchQueue.main.async{
//                                    self.blurView.isHidden = true
//                                    self.activityIndicator.stopAnimating()
//                                    self.present(messages.successMsg(data1.value(forKey: "message") as! String), animated: true, completion: nil)
//                                }
//                            }
//                            else if data1.value(forKey: "StatusCode") as! Int == 200 && data1.value(forKey: "otpRefNo") as! String != "0"
//                            {
//                                DispatchQueue.main.async{
//                                    self.blurView.isHidden = true
//                                    self.activityIndicator.stopAnimating()
//                                    self.statusReff = String(data1.value(forKey: "otpRefNo") as! Int)
//                                    self.senderId = data1.value(forKey: "ID_Sender") as! String
//                                }
//                            }
//                            else
//                            {
//                                DispatchQueue.main.async{
//                                    self.blurView.isHidden = true
//                                    self.activityIndicator.stopAnimating()
//                                    self.present(messages.failureMsg(data1.value(forKey: "message") as! String), animated: true, completion: nil)
//                                }
//                            }
//                        }
//                        catch
//                        {
//                            DispatchQueue.main.async { [self] in
//                                self.blurView.isHidden = true
//                                self.activityIndicator.stopAnimating()
//                            }
//                        }
//
//                    }
//                }
//            }
//            task.resume()
//        }
//        // new receiver adding otp screen
//        else if otpType == 3
//        {
//            let url = URL(string: urlString)
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            let task = session.dataTask(with: url!) { data,response,error in
//                if error != nil
//                {
//                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    self.blurView.isHidden = true
//                    return
//                }
//                if let datas = data
//                {
//                    let dataInString = String(data: data!, encoding: String.Encoding.utf8)
//                    if dataInString == "null"
//                    {
//                        DispatchQueue.main.async{
//                            self.blurView.isHidden = true
//                            self.activityIndicator.stopAnimating()
//                            print("error")
//
//                        }
//                    }
//                    else
//                    {
//                        do
//                        {
//                            let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
//
//                            if data1.value(forKey: "StatusCode") as! Int != 200
//                            {
//                                DispatchQueue.main.async{
//                                    self.blurView.isHidden = true
//                                    self.activityIndicator.stopAnimating()
//
//                                    self.present(messages.failureMsg(data1.value(forKey: "message") as! String), animated: true, completion: nil)
//                                }
//
//                            }
//                            else
//                            {
//                                if data1.value(forKey: "StatusCode") as! Int == 200 && data1.value(forKey: "otpRefNo") as! String == "0"
//                                {
//                                    DispatchQueue.main.async{
//                                        self.blurView.isHidden = true
//                                        self.activityIndicator.stopAnimating()
//
//                                        self.present(messages.successMsg(data1.value(forKey: "message") as! String), animated:  true, completion: nil)
//                                    }
//                                }
//                                else if data1.value(forKey: "StatusCode") as! Int == 200 && data1.value(forKey: "otpRefNo") as! String != "0"
//                                {
//                                    DispatchQueue.main.async{
//                                        self.blurView.isHidden = true
//                                        self.activityIndicator.stopAnimating()
//
//                                        self.statusReff = data1.value(forKey: "otpRefNo") as! String
//                                        self.senderId = data1.value(forKey: "ID_Sender") as! String
//                                        self.receverId = data1.value(forKey: "ID_Receiver") as! String
//
//
//                                    }
//                                }
//                                else
//                                {
//                                    DispatchQueue.main.async{
//                                        self.blurView.isHidden = true
//                                        self.activityIndicator.stopAnimating()
//
//                                        self.present(messages.failureMsg(data1.value(forKey: "message") as! String), animated: true, completion: nil)
//                                    }
//                                }
//                            }
//                        }
//                        catch
//                        {
//                            DispatchQueue.main.async { [self] in
//                                self.blurView.isHidden = true
//                                self.activityIndicator.stopAnimating()
//                            }
//                        }
//                    }
//                }
//            }
//            task.resume()
//        }
//        // quickpay payment otp screen
//        if otpType == 4
//        {
//            // url searching
//            let url = URL(string: urlString)
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            let task = session.dataTask(with: url!) { data,response,error in
//                if error != nil
//                {
//                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    self.blurView.isHidden = true
//                    return
//                }
//                if let datas = data
//                {
//                    self.statusReff = String(data: datas, encoding: String.Encoding.utf8)!
//                }
//            }
//            task.resume()
//        }
    }
    
    func PaymentOtherSuccess(_ RTitle : String,_ RefNo : String, _ RDate : String, _ RTime : String) {
        DispatchQueue.main.async {
            let customRSAlert = self.storyboard?.instantiateViewController(withIdentifier: "rechargeSuccessAlert") as! rechargeSuccessAlertViewController
            customRSAlert.providesPresentationContextTransitionStyle = true
            customRSAlert.definesPresentationContext = true
            customRSAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customRSAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customRSAlert.delegate = self
            customRSAlert.sucHdrLtxt = RTitle
            customRSAlert.rechDateLtxt = "Date : \(RDate)"
            customRSAlert.rechTimeLtxt = "Time : \(RTime)"
            customRSAlert.rechReffNoLtxt = RefNo
            customRSAlert.fromAccLtxt = self.fromAcc
            customRSAlert.fromAccBranchLtxt = "Branch : \(self.fromAccBranchLtxt)"
            customRSAlert.rechHdrLtxt = "Paying To "
            customRSAlert.rechNumbLtxt = "A/C No : \(self.confirmBeneAccNo)"
            customRSAlert.rechNumDetailsLtxt = ""
            customRSAlert.rechAmountHdrLtxt = "Transfer Amount"
            customRSAlert.rechAmountLtxt = Double(self.amount)!.currencyIN
            customRSAlert.rechAmountDetailsLtxt = Double(self.amount)!.InWords
            self.present(customRSAlert, animated: true, completion: nil)
        }
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
    
 
    //FIXME: - confirmationI_Api_Call()
    func confirmOTPAPICall(url:String,type:Int) {
        
        var arguments = [String:String]()
        
        self.displayIndicator()
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg)
            return
        }
        
        if otpText.text?.count != 6{
            
            self.removeIndicator(showMessagge: true, message: invalidOtpMsg)
            return
            
        }
        
        let urlString = APIBaseUrlPart1 + url
        
        let datas = fullDetails[0]
        let OTPCode = self.otpText.text ?? ""
        let imei = ""
        
        let token = datas.token
        let statusRefference = self.statusReff
        let transactionID = transcationID.trimmingCharacters(in: .whitespacesAndNewlines) as? String ?? ""
        let mobileNum = mobNumb.trimmingCharacters(in: .whitespacesAndNewlines) as? String ?? ""
        let receiveID = receverId.trimmingCharacters(in: .whitespacesAndNewlines) as? String ?? ""
        let senderID = senderId.trimmingCharacters(in: .whitespacesAndNewlines) as? String ?? ""
        
        if type == 1{
        
        
        let accountNumber = datas.encryAcc
        let modules = datas.encryAccModule
        let BeneName = datas.encryBeneName
        let BeneIFSC = datas.encryIFSC
        let BeneAccountNumber = datas.encryBeneAccNumber
        let amount = datas.encryAmount
        let EftType = datas.encryMode
        let BeneAdd = datas.encryBeneAdd
       
        let pin  = datas.encryPin
        
        arguments = ["AccountNo":"\(accountNumber)",
                         "BeneName":"\(BeneName)",
                         "BeneIFSC":"\(BeneIFSC)",
                         "BeneAccountNumber":"\(BeneAccountNumber)",
                         "amount":"\(amount)",
                         "EftType" : "\(EftType)",
                         "BeneAdd":"\(BeneAdd)",
                         "OTPRef" : "\(statusRefference)",
                         "OTPCode" : "\(OTPCode)",
                         "token": token,
                         "BankKey": BankKey,
                         "imei":"\(imei)",
                         "Module" :  "\(modules)",
                         "BankVerified":"",
                         "BankHeader": BankHeader]
            
        }
        
        if type == 2{
            
            
            
            
            
            arguments = ["senderid":"\(senderID)",
                         "OTP":"\(OTPCode)","otpRefNo":"\(statusRefference)","MobileNo":"\(mobileNum)","imei":"\(imei)","token":"\(token)","BankKey":"\(BankKey)","BankHeader":"\(BankHeader)","BankVerified":""
            ]
            
        }
        
        if type == 3{
            
            arguments = ["senderid":"\(senderID)",
                         "OTP":"\(OTPCode)","otpRefNo":"\(statusRefference)","MobileNo":"\(mobileNum)","imei":"\(imei)","token":"\(token)","BankKey":"\(BankKey)","BankHeader":"\(BankHeader)","BankVerified":"","receiverid":"\(receiveID)"
            ]
            
            
        }
        
        if type == 4{
            
            arguments = ["senderid":"\(senderID)",
                         "OTP":"\(OTPCode)","otpRefNo":"\(statusRefference)","MobileNo":"\(mobileNum)","imei":"\(imei)","token":"\(token)","BankKey":"\(BankKey)","BankHeader":"\(BankHeader)","BankVerified":"","transcationID":"\(transactionID)","receiverid":"\(receiveID)"
            ]
            
         
            
        }
        
        APICallHandler(urlString: urlString, method: .post, parameter: arguments) { getResult in
            
            switch getResult{
                
            case .success(let datas):
                let httpStatuscode = datas.value(forKey: "HttpStatusCode") as! Int
                let StatusCode = datas.value(forKey: "StatusCode") as? NSNumber
                let message  = datas.value(forKey: "Message") as? String ?? ""
                let exMessage = datas.value(forKey: "ExMessage") as? String ?? ""
                
                if type == 1{
                if httpStatuscode == 200 && StatusCode == 200{
                    
                    let Message = datas.value(forKey: "Message") as! String
                    let RefID = datas.value(forKey: "RefID") as AnyObject
                    let Amount = datas.value(forKey: "Amount") as AnyObject
                    let CDate = Date().currentDate(format: "dd-MM-yyyy")
                    let CTime = Date().currentDate(format: "h:mm a")
                    self.PaymentOtherSuccess(Message,String(describing: RefID),CDate,CTime)
                    self.responseValueSettings.append(responseValue(title: "SUCCESS...!", msg: Message, resValue: keyValue(key: ["Ref.No","Amount"], value: [": "+String(describing: RefID), ": "+String(describing: Amount)])))
                    
                }else if StatusCode == -1 && httpStatuscode == 500{
                    DispatchQueue.main.async {
                        let checkMessage = message == "" ? exMessage : message
                        self.present(messages.msg(checkMessage), animated: true,completion: nil)
                    }
                }
                else
                {
                    self.attempt = self.attempt - 1
                    if self.attempt > 0
                    {
                        let otpAtt = String(self.attempt)
                        DispatchQueue.main.async {
                            
                            self.present(messages.failureMsg(datas.value(forKey: "ExMessge") as! String), animated: true, completion: nil)
                            self.errorMsg.text = "You are left with \(otpAtt) more attempt"
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            
                            let failedQuitOtp = UIAlertController(title: "FAILED", message: (datas.value(forKey: "ExMessge") as! String), preferredStyle: UIAlertController.Style.alert)
                            failedQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
                                //after user press ok, the following code will be execute
                                self.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
                            }))
                            self.present(failedQuitOtp, animated: true, completion: nil)
                        }
                    }
                }
            }
                
                if type == 2{
                    
                    if StatusCode == 200 {
                        
                        
                        DispatchQueue.main.async {
                            

                            let successQuitOtp = UIAlertController(title: "SUCCESS", message: message, preferredStyle: UIAlertController.Style.alert)
                            successQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
                                //after user press ok, the following code will be execute
                                self.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
                            }))
                            self.present(successQuitOtp, animated: true, completion: nil)
                        }
                        
                      
                        
                    }else{
                                
                                
                       DispatchQueue.main.async {
                                    
                            let failedQuitOtp = UIAlertController(title: "FAILED", message: message, preferredStyle: UIAlertController.Style.alert)
                            failedQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
                                            //after user press ok, the following code will be execute
                            self.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
                            }))
                            self.present(failedQuitOtp, animated: true, completion: nil)
                                    
                        }
                        
                    }
                    
                }
                
                if type == 3{
                    
                    if StatusCode == 200 {
                        
                        
                        DispatchQueue.main.async {
                            

                            let successQuitOtp = UIAlertController(title: "SUCCESS", message: message, preferredStyle: UIAlertController.Style.alert)
                            successQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
                                //after user press ok, the following code will be execute
                                self.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
                            }))
                            self.present(successQuitOtp, animated: true, completion: nil)
                        }
                        
                      
                        
                    }else{
                                
                                
                       DispatchQueue.main.async {
                                    
                            let failedQuitOtp = UIAlertController(title: "FAILED", message: message, preferredStyle: UIAlertController.Style.alert)
                            failedQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
                                            //after user press ok, the following code will be execute
                            self.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
                            }))
                            self.present(failedQuitOtp, animated: true, completion: nil)
                                    
                        }
                        
                    }
                    
                }
                
                if type == 4{
                    
                    if StatusCode == 200 {
                        
                        DispatchQueue.main.async {
                            let CDate = Date().currentDate(format: "dd-MM-yyyy")
                            let CTime = Date().currentDate(format: "h:mm a")
                            self.PaymentSuccess(message,"",CDate,CTime)
                        }
                        
                    }else{
                        
                        DispatchQueue.main.async {
                                     
                             let failedQuitOtp = UIAlertController(title: "FAILED", message: message, preferredStyle: UIAlertController.Style.alert)
                             failedQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
                                             //after user press ok, the following code will be execute
                             self.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
                             }))
                             self.present(failedQuitOtp, animated: true, completion: nil)
                                     
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
    
    //FIXME: - CHECK_CONFIRM_OTP_API_CALL()
    func checkOtpType(type:Int) {
        switch type{
        case 1:
            // imps/rtgs/neft payment otp screen
            confirmOTPAPICall(url: "/AccountSummary/NEFTRTGSPayment", type: 1)
        case 2:
            // new sender adding otp screen
            confirmOTPAPICall(url: "/Customer/MTVerifySenderOTP", type: 2)
        case 3:
            // new receiver adding otp screen
            confirmOTPAPICall(url: "/Customer/MTVerifyReceiverOTP", type: 3)
        case 4:
            // quick pay otp screen
            confirmOTPAPICall(url: "/Customer/MTVerifyPaymentOTP", type: 4)
        
        default:
            print(otpType)
        }
    }
    
    
    
    
    @IBAction func ConfirmOTP(_ sender: UIButton)
    {
        
        
        
        
        checkOtpType(type: otpType)
        
//        errorMsg.text = ""
//        blurView.isHidden = false
//        activityIndicator.startAnimating()
//
//        // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//                self?.activityIndicator.startAnimating()
//                self?.blurView.isHidden = true
//            }
//            return
//        }
//        if (otpText.text?.count)! != 6
//        {
//            blurView.isHidden = true
//            activityIndicator.stopAnimating()
//
//            self.present(messages.msg(invalidOtpMsg), animated: true, completion: nil)
//            return
//        }
        
        
        
//        let encryptedOTP = self.instanceOfEncryption.encryptUseDES(otpText.text!.trimmingCharacters(in: .whitespacesAndNewlines), key: "Agentscr") as String
//        let encryptedReff = self.instanceOfEncryption.encryptUseDES(statusReff.trimmingCharacters(in: .whitespacesAndNewlines), key: "Agentscr") as String
//        let encryptedSenderID = self.instanceOfEncryption.encryptUseDES(senderId.trimmingCharacters(in: .whitespacesAndNewlines), key: "Agentscr") as String
//        let encryptedMobNumb = instanceOfEncryption.encryptUseDES(mobNumb.trimmingCharacters(in: .whitespacesAndNewlines), key: "Agentscr") as String
//        let encryptedReceiverID = self.instanceOfEncryption.encryptUseDES(receverId.trimmingCharacters(in: .whitespacesAndNewlines), key: "Agentscr") as String
//        let encryptedTransactionID = self.instanceOfEncryption.encryptUseDES(transcationID.trimmingCharacters(in: .whitespacesAndNewlines), key: "Agentscr") as String

        
        
       
            
            
      
        /*if otpType == 1
        {
            // url searching
            let url = URL(string: BankIP + APIBaseUrlPart + "/NEFTRTGSPayment?AccountNo=\(fullDetails[0].encryAcc)&Module=\(fullDetails[0].encryAccModule)&BeneName=\(fullDetails[0].encryBeneName)&BeneIFSC=\(fullDetails[0].encryIFSC)&BeneAccountNumber=\(fullDetails[0].encryBeneAccNumber)&amount=\(fullDetails[0].encryAmount)&EftType=\(fullDetails[0].encryMode)&BeneAdd=\(fullDetails[0].encryBeneAdd)&Pin=\(fullDetails[0].encryPin)&OTPRef=\(encryptedReff)&OTPCode=\(encryptedOTP)&imei=\(fullDetails[0].imei)&token=\(fullDetails[0].token)&BankKey=\(BankKey)")
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let task = session.dataTask(with: url!) { data,response,error in
                if error != nil
                {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)

                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                    return
                }
                if let datas = data
                {
                    do
                    {
                        let datas = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        let httpStatuscode = datas.value(forKey: "HttpStatusCode") as! Int

                        if httpStatuscode == 200 && datas.value(forKey: "StatusCode") as? Int == 200
                        {
                            DispatchQueue.main.async { [weak self] in
                                let Message = datas.value(forKey: "Message") as! String
                                let RefID = datas.value(forKey: "RefID") as AnyObject
//                                let Amount = datas.value(forKey: "Amount") as AnyObject
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()

                                let CDate = Date().currentDate(format: "dd-MM-yyyy")
                                let CTime = Date().currentDate(format: "h:mm a")
                                self?.PaymentOtherSuccess(Message,String(describing: RefID),CDate,CTime)
//                                self?.responseValueSettings.append(responseValue(title: "SUCCESS...!", msg: Message, resValue: keyValue(key: ["Ref.No","Amount"], value: [": "+String(describing: RefID), ": "+String(describing: Amount)])))
                            }

                        }
                        else
                        {
                            self.attempt = self.attempt - 1
                            if self.attempt > 0
                            {
                                let otpAtt = String(self.attempt)
                                DispatchQueue.main.async { [weak self] in
                                    self?.blurView.isHidden = true
                                    self?.activityIndicator.stopAnimating()
                                    self?.present(messages.failureMsg(datas.value(forKey: "ExMessge") as! String), animated: true, completion: nil)
                                    self?.errorMsg.text = "You are left with \(otpAtt) more attempt"
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async { [weak self] in
                                    self?.blurView.isHidden = true
                                    self?.activityIndicator.stopAnimating()

                                    let failedQuitOtp = UIAlertController(title: "FAILED", message: (datas.value(forKey: "ExMessge") as! String), preferredStyle: UIAlertController.Style.alert)
                                    failedQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
                                        //after user press ok, the following code will be execute
                                        self?.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
                                    }))
                                    self?.present(failedQuitOtp, animated: true, completion: nil)
                                }
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
            task.resume()
        } */
        // new sender adding otp screen
//        if otpType == 2
//        {
//            // url searching
//            let url = URL(string: BankIP + APIBaseUrlPart + "/MTVerifySenderOTP?senderid=\(encryptedSenderID)&OTP=\(encryptedOTP)&otpRefNo=\(encryptedReff)&mobile=\(encryptedMobNumb)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            let task = session.dataTask(with: url!) { data,response,error in
//                if error != nil
//                {
//                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    self.blurView.isHidden = true
//                    return
//                }
//                if let datas = data
//                {
//                    do
//                    {
//                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
//                        print(data1)
//                        if data1.value(forKey: "StatusCode") as? Int == 200
//                        {
//                            DispatchQueue.main.async { [weak self] in
//                                self?.blurView.isHidden = true
//                                self?.activityIndicator.stopAnimating()
//
//                                let successQuitOtp = UIAlertController(title: "SUCCESS", message: (data1.value(forKey: "message") as! String), preferredStyle: UIAlertController.Style.alert)
//                                successQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
//                                    //after user press ok, the following code will be execute
//                                    self?.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
//                                }))
//                                self?.present(successQuitOtp, animated: true, completion: nil)
//                            }
//
//                        }
//                        else
//                        {
//                            DispatchQueue.main.async { [weak self] in
//                                self?.blurView.isHidden = true
//                                self?.activityIndicator.stopAnimating()
//
//                                let failedQuitOtp = UIAlertController(title: "FAILED", message: (data1.value(forKey: "message") as! String), preferredStyle: UIAlertController.Style.alert)
//                                failedQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
//                                        //after user press ok, the following code will be execute
//                                    self?.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
//                                }))
//                                self?.present(failedQuitOtp, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                    catch
//                    {
//                        DispatchQueue.main.async { [self] in
//                            self.blurView.isHidden = true
//                            self.activityIndicator.stopAnimating()
//                        }
//                    }
//                }
//            }
//            task.resume()
//
//        }
//        // new receiver adding otp screen
//        if otpType == 3
//        {
//            // url searching
//            let url = URL(string: BankIP + APIBaseUrlPart + "/MTVerifyReceiverOTP?senderid=\(encryptedSenderID)&receiverid=\(encryptedReceiverID)&OTP=\(encryptedOTP)&otpRefNo=\(encryptedReff)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            let task = session.dataTask(with: url!) { data,response,error in
//                if error != nil
//                {
//                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    self.blurView.isHidden = true
//                    return
//                }
//                if let datas = data
//                {
//                    do
//                    {
//                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
//                        if data1.value(forKey: "StatusCode") as? Int == 200
//                        {
//                            DispatchQueue.main.async { [weak self] in
//                                self?.blurView.isHidden = true
//                                self?.activityIndicator.stopAnimating()
//
//                                let successQuitOtp = UIAlertController(title: "SUCCESS", message: (data1.value(forKey: "message") as! String), preferredStyle: UIAlertController.Style.alert)
//                                successQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
//                                    //after user press ok, the following code will be execute
//                                    self?.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
//                                }))
//                                self?.present(successQuitOtp, animated: true, completion: nil)
//                            }
//
//                        }
//                        else
//                        {
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.blurView.isHidden = true
//                                self?.activityIndicator.stopAnimating()
//
//                                let failedQuitOtp = UIAlertController(title: "FAILED", message: (data1.value(forKey: "message") as! String), preferredStyle: UIAlertController.Style.alert)
//                                failedQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
//                                    //after user press ok, the following code will be execute
//                                    self?.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
//                                }))
//                                self?.present(failedQuitOtp, animated: true, completion: nil)
//                            }
//
//                        }
//                    }
//                    catch
//                    {
//                        DispatchQueue.main.async { [self] in
//                            self.blurView.isHidden = true
//                            self.activityIndicator.stopAnimating()
//                        }
//                    }
//                }
//            }
//            task.resume()
//        }
//        // quick pay otp screen
//        else if otpType == 4
//        {
//            let url = URL(string: BankIP + APIBaseUrlPart + "/MTVerifyPaymentOTP?senderid=\(encryptedSenderID)&receiverid=\(encryptedReceiverID)&transcationID=\(encryptedTransactionID)&OTP=\(encryptedOTP)&otpRefNo=\(otpText.text!)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            let task = session.dataTask(with: url!) { data,response,error in
//                if error != nil
//                {
//                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//
//                    self.activityIndicator.stopAnimating()
//                    self.blurView.isHidden = true
//                    return
//                }
//                if let datas = data
//                {
//                    let dataInString = String(data: data!, encoding: String.Encoding.utf8)
//                    if dataInString == "null"
//                    {
//                        DispatchQueue.main.async{
//                            self.blurView.isHidden = true
//                            self.activityIndicator.stopAnimating()
//                        }
//                    }
//                    else
//                    {
//                        do
//                        {
//                            DispatchQueue.main.async { [self] in
//                                self.blurView.isHidden = true
//                                self.activityIndicator.stopAnimating()
//                            }
//
//                            let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
//                            if data1.value(forKey: "StatusCode") as! Int == 200
//                            {
//                                DispatchQueue.main.async{
//
//                                    let CDate = Date().currentDate(format: "dd-MM-yyyy")
//                                    let CTime = Date().currentDate(format: "h:mm a")
//                                    self.PaymentSuccess(data1.value(forKey: "message") as! String,"",CDate,CTime)
//
//                                }
//                            }
//                            else
//                            {
//                                let failedQuitOtp = UIAlertController(title: "FAILED", message: (data1.value(forKey: "message") as! String), preferredStyle: UIAlertController.Style.alert)
//                                failedQuitOtp.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
//                                    //after user press ok, the following code will be execute
//                                    self.performSegue(withIdentifier: "otpToHomeScreen", sender: self)
//                                }))
//                                self.present(failedQuitOtp, animated: true, completion: nil)
//                            }
//                        }
//                        catch
//                        {
//                            DispatchQueue.main.async { [self] in
//                                self.blurView.isHidden = true
//                                self.activityIndicator.stopAnimating()
//                            }
//                        }
//                    }
//                }
//            }
//            task.resume()
//        }
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

        if textField.isEqual(otpText)
        {
            maxLength = 6
        }
        
        if newLength == maxLength+1{
            textField.resignFirstResponder()
        }


        return newLength <= maxLength
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
        customQPSAlert.senderAccDetaLtxt = "\(accounts)\n\(fromAccBranchLtxt)"
        customQPSAlert.senderMobLtxt = senMob
        customQPSAlert.receiverNameLtxt = recName
        customQPSAlert.receiverAccDetaLtxt = recAcc
        customQPSAlert.receiverMobLtxt = recMob
        customQPSAlert.qpAmountLtxt = Double(amountText)!.currencyIN
        customQPSAlert.qpAmountDetailsLtxt = Double(amountText)!.InWords
        DispatchQueue.main.async {
            self.present(customQPSAlert, animated: true, completion: nil)
        }
        
    }
}

extension PaymentOTPViewController: qpConfSuccessAlertDelegate{

    func qpShareScreenShot(_ img: UIImage, _ Share : UIButton) {
        self.ShareImg = img
        self.ShareB = Share
    }
    func qpokButtonTapped() {
        print("OK")
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
extension PaymentOTPViewController: rechargeConfSuccessAlertDelegate{

    func ShareScreenShot(_ img: UIImage, _ Share : UIButton) {
        self.ShareImg = img
        self.ShareB = Share
    }
    
    func okButtonTapped() {
        print("OK")
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
