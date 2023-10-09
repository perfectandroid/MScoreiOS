//
//  ViewController.swift
//  mScoreNew
//
//  Created by Perfect on 16/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import JNKeychain

protocol SessionLogOutDelegate:AnyObject{
    func didLogOut(sessionOut:Bool)
    
}

class Login: UIViewController,URLSessionDelegate,UITextFieldDelegate
{
    
    @IBOutlet weak var setPhoneView: UIView!{
        didSet {
            setPhoneView.layer.cornerRadius = 5
            setPhoneView.clipsToBounds      = true
            setPhoneView.layer.borderColor  = UIColor.gray.cgColor
            setPhoneView.layer.borderWidth  = 1.0
        }
    }
    @IBOutlet weak var phoneNumView     : UIView!
    @IBOutlet weak var phoneNumber      : UITextField!
    @IBOutlet weak var activateButtonSettings: UIButton!{
        didSet{
            activateButtonSettings.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var sliderImage: UIImageView!
    let sliderImages = [UIImage(named: "loginbg1.png")!,
                        UIImage(named: "loginbg2.png")!,
                        UIImage(named: "loginbg3.png")!]
    @IBOutlet weak var pageControl: UIPageControl!{
        didSet{
            pageControl.isEnabled = false
            pageControl.currentPage = 0
            pageControl.numberOfPages = self.sliderImages.count
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blurView         : UIView!
    @IBOutlet weak var pinView          : UIView!
    @IBOutlet weak var imgView          : UIView!
    @IBOutlet weak var firstImg         : UIImageView!
    @IBOutlet weak var secondImg        : UIImageView!
    @IBOutlet weak var thirdImg         : UIImageView!
    @IBOutlet weak var fourthImg        : UIImageView!
    @IBOutlet weak var fifthImg         : UIImageView!
    @IBOutlet weak var sixthImg         : UIImageView!
    @IBOutlet weak var welcomeLabel : UILabel!
    @IBOutlet weak var pinNumView   : UIView!{
        didSet{
            pinNumView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var one          : UIButton!
    @IBOutlet weak var two          : UIButton!
    @IBOutlet weak var three        : UIButton!
    @IBOutlet weak var four         : UIButton!
    @IBOutlet weak var five         : UIButton!
    @IBOutlet weak var six          : UIButton!
    @IBOutlet weak var seven        : UIButton!
    @IBOutlet weak var eight        : UIButton!
    @IBOutlet weak var nine         : UIButton!
    @IBOutlet weak var zero         : UIButton!
    @IBOutlet weak var clear        : UIButton!
    @IBOutlet weak var delete       : UIButton!
    @IBOutlet weak var bankName       : UILabel!{
        didSet{
            bankName.text = appName
        }
    }
    @IBOutlet weak var bankNamePinView: UILabel!
    @IBOutlet weak var imgPinView     : UIImageView!{
        didSet{
            SetImage(ImageCode: AppIconImageCode, ImageView: imgPinView, Delegate: self)
        }
    }
    @IBOutlet weak var imgLogView     : UIImageView!{
        didSet{
            SetImage(ImageCode: AppIconImageCode, ImageView: imgLogView, Delegate: self)
        }
    }
    // instance of encryption settings
    var instanceOfEncryption: Encryption = Encryption()
    // variables settings
//    var entryPin,pin,encryptedPhoneNumber : String
    var encryptedPhoneNumber = ""
    var entryPin             = String()
    var pin                  = String()
    var pinCount             = 0
    var cusData              = [Customerdetails]()
    var fromChangePin        = Bool()
    var i                    = Int()
    
    
    var sessionOut = false{
        
        didSet{
            switch sessionOut{
            case true :
                print("session expired")
                
                DispatchQueue.main.async {
                    self.present(messages.msg(sessionExpiredMsg), animated: true) {
                       
                        self.clearWhenSessionExpired()
                        
                    }
                }
                
            case false :
                print("session not expired")
            }
        }
    }
    
   
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
    //// Do any additional setup after loading the view.
        // fetchig the pin if already logged in
        do
        {
            cusData = try coredatafunction.fetchObjectofCus()
            if cusData == []
            {
                // hiding and non hiding views are setted
                pinView.isHidden                = true
                phoneNumView.isHidden           = false
                blurView.isHidden               = true
                //  phone number count is setting
                phoneNumber.delegate            = self
                // keyboard hiding in the case of touch the screen
                self.hideKeyboardWhenTappedAround()
                // udid generation
                UDID = udidGeneration.udidGen()
            }
            else
            {
                bankNamePinView.text            = appName
//                imgPinView.image                = #imageLiteral(resourceName: "logo")
                // hiding and non hiding views are setted
                pinView.isHidden                = false
                phoneNumView.isHidden           = true
                blurView.isHidden               = true
                for oneFetchedDmenu in cusData
                {
                    entryPin = oneFetchedDmenu.value(forKey: "pin") as! String
                    var wish = "Night"
                    // let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate()) Swift 2 legacy
                    let hour = Calendar.current.component(.hour, from: Date())

                    switch hour {
                        case 6..<12 : wish = "Good Morning"
                        case 12 : wish = "Good Noon"
                        case 13..<17 : wish = "Good Afternoon"
                        case 17..<22 : wish = "Good Evening"
                        default: wish = "Good Night"
                    }
                    welcomeLabel.text = wish + " \( (oneFetchedDmenu.value(forKey: "name") as? String)!) "
                }
            }            
        }
        catch{}
            Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(imageChange), userInfo: nil, repeats: true)
    }

    @objc func imageChange() {
        self.sliderImage.image = sliderImages[i]
        pageControl.currentPage = i
        if i<sliderImages.count-1 {
            i += 1
        }
        else {
            i = 0
        }
    }
    
    // phone number activation button settings
    @IBAction func activate(_ sender: UIButton)
    {
        // activity indicator and blur view viewing settings
        activityIndicator.startAnimating()
        blurView.isHidden = false

        // network reachability checking
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                
                // activity indicator and blur view viewing settings
                self?.activityIndicator.stopAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        
        // error message for no value & less than ten digit in phone number
        let phoneNum = phoneNumber.text
        if phoneNum?.count != 10 || Int(phoneNum!) == nil
        {
            // activity indicator and blur view viewing settings
            activityIndicator.stopAnimating()
            blurView.isHidden = true

            self.present(messages.msg(invalidMobNumMsg), animated: true, completion: nil)
            return
        }
        certificates    = [Data]()
        if TestingImageURL != "" && TestingURL != "" && TestingBankHeader != "" && TestingBankKey != "" && TestingMobileNo == phoneNum {
            ImageURL    = TestingImageURL
            BankIP      = TestingURL
//            certURL     = TestingCertUrl
            certificates    = {
                                let url = Bundle.main.url(forResource: TestingCertName, withExtension: "cer")
                                let data = try! Data(contentsOf: url!)
                                return [data]
                            }()
//            BankKey     = instanceOfEncryptionPost.encryptUseDES(TestingBankKey, key: "Agentscr")
//            BankHeader  = instanceOfEncryptionPost.encryptUseDES(TestingBankHeader, key: "Agentscr")
            
            BankKey = TestingBankKey
            BankHeader = TestingBankHeader
        }
        else {
            ImageURL        = OriginalImageURL
            BankIP          = OriginalBankIP
//            certURL         = OriginalCertUrl
            certificates    = {
                                let url = Bundle.main.url(forResource: OriginalCertName, withExtension: "cer")
                                let data = try! Data(contentsOf: url!)
                                return [data]
                            }()
//            BankKey         = instanceOfEncryptionPost.encryptUseDES(OriginalBankKey, key: "Agentscr")
//            BankHeader      = instanceOfEncryptionPost.encryptUseDES(OriginalBankHeader, key: "Agentscr")
            
            BankKey         = OriginalBankKey
            BankHeader      = OriginalBankHeader
        }

        // encrypt phone number
        //
        encryptedPhoneNumber = "91" + phoneNumber.text!
//        let bankVerified = (instanceOfEncryption.encryptUseDES("0", key: "Agentscr"))!
    //// url settings
        let url = URL(string: BankIP + APIBaseUrlPart1 + "/Customer/LoginVerification")
                      
                      
                      let parameter = [
                          
                          "MobileNo" : "\(encryptedPhoneNumber)",
                            "Pin":"0000",
                            "imei": "\(UDID)",
                            "BankKey": "\(BankKey)",
                          "BankHeader": "\(BankHeader)",
                            "BankVerified":"1"
                      
                      ]
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do{
            
            let parsedParam = try JSONSerialization.data(withJSONObject: parameter, options: [])
            request.httpBody = parsedParam
            
        }catch let error{
            
            print("json error - \(error.localizedDescription)")
            
        }
                      
                      
                      //?Mobno=\(encryptedPhoneNumber)&Pin=vHyQzFkgJvE%3D%0A&imei=\(UDID)&BankKey=\(BankKey)")!
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
        let task = session.dataTask(with: request)  { data,response,error in
            if let error = error
            {
                DispatchQueue.main.async { [weak self] in
                    self?.present(errorMessages.error(error as NSError), animated: true, completion: nil)
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                }
                return
            }
            
            do{
                
                print(" login page")
                
                let responseJSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary ?? [:]
                print(responseJSON)
                
                if let statusCode = responseJSON.value(forKey: "StatusCode") as? NSNumber,
                   let message = responseJSON.value(forKey: "EXMessage") as? String
                {
                    if statusCode == 0{
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.performSegue(withIdentifier: "login", sender: self)
                            self?.phoneNumber.text = ""
                        }
                    }else{
                        
                        DispatchQueue.main.async {
                            self.present(messages.msg(message), animated: true, completion: nil)
                            self.activityIndicator.stopAnimating()
                            self.blurView.isHidden = true
                        }
                        
                    }
                }else{
                    DispatchQueue.main.async {
                        self.present(messages.msg(contactBankMsg), animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        self.blurView.isHidden = true
                    }
                }
                
                
            }
            catch let error{
                
                DispatchQueue.main.async {
                    print("jsonerror login page \(error.localizedDescription)")
                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                }
                
            }
//            let dataInString = String(data: data!, encoding: String.Encoding.utf8)
//            print(dataInString)
//            if dataInString == "true"
//            {
//
//            }
//            else
//            {
//                DispatchQueue.main.async { [weak self] in
//                    if phoneNum?.count == 10
//                    {
//
//                    }
//                }
//            }
        }
        task.resume()
    }
    
    // settings data to pass in the time of segue is setted here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from phone number screen to otp screen
        if segue.identifier == "login"
        {
            let vw = segue.destination as! OtpScreen
                vw.phoneNumberForOtp = encryptedPhoneNumber
                vw.udid = UDID
        }
    }
    // action for the number click
    @IBAction func numb(_ sender: UIButton)
    {
        // set pincount limit as 6
        if pinCount == 6 {
            return
        }
        // pin counting and append evry value to pin with limit of 6 digit
        pinCount = pinCount + 1
        pin.append(String(sender.tag))
        // image setting in the time of pin clicking
        if pinCount == 1
        {
            firstImg.image = #imageLiteral(resourceName: "PIN3")
        }
        if pinCount == 2
        {
            secondImg.image = #imageLiteral(resourceName: "PIN3")
        }
        if pinCount == 3
        {
            thirdImg.image = #imageLiteral(resourceName: "PIN3")
        }
        if pinCount == 4
        {
            fourthImg.image = #imageLiteral(resourceName: "PIN3")
        }
        if pinCount == 5
        {
            fifthImg.image = #imageLiteral(resourceName: "PIN3")
        }
        if pinCount == 6
        {
            sixthImg.image = #imageLiteral(resourceName: "PIN3")
            pinCases()

        }
    }
    // pin cases
    func pinCases()
    {
        // activity indicator and blur view viewing settings
        activityIndicator.startAnimating()
        blurView.isHidden = false

        // pin matched case
        if pin == entryPin
        {
            // all value setted to empty
            clearAll()
            // perform segue to home screen in the case of correct pin
            self.performSegue(withIdentifier: "correctPin", sender: self)
            self.activityIndicator.stopAnimating()
            self.blurView.isHidden = true
            UserDefaults.standard.removeObject(forKey: "LastLogin")
            UserDefaults.standard.set(Date().currentDate(format: "dd-MM-yyyy, h:mm a"), forKey: "LastLogin")

        }
        // pin not matching case
        else if pin != entryPin
        {
            // set alert message
            self.present(messages.msg(invalidPinMsg), animated: true, completion: nil)
            clearAll()
            activityIndicator.stopAnimating()
            blurView.isHidden = true

        }

    }
    // all value setted to empty
    @IBAction func clear(_ sender: UIButton)
    {
       clearAll()
    }
    // function for set all value as empty
    func clearAll()
    {
        pin             = ""
        pinCount        = 0
        firstImg.image  = #imageLiteral(resourceName: "PIN1")
        secondImg.image = #imageLiteral(resourceName: "PIN1")
        thirdImg.image  = #imageLiteral(resourceName: "PIN1")
        fourthImg.image = #imageLiteral(resourceName: "PIN1")
        fifthImg.image  = #imageLiteral(resourceName: "PIN1")
        sixthImg.image  = #imageLiteral(resourceName: "PIN1")
    }
    // action for delete button as removing one digit at a time
    @IBAction func deleteButton(_ sender: UIButton)
    {
        // in the case of pin count is zero the action return from here
        if  pinCount == 0 {
            return
        }
        // last one digit is clearing
        clearPin()
        // pincount is decreasing by one
        pinCount = pinCount - 1
        // image setting in the time of pin count decreasing
        if pinCount == 5
        {
            sixthImg.image = #imageLiteral(resourceName: "PIN1")
        }
        if pinCount == 4
        {
            fifthImg.image = #imageLiteral(resourceName: "PIN1")
        }
        if pinCount == 3
        {
            fourthImg.image = #imageLiteral(resourceName: "PIN1")
        }
        if pinCount == 2
        {
            thirdImg.image = #imageLiteral(resourceName: "PIN1")
        }
        if pinCount == 1
        {
            secondImg.image = #imageLiteral(resourceName: "PIN1")
        }
        if pinCount == 0
        {
            firstImg.image = #imageLiteral(resourceName: "PIN1")
        }
    }
    // function for removing last number from pin
    func clearPin()
    {
        if pin.count > 0
        {
            pin = String(pin.dropLast(1))
        }
    }
    // setting the number button constrains
    func buttonConstrain()
    {
        one.createRoundButton(buttonPositionX: Double(view.frame.width) / 4.5,
                              buttonPositionY: Double(view.frame.height) / 2.5,
                              buttonWidth: Double(view.frame.width) / 7,
                              buttonHeight: Double(view.frame.width) / 7)
        two.createRoundButton(buttonPositionX: Double(view.frame.width) / 2.3,
                              buttonPositionY: Double(view.frame.height) / 2.5,
                              buttonWidth: Double(view.frame.width) / 7,
                              buttonHeight: Double(view.frame.width) / 7)
        three.createRoundButton(buttonPositionX: Double(view.frame.width) / 1.55,
                                buttonPositionY: Double(view.frame.height) / 2.5,
                                buttonWidth: Double(view.frame.width) / 7,
                                buttonHeight: Double(view.frame.width) / 7)
        four.createRoundButton(buttonPositionX: Double(view.frame.width) / 4.5,
                               buttonPositionY: Double(view.frame.height) / 2,
                               buttonWidth: Double(view.frame.width) / 7,
                               buttonHeight: Double(view.frame.width) / 7)
        five.createRoundButton(buttonPositionX: Double(view.frame.width) / 2.3,
                               buttonPositionY: Double(view.frame.height) / 2,
                               buttonWidth: Double(view.frame.width) / 7,
                               buttonHeight: Double(view.frame.width) / 7)
        six.createRoundButton(buttonPositionX: Double(view.frame.width) / 1.55,
                              buttonPositionY: Double(view.frame.height) / 2,
                              buttonWidth: Double(view.frame.width) / 7,
                              buttonHeight: Double(view.frame.width) / 7)
        seven.createRoundButton(buttonPositionX: Double(view.frame.width) / 4.5,
                                buttonPositionY: Double(view.frame.height) / 1.65,
                                buttonWidth: Double(view.frame.width) / 7,
                                buttonHeight: Double(view.frame.width) / 7)
        eight.createRoundButton(buttonPositionX: Double(view.frame.width) / 2.3,
                                buttonPositionY: Double(view.frame.height) / 1.65,
                                buttonWidth: Double(view.frame.width) / 7,
                                buttonHeight: Double(view.frame.width) / 7)
        nine.createRoundButton(buttonPositionX: Double(view.frame.width) / 1.55,
                               buttonPositionY: Double(view.frame.height) / 1.65,
                               buttonWidth: Double(view.frame.width) / 7,
                               buttonHeight: Double(view.frame.width) / 7)
        clear.createRoundButton(buttonPositionX: Double(view.frame.width) / 4.5,
                                buttonPositionY: Double(view.frame.height) / 1.4,
                                buttonWidth: Double(view.frame.width) / 7,
                                buttonHeight: Double(view.frame.width) / 7)
        zero.createRoundButton(buttonPositionX: Double(view.frame.width) / 2.3,
                               buttonPositionY: Double(view.frame.height) / 1.4,
                               buttonWidth: Double(view.frame.width) / 7,
                               buttonHeight: Double(view.frame.width) / 7)
        delete.createRoundButton(buttonPositionX: Double(view.frame.width) / 1.55,
                                 buttonPositionY: Double(view.frame.height) / 1.4,
                                 buttonWidth: Double(view.frame.width) / 7,
                                 buttonHeight: Double(view.frame.width) / 7)
    }
    // unwind to login screen
    @IBAction func loginScreen(_ login:UIStoryboardSegue)
    {
        if fromChangePin == true
        {
            fromChangePin = false
            messages.msg("Pin change success").showMsg()
        }
        viewDidLoad()
    }
    @IBAction func share(_ sender: UIButton)
    {
        
        let firstActivityItem = "Click here to download \n"
        let secondActivityItem : NSURL = NSURL(string: appLink)!
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem,secondActivityItem], applicationActivities: nil)
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender)
        
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
    
    // Session Expired Case
    func clearWhenSessionExpired(){
        
        print("=== Move ==== To ======= Registration Page ======")
        
        DispatchQueue.main.async {
            coredatafunction.delete("Accountdetails")
            coredatafunction.delete("Customerdetails")
            coredatafunction.delete("Transactiondetails")
            coredatafunction.delete("Settings")
            coredatafunction.delete("Messages")
            coredatafunction.delete("CustomerPhoto")
            

            UserDefaults.standard.removeObject(forKey: "LastLogin")
            self.viewDidLoad()
        }
        
    }
    
    // action for log out button
    @IBAction func logout(_ sender: UIButton)
    {
        
        let quitopt = UIAlertController(title: "",
                                        message: "Do You Want To Delete This Account And Register With Another Account?",
                                        preferredStyle: UIAlertController.Style.alert)
        quitopt.addAction(UIAlertAction(title: "No",
                                        style: UIAlertAction.Style.default,
                                        handler: nil))
        quitopt.addAction(UIAlertAction(title: "Yes",
                                        style: UIAlertAction.Style.default,
                                        handler: { (action:UIAlertAction!) -> Void in
                                            //after user press ok, the following code will be execute
                                            // core data deleting
                                            coredatafunction.delete("Accountdetails")
                                            coredatafunction.delete("Customerdetails")
                                            coredatafunction.delete("Transactiondetails")
                                            coredatafunction.delete("Settings")
                                            coredatafunction.delete("Messages")
                                            coredatafunction.delete("CustomerPhoto")
                                            

                                            UserDefaults.standard.removeObject(forKey: "LastLogin")
                                            self.viewDidLoad()

        }))
        self.present(quitopt, animated: true, completion: nil)
    }
    
    
    
    @IBAction func QuitApp(_ sender: UIButton)
    {
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                               to: UIApplication.shared, for: nil)
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
        if textField.isEqual(phoneNumber)
        {
            maxLength = 10
        }
        return newLength <= maxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 150)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 150)
    }
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}

// extension for button for round the button
extension UIButton
{
    func createRoundButton(buttonPositionX: Double, buttonPositionY: Double ,buttonWidth: Double, buttonHeight: Double)
    {
        let Button                    = self
            Button.frame              = CGRect(x: buttonPositionX,
                                               y: buttonPositionY,
                                               width: buttonWidth,
                                               height: buttonHeight)
            Button.layer.cornerRadius = 0.5 * Button.bounds.size.width
            Button.layer.borderColor  = UIColor.black.cgColor
            Button.layer.borderWidth  = 1.0
            Button.clipsToBounds      = true
    }
}
