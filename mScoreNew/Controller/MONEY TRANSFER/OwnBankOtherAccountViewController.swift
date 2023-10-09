//
//  OwnBankViewController.swift
//  mScoreNew
//
//  Created by Perfect on 05/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import DropDown

class OwnBankOtherAccountViewController: NetworkManagerVC,UITextFieldDelegate
{
    
    @IBOutlet weak var recAccType       : UIButton!{
        didSet{
            // rec acc type dropdown button title settings
            recAccType.setTitle(recAccTp[0], for: .normal)
        }
    }
    @IBOutlet weak var accNumber        : UITextField!{
        didSet{
            // number typing in the text field is not shown
            accNumber.isSecureTextEntry = !accNumber.isSecureTextEntry
            accNumber.delegate      = self
        }
    }
    @IBOutlet weak var accNumb          : UILabel!
    @IBOutlet weak var confAccNumber    : UITextField!{
        didSet{
            confAccNumber.delegate  = self
        }
    }
    @IBOutlet weak var confAccNumb      : UILabel!
    @IBOutlet weak var amount           : UITextField!{
        didSet{
            amount.delegate         = self
            amount.setBottomBorder(UIColor.lightGray,1.0)
            
        }
    }
    @IBOutlet weak var amountMsg            : UILabel!
    @IBOutlet weak var amountInWords        : UILabel!
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
    @IBOutlet weak var fromAccNoL: UILabel!
    @IBOutlet weak var fromBranchL: UILabel!
    @IBOutlet weak var fromBalance: UILabel!
    @IBOutlet weak var fundTransferLimitL: UILabel!
    @IBOutlet weak var RemarkTF: UITextField! {
        didSet {
            RemarkTF.delegate         = self
            RemarkTF.setBottomBorder(UIColor.lightGray,1.0)
        }
    }
    
    // set var for get data in the time of segue
    var TokenNo      = String()
    var customerId   = String()
    var pin          = String()
    var dmenuDic     = [String: String]()
    // values for reciver acc type drop down
    let recAccTp     = rechargeAccType
    // acc dropdown settings
    var accDrop = DropDown()
    lazy var accDropDowns: [DropDown] = { return[self.accDrop] } ()
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
    private let parserViewModel : ParserViewModel = ParserViewModel()
    let group = DispatchGroup()
    
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
        setAccTypeDropDown()
        
        nextButtonInClick.load().addTarget(self, action: #selector(self.mobilePadNextAction(_:)),
                                           for: UIControl.Event.touchUpInside)
        
