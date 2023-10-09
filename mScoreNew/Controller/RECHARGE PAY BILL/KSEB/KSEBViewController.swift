//
//  KSEBViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import DropDown



class KSEBViewController: NetworkManagerVC, UITextFieldDelegate
{
    
    @IBOutlet weak var enterConsumerName    : UILabel!
    @IBOutlet weak var enterPhoneNum        : UILabel!
    @IBOutlet weak var enterConsumerNum     : UILabel!
    @IBOutlet weak var enterBillNum         : UILabel!
    @IBOutlet weak var enterBillAmount      : UILabel!
    @IBOutlet weak var consumerName         : UITextField!
    @IBOutlet weak var mobNumber            : UITextField!
    @IBOutlet weak var consumerNumber       : UITextField!
    @IBOutlet weak var selectSection        : UIButton!
    @IBOutlet weak var billNum              : UITextField!
    @IBOutlet weak var billAmount           : UITextField!
    @IBOutlet weak var amountInWords        : UILabel!
    @IBOutlet weak var payBtn               : UIButton!
    @IBOutlet weak var accNumber            : UIButton!
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    
    // instance of encryption settings
    var instanceOfEncryption: Encryption = Encryption()
    // acc drop down settings
    var accDrop = DropDown()
    lazy var accDropDowns: [DropDown] = { return[self.accDrop] } ()
    
    // variable for token and pin for getting value from home screen in the time of segue
    var TokenNo                 = String()
    var pin                     = String()
    var customerId              = String()
    var oneAcc                  = String()
    var module                  = String()
    var sectionCode             = String()
    var OwnAccountdetailsList   = [NSDictionary]()
    var fromAccBranchLtxt       = String()
    var AccountdetailsList      = [String]()
    var ShareImg                = UIImage()
    var ShareB                  = UIButton()
    var keyboardHeight          = CGFloat()
    
    
    private var parserViewModel : ParserViewModel = ParserViewModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    //// Do any additional setup after loading the view.
        // keyboard hide settings
        self.hideKeyboardWhenTappedAround()
        // acc drop down value and drop down possitin settings
        accDropDowns.forEach { $0.dismissMode = .onTap }
        accDropDowns.forEach { $0.direction = .any }
//        setAccDropDown()
        
        

        // set section name as an empty string
        selectedSectionName = ""
        // udid generation
        UDID = udidGeneration.udidGen()
        // border settings
        consumerName.setBottomBorder(UIColor.lightGray,1.0)
        mobNumber.setBottomBorder(UIColor.lightGray,1.0)
        consumerNumber.setBottomBorder(UIColor.lightGray,1.0)
        billNum.setBottomBorder(UIColor.lightGray,1.0)
        billAmount.setBottomBorder(UIColor.lightGray,1.0)
        