        fromAccNoL.text     = "A/C No : " + (payingFromAccDetails.value(forKey: "AccountNumber") as! String)
        fromBranchL.text    = (payingFromAccDetails.value(forKey: "BranchName") as! String)
        fromBalance.text    = (payingFromAccDetails.value(forKey: "Balance") as! Double).currencyIN
        self.module = payingFromAccDetails.value(forKey: "typeShort") as? String ?? ""
        FundTransferLimit()
    }
    
    func FundTransferLimit() {
        // network reachability checking
        
        if Reachability.isConnectedToNetwork(){
            self.parserViewModel.mainThreadCall {
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        
        let urlPath = "/AccountSummary/FundTransferLimit"
        let arguMents = ["ReqMode" : "18",
                         "Token" : TokenNo,
                         "BankKey" : BankKey,
                         "BankHeader" : BankHeader]
        
        
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            switch getResult{
            case.success(let datas):
                
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    
                    self.MaximumAmount = 0.0
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "FundTransferLimit")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        self.MaximumAmount = modelInfo.value(forKey: "MaximumAmount") as? Double ?? 0.00
                    }
                    self.group.leave()
                }
            case.failure(let catchedErrors):
                self.parserViewModel.parserErrorHandler(catchedErrors, vc: self)
                self.group.leave()
            }
            
            DispatchQueue.global(qos:.default).async {
                
                self.group.wait()
                
                DispatchQueue.main.async {
                    
                    if self.MaximumAmount > 0.0 {
                        self.fundTransferLimitL.text = "Transfer Upto " + self.MaximumAmount.currencyIN + " Instantly."
                    }else{
                        self.fundTransferLimitL.text = ""
                    }
                    
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
        
        
    }
    
    @objc func mobilePadNextAction(_ sender : UIButton){
        
        //Click action
        if accNumber.isFirstResponder{
            confAccNumber.becomeFirstResponder()
        }
        else if confAccNumber.isFirstResponder{
            amount.becomeFirstResponder()
        }
        else if amount.isFirstResponder{
            RemarkTF.becomeFirstResponder()
        }
        else if RemarkTF.isFirstResponder{
            mobilePadNextButton.isHidden = true
            view.endEditing(true)
        }
    }
    // acc drop values settings

    // acc type drop values settings
    func setAccTypeDropDown()
    {
        recAccDrop.anchorView      = recAccType
        recAccDrop.bottomOffset    = CGPoint(x: 0, y:40)
        recAccDrop.dataSource      = recAccTp
        recAccDrop.backgroundColor = UIColor.white
        recAccDrop.selectionAction = {[weak self] (index, item) in
            self?.recAccType.setTitle(item, for: .normal)
        }
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func receiverType(_ sender: UIButton)
    {
        recAccDrop.show()
    }
    
    @IBAction func ReSet(_ sender: UIButton) {
        self.accNumber.text!        = ""
        accNumb.text                = ""
        self.confAccNumber.text!    = ""
        confAccNumb.text            = ""
        self.amount.text!           = ""
        amountMsg.text              = ""
        amountInWords.text          = ""
        fundTransferLimitL.text     = ""
        self.RemarkTF.text!         = ""
        payBtn.setTitle("PAY", for: .normal)
        viewDidLoad()
    }
    
    
    @IBAction func submit(_ sender: UIButton)
    {
        accNumb.text        = ""
        confAccNumb.text    = ""
        amountMsg.text      = ""
        // selected acc number without module
        acc             = payingFromAccDetails.value(forKey: "AccountNumber") as! String
        oneAcc          = String(acc.dropLast(5))
        if recAccType.currentTitle! == "Savings Bank"
        {
            receiverAccType = "SB"
        }
        else if recAccType.currentTitle! == "Current Account"
        {
            receiverAccType = "CA"
        }
        else if recAccType.currentTitle! == "Cash Credit"
        {
            receiverAccType = "OD"
        }
        else if recAccType.currentTitle! == "Member loan"
        {
            receiverAccType = "ML"
        }
        else if recAccType.currentTitle! == "Recurring deposit"
        {
            receiverAccType = "RD"
        }
        else if recAccType.currentTitle! == "Jewell loan"
        {
            receiverAccType = "JL"
        }
        else
        {
            receiverAccType = "GDS"
        }
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        let accNum = self.accNumber.text!
        if accNum.count != 12 || Int(accNum) == nil
        {
            accNumb.text = "Invalid account number."
            return
        }
        confAccNum = self.confAccNumber.text!
        if confAccNum.count != 12 || Int(confAccNum) == nil
        {
            confAccNumb.text = "Account number do not match."
            return
        }
        let amn = Int(self.amount.text!)
        if amn == nil
        {
           amountMsg.text = amountToReachargeMsg
            return
        }
        if MaximumAmount > 0.0 {
            if amn! < 1 || amn! > Int(MaximumAmount)
            {
                amountMsg.text = amountLimitMsg + MaximumAmount.currencyIN
                return
            }
        }
        if confAccNum != accNum
        {
            confAccNumb.text = "Account number do not match."
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
        
        self.PaymentConfirmation()

    }
    
    func FundTransferIntraBank() {
        DispatchQueue.main.async {
            self.blurView.isHidden  = false
            self.activityIndicator.startAnimating()
        }
       
//        let encryptedFromAcc    = self.instanceOfEncryption.encryptUseDES(oneAcc,
//                                                                          key: "Agentscr") as String
//        let encryptedFromModule = self.instanceOfEncryption.encryptUseDES(self.module ,
//                                                                          key: "Agentscr") as String
//        let encryptedRecAccType = self.instanceOfEncryption.encryptUseDES(receiverAccType ,
//                                                                          key: "Agentscr") as String
//        let encryptedToAcc      = self.instanceOfEncryption.encryptUseDES(confAccNum ,
//                                                                          key: "Agentscr") as String
//        let encryptedAmount     = self.instanceOfEncryption.encryptUseDES(self.amount.text ,
//                                                                          key: "Agentscr") as String
//        let encryptedPin        = self.instanceOfEncryption.encryptUseDES(self.pin ,
//                                                                          key: "Agentscr") as String
//        let encryptedQrCode     = self.instanceOfEncryption.encryptUseDES("novalue" ,
//                                                                          key: "Agentscr") as String
//        let encryptedRemark     = self.instanceOfEncryption.encryptUseDES(RemarkTF.text ,
//                                                                          key: "Agentscr") as String
        
        let encryptedFromAcc    = "\(oneAcc)"
        let encryptedFromModule = "\(self.module)"
        let encryptedRecAccType = "\(receiverAccType)"
        let encryptedToAcc      = "\(confAccNum)"
        let encryptedAmount     = "\(self.amount.text ?? "")"
        let encryptedPin        = "\(self.pin)"
        let encryptedQrCode     = "novalue"
        let encryptedRemark     = RemarkTF.text!
        
                                            
        
        
        let parameter = ["AccountNo":encryptedFromAcc,"Module":"\(encryptedFromModule)","ReceiverModule":"\(encryptedRecAccType)","amount":"\(encryptedAmount)","ReceiverAccountNo":"\(encryptedToAcc)","Pin":"\(encryptedPin)","QRCode":"\(encryptedQrCode)","Remark":"\(encryptedRemark)","imei":"\(UDID)","token":"\(self.TokenNo)","BankKey":"\(BankKey)","BankHeader":"\(BankHeader)"]
        
        print(parameter)
                      
        let url = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/FundTransferIntraBank")
        
        var Request = URLRequest(url: url!)
        Request.httpMethod = "POST"
        Request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        Request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do{
            
            Request.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            
        }catch let error{
            print(error.localizedDescription + "  json error")
            return
        }
                      

        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: Request) { data,response,error in
            if error != nil
            {
                DispatchQueue.main.async{
                    self.blurView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                }
                return
            }
            if let datas = data
            {
                let dataInString = String(data: datas, encoding: String.Encoding.utf8)
                let responseData = dataInString?.range(of: "{\"acInfo\":null")
               // if responseData == nil
                //{
                    do
                    {
                        var transAmount = ""
                        DispatchQueue.main.async {
                            transAmount = self.amount.text!
                        }
                        let resdatas       = try JSONSerialization.jsonObject(with: datas, options: .mutableContainers) as! NSDictionary
                        let info  = resdatas.value(forKey: "FundTransferIntraBankList") as? NSDictionary ?? [:]
                        let detailList = info.value(forKey: "FundTransferIntraBankList") as? [NSDictionary] ?? []
                        let StatusCode  = info.value(forKey: "StatusCode") as? Int ?? 0
                        let StatusMessage = info.value(forKey: "StatusMessage") as? String ?? ""
                        let RefID       = detailList.first?.value(forKey: "RefID") as? Int ?? 00
                        let EXMessage = resdatas.value(forKey: "EXMessage") as? String ?? ""
                        let CDate = detailList.first?.value(forKey: "TransDate") as? String ??  Date().currentDate(format: "dd-MM-yyyy")
                        let CTime = Date().currentDate(format: "h:mm a")
                        
                        if StatusCode == 1
                        {
                            self.oneAcc             = ""
                            self.module             = ""
                            self.receiverAccType    = ""
                            self.confAccNum         = ""
                            DispatchQueue.main.async { [weak self] in
                                
                                self?.accNumber.text!             = ""
                                self?.accNumb.text                = ""
                                self?.confAccNumber.text!         = ""
                                self?.confAccNumb.text            = ""
                                self?.amount.text!                = ""
                                self?.amountMsg.text              = ""
                                self?.amountInWords.text          = ""
                                self?.fundTransferLimitL.text     = ""
                                self?.RemarkTF.text!              = ""
                                self?.payBtn.setTitle("PAY", for: .normal)
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                self?.PaymentSuccess(StatusMessage, String(RefID), CDate, CTime,transAmount,payeeAcc: encryptedToAcc, recActype: encryptedRecAccType)
                                
                                
                            }
                        }
                        else if StatusCode == 4
                        {
                            
                            DispatchQueue.main.async { [weak self] in
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                self?.present(messages.errorMsgWithAppIcon(EXMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
                            }
                        }
                        else if StatusCode == 5
                        {
                            DispatchQueue.main.async { [weak self] in
                                self?.blurView.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                self?.present(messages.errorMsgWithAppIcon(EXMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)
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
               // }
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
        customRCAlert.rechNumbLtxt = "A/C No : \(confAccNumber.text!)"
        customRCAlert.rechNumDetailsLtxt = "A/C Type : \(recAccType.currentTitle!)"
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
        customRSAlert.rechReffNoLtxt = RefNo
        customRSAlert.fromAccLtxt = fromAcc
        customRSAlert.fromAccBranchLtxt = "Branch : \(payingFromAccDetails.value(forKey: "BranchName") as! String)"
        customRSAlert.rechHdrLtxt = "Paying To "
        customRSAlert.rechNumbLtxt = "A/C No : \(confAccNumber.text! == "" ? payeeAcc : confAccNumber.text!) (\(receiverAccType == "" ? recActype : receiverAccType))"
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
        if textField.isEqual(accNumber)
        {
            maxLength = 12
        }
        else if textField.isEqual(confAccNumber)
        {
            maxLength = 12
        }
        else if textField.isEqual(amount)
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
        
        if textField.isEqual(accNumb) || textField.isEqual(confAccNumb) || textField.isEqual(amount) || textField.isEqual(RemarkTF)
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
        if textField.isEqual(accNumb) || textField.isEqual(confAccNumb) || textField.isEqual(amount) || textField.isEqual(RemarkTF)
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
        
        if accNumber.isFirstResponder
        {
            DispatchQueue.main.async { () -> Void in
                nextButtonInClick.ShowKeyboard(view: self.view)
            }
        }
        else if confAccNumber.isFirstResponder
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

}

extension OwnBankOtherAccountViewController: rechargeConfSuccessAlertDelegate{

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