        nextButtonInClick.load().addTarget(self, action: #selector(self.mobilePadNextAction(_:)), for: UIControl.Event.touchUpInside)
        
        OwnAccounDetails()
        
      

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//       if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//           UIView.animate(withDuration: 0.1, animations: { () -> Void in
//               self.view.frame.origin.y -= keyboardSize.height
//               self.view.layoutIfNeeded()
//           })
//       }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//       if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//           UIView.animate(withDuration: 0.1, animations: { () -> Void in
//               self.view.frame.origin.y += keyboardSize.height
//               self.view.layoutIfNeeded()
//           })
//       }
//    }
    
    
    //FIXME: ========= accountUIUpdateDetails() ==========
    fileprivate func accountUIUpdateDetails(info:[NSDictionary]) {
        DispatchQueue.main.async {
            self.accNumber.setTitle((info.first!.value(forKey: "AccountNumber") as? String ?? ""), for: .normal)
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
        }
    
       }
    
    
    
    func keyboardWillShow()
    {
        if mobNumber.isFirstResponder
        {
            DispatchQueue.main.async { () -> Void in
                nextButtonInClick.ShowKeyboard(view: self.view)
            }
        }

        else if consumerNumber.isFirstResponder
        {
            DispatchQueue.main.async { () -> Void in
                nextButtonInClick.ShowKeyboard(view: self.view)
            }
        }
            
        else if billAmount.isFirstResponder
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
        if mobNumber.isFirstResponder{
            consumerNumber.becomeFirstResponder()
        }
        else if consumerNumber.isFirstResponder{
            billNum.becomeFirstResponder()
        }
        else if billAmount.isFirstResponder{
            mobilePadNextButton.isHidden = true
            view.endEditing(true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
    //// whenever the view will appear this func works
        // if the section is selected the name is setted as the title of selectsection button
        if selectedSectionName != ""
        {
            selectSection.setTitleColor(UIColor.darkGray, for: UIControl.State.normal)
            selectSection.setTitle(selectedSectionName, for: .normal)
        }
    }
   
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //FIXME: ========= setAccDropDown() ==========
    func setAccDropDown()
    {
        accDrop.anchorView      = accNumber
        accDrop.bottomOffset    = CGPoint(x:0, y:0)
        accDrop.dataSource      = AccountdetailsList
        accDrop.backgroundColor = UIColor.white
        accDrop.selectionAction = {[weak self] (index, item) in
            self?.accNumber.setTitle(item, for: .normal)
            self?.fromAccBranchLtxt = self?.OwnAccountdetailsList[index].value(forKey: "BranchName") as! String
        }
    }
  
    
    @IBAction func Back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    // action of acc num selection button
    @IBAction func accNum(_ sender: UIButton)
    {
        accDrop.show()
    }
    
    // action of clear all button
    @IBAction func clearAll(_ sender: UIButton)
    {
        // settings all value to empty
        self.enterConsumerName.text = ""
        self.enterPhoneNum.text     = ""
        self.enterConsumerNum.text  = ""
        self.enterBillNum.text      = ""
        self.enterBillAmount.text   = ""
        self.consumerName.text      = ""
        self.mobNumber.text         = ""
        self.consumerNumber.text    = ""
        self.consumerName.text      = ""
        self.billNum.text           = ""
        self.billAmount.text        = ""
        selectSection.setTitle("Select section name", for: .normal)
        selectSection.setTitleColor(UIColor.black, for: .normal)
    }
    // action of proceed to pay button
    @IBAction func proceedToPay(_ sender: UIButton)
    {
        // setting all error message to empty
        self.enterConsumerName.text = ""
        self.enterPhoneNum.text     = ""
        self.enterConsumerNum.text  = ""
        self.enterBillNum.text      = ""
        self.enterBillAmount.text   = ""
        selectSection.setTitleColor(UIColor.darkGray, for: UIControl.State.normal)
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
    //// error message settings
        // error message for no value in consumername
        if self.consumerName.text! == ""
        {
            self.enterConsumerName.text = "Please enter consumer name"
            return
        }
        // error message for no value & less than ten digit in phone number
        let phoneNumb = self.mobNumber.text
        if phoneNumb?.count != 10 ||  phoneNumb! == ""
        {
            self.enterPhoneNum.text = "Phone number must be 10 digit"
            return
        }
        // error message for no value in consumer number
        if self.consumerNumber.text! == ""
        {
            self.enterConsumerNum.text = "Please enter the consumer number"
            return
        }
        // error message for no value in section
        if selectSection.titleLabel?.text == "Select section name"
        {
            selectSection.setTitleColor(UIColor.blue, for: UIControl.State.normal)
            return
        }
        // error message for no value in bill number
        if self.billNum.text! == ""
        {
            self.enterBillNum.text = "Please enter bill number"
            return
        }
        // error message for no value in amount
        if Int(self.billAmount.text!) == nil
        {
             self.enterBillAmount.text = "Please enter valid amount"
            return
        }
        // selected acc
        oneAcc = String(accNumber.currentTitle!.dropLast(4))

        // selected acc module settings
        module = accNumber.currentTitle!.components(separatedBy: CharacterSet.decimalDigits).joined()
        module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
        module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
        // section code settings
        sectionCode = selectSection.currentTitle!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
//        performSegue(withIdentifier: "confirmation", sender: self)
        
        ksebConfirmation()
        
    }
    
    func ksebConfirmation() {
        let customKAlert = self.storyboard?.instantiateViewController(withIdentifier: "KConfirmationAlert") as! ksebConfirmationAlertViewController
        customKAlert.providesPresentationContextTransitionStyle = true
        customKAlert.definesPresentationContext = true
        customKAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customKAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customKAlert.delegate = self
        let fromAcc = accNumber.currentTitle!
        customKAlert.fromAccLtxt = fromAcc
        customKAlert.fromAccBranchLtxt = fromAccBranchLtxt
        customKAlert.conNameLtxt = consumerName.text!
        customKAlert.conMobLtxt = mobNumber.text!
        customKAlert.conDetailLtxt = "Consumer No : \(consumerNumber.text!) \nConsumer Section : \(selectSection.currentTitle!) \nBill No : \(billNum.text!)"
        customKAlert.conAmountLtxt = Double(billAmount.text!)!.currencyIN
        customKAlert.conAmountDetailsLtxt = Double(billAmount.text!)!.InWords
        self.present(customKAlert, animated: true, completion: nil)
    }
    
    
    //FIXME: ========= Recharge_KSEB_Bill() ==========
    func Recharge_KSEB_Bill() {
        // network reachability checking
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
       
        
        let consumerName = (self.consumerName.text ?? "").trimmingCharacters(in: .whitespaces)
        let mobile = (self.mobNumber.text ?? "").trimmingCharacters(in: .whitespaces)
        let consumerNumber = (self.consumerNumber.text ?? "").trimmingCharacters(in: .whitespaces)
        let billNum = (self.billNum.text ?? "").trimmingCharacters(in: .whitespaces)
        let billAmount = (self.billAmount.text ?? "").trimmingCharacters(in: .whitespaces)
        let accNumber = (self.accNumber.currentTitle ?? "").trimmingCharacters(in: .whitespaces)
        
       
        
        let argruMents = ["ConsumerName":"\(consumerName)",
                          "MobileNo":"\(mobile)",
                          "ConsumerNo":"\(consumerNumber)",
                          "SectionList":"\(sectionCode)",
                          "BillNo":"\(billNum)",
                          "amount":"\(billAmount)",
                          "AccountNo":"\(accNumber)",
                          "Module":"\(module)",
                          "Pin":"\(pin)",
                          "imei":"",
                          "token":"\(TokenNo)",
                          "BankKey":BankKey,
                          "BankHeader":BankHeader,
                          "BankVerified":""
        ]
        let urlPath = "/Recharge/KSEBPaymentRequest"
        
        parserViewModel.apiParser(urlPath: urlPath, arguments: argruMents) { getResult in
            
            switch getResult{
                
            case.success(let datas):
                print(datas)
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    
                    //API RESPONSE FETCH FROM VIEWMODEL
                    let response = self.parserViewModel.resultHandler(datas: datas,modelKey:"")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    
                    
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg,showFailure: .show,vc:self) { status in
                          
                        switch status{
                        case true:
                            print("success case")
                        case false:
                            print("failed case")
                        }
                        
                    }
                    
                }
            case.failure(let errResponse):
                
                self.parserViewModel.parserErrorHandler(errResponse, vc: self)
                
            
            }
            
            self.removeIndicator(showMessagge: false, message: "",activityView: self.activityIndicator, blurview: self.blurView)
        }
        
        
    }
    
    func RechargeKSEB(_ consName: String, _ mobNumb: String, _ consNumb : String, _ billNumb: String, _ billAmount : String, _ account: String ) {
        blurView.isHidden = false
        activityIndicator.startAnimating()
        // encrypting all datas
        let encryptedConsName   = instanceOfEncryption.encryptUseDES(consName, key: "Agentscr") as String
        let encryptedMobileNum  = instanceOfEncryption.encryptUseDES(mobNumb, key: "Agentscr") as String
        let encryptedConsNum    = instanceOfEncryption.encryptUseDES(consNumb, key: "Agentscr") as String
        let encryptedSection    = instanceOfEncryption.encryptUseDES(sectionCode, key: "Agentscr") as String
        let encryptedBillNum    = instanceOfEncryption.encryptUseDES(billNumb, key: "Agentscr") as String
        let encryptedBillAmount = instanceOfEncryption.encryptUseDES(billAmount, key: "Agentscr") as String
        let encryptedAcc        = instanceOfEncryption.encryptUseDES(account, key: "Agentscr") as String
        let encryptedModule     = instanceOfEncryption.encryptUseDES(module, key: "Agentscr") as    String
        let encryptedPin        = instanceOfEncryption.encryptUseDES(pin, key: "Agentscr") as String
        //// url settings
        let url = URL(string: BankIP + APIBaseUrlPart + "/KSEBPaymentRequest?ConsumerName=\(encryptedConsName)&MobileNo=\(encryptedMobileNum)&ConsumerNo=\(encryptedConsNum)&SectionList=\(encryptedSection)&BillNo=\(encryptedBillNum)&Amount=\(encryptedBillAmount)&AccountNo=\(encryptedAcc)&Module=\(encryptedModule)&Pin=\(encryptedPin)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url!) { data,response,error in
            if error != nil
            {
                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                
//                self.activityIndicator.stopAnimating()
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
                        let datas           = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        let StatusCode      = datas.value(forKey: "StatusCode") as! Int
                        let RefID           = datas.value(forKey: "RefID") as! Int
//                        let Amount          = datas.value(forKey: "Amount") as AnyObject
                        let StatusMessage   = datas.value(forKey: "StatusMessage") as! String
                        let CDate           = Date().currentDate(format: "dd-MM-yyyy")
                        let CTime           = Date().currentDate(format: "h:mm a")
                        
                        if StatusCode > 0
                        {
                            DispatchQueue.main.async { [weak self] in
                                self?.blurView.isHidden     = true
                                self?.activityIndicator.stopAnimating()
                                self?.RechargeKSEBSuccess(StatusMessage,String(RefID) ,CDate, CTime)


                            }
                        }
                        else if StatusCode < 0
                        {
                            DispatchQueue.main.async { [weak self] in
                                if StatusCode == -72
                                {

                                    self?.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)

                                }
                                else if StatusCode == -55
                                {
                                    self?.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)

                                }
                                else
                                {
                                    self?.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)

                                }
                                self?.blurView.isHidden     = true
                                self?.activityIndicator.stopAnimating()
                            }
                        }
                        else{
                            self.present(messages.errorMsgWithAppIcon(StatusMessage,UIImage(named: "AppIcon")!), animated: true,completion: nil)

                        }
                    }
                    catch{
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
    
    
    func RechargeKSEBSuccess(_ RTitle : String,_ RefTitle : String, _ RDate : String, _ RTime : String) {
        let customRKSAlert = self.storyboard?.instantiateViewController(withIdentifier: "rechargeksebSuccessAlert") as! ksebSuccessAlertViewController
        customRKSAlert.providesPresentationContextTransitionStyle = true
        customRKSAlert.definesPresentationContext = true
        customRKSAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customRKSAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customRKSAlert.delegate = self
        customRKSAlert.sucHdrLtxt = RTitle
        customRKSAlert.kRechDateLtxt = "Date : \(RDate)"
        customRKSAlert.kRechTimeLtxt = "Time : \(RTime)"
        customRKSAlert.kRechReffeLtxt = "Ref.No : \(RefTitle)"
        let fromAcc = accNumber.currentTitle!
        customRKSAlert.fromAccLtxt = fromAcc
        customRKSAlert.fromAccBranchLtxt = fromAccBranchLtxt
        customRKSAlert.kRechmobLtxt = mobNumber.text!
        customRKSAlert.kRechNamLtxt = consumerName.text!
        customRKSAlert.kRechDetaLtxt = "Consumer No : \(consumerNumber.text!) \nConsumer Section : \(selectSection.currentTitle!) \nBill No : \(billNum.text!)"
        customRKSAlert.kRechAmountLtxt = Double(billAmount.text!)!.currencyIN
        customRKSAlert.kRechAmountDetailsLtxt = Double(billAmount.text!)!.InWords
        self.present(customRKSAlert, animated: true, completion: nil)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        // from home screen to accInfo screen
//        if segue.identifier == "confirmation"
//        {
//            let vw = segue.destination as! KsebConfirmationViewController
//                vw.consName    = consumerName.text!
//                vw.mobNumb     = mobNumber.text!
//                vw.consNumb    = consumerNumber.text!
//                vw.sect        = selectSection.currentTitle!
//                vw.billNumb    = billNum.text!
//                vw.billAmount  = billAmount.text!
//                vw.accNumb     = accNumber.currentTitle!
//                vw.module      = module
//                vw.sectionCode = sectionCode
//                vw.TokenNo     = TokenNo
//                vw.pin         = pin
//        }
//    }
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(greenColour,2.0)
        self.keyboardWillShow()
        if textField.isEqual(consumerNumber) || textField.isEqual(billNum) || textField.isEqual(billAmount)
        {
            moveTextField(textField, moveDistance: -150, up: true)
        }

    }
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(UIColor.lightGray,1.0)
        if textField.isEqual(consumerNumber) || textField.isEqual(billNum) || textField.isEqual(billAmount)
        {
            moveTextField(textField, moveDistance: -150, up: false)
        }
    }
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if consumerName.isFirstResponder{
            mobNumber.becomeFirstResponder()
        }
        else if billNum.isFirstResponder {
            billAmount.becomeFirstResponder()
        }
        return true
    }
    
    var amountInWordsTxt = String()
    var payAmount = String()
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.isEqual(billAmount)
        {
            let amn = billAmount.text!
            if amn.count != 0 && amn.count < 7 {
                amountInWordsTxt = Double(String(amn))!.InWords
                payAmount = (Double(amn)!.currencyIN)
                amountInWords.text = amountInWordsTxt
                payBtn.setTitle("PAY \(payAmount)", for: .normal)
            }
            else if amn.count > 6 {
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

    // text field count settings
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount)
        {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        var maxLength = 0
        
        if textField.isEqual(mobNumber)
        {
            maxLength = 10
        }
        else if textField.isEqual(consumerNumber)
        {
            maxLength = 20
        }
        else if textField.isEqual(billNum)
        {
            maxLength = 20
        }
        else if textField.isEqual(billAmount)
        {
            maxLength = 6
        }
        else if textField.isEqual(consumerName)
        {
            maxLength = 50
        }

        return newLength <= maxLength
    }
}


extension KSEBViewController : ksebConfSuccessAlertDelegate {
    
    func ShareScreenShot(_ img: UIImage, _ Share : UIButton) {
        self.ShareImg = img
        self.ShareB = Share
    }
    
    func okButtonTapped() {
        print("OK")
        //self.RechargeKSEB(self.consumerName.text!, self.mobNumber.text!, self.consumerNumber.text!, self.billNum.text!, billAmount.text!, self.accNumber.currentTitle!)
        self.Recharge_KSEB_Bill()
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
