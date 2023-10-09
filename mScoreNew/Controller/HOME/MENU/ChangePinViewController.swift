//
//  ChangePinViewController.swift
//  mScoreNew
//
//  Created by Perfect on 24/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class ChangePinViewController: UIViewController,UITextFieldDelegate,URLSessionDelegate
{
    @IBOutlet weak var pinChange            : UIView!
    @IBOutlet weak var oldPin               : UITextField!
    @IBOutlet weak var newPin               : UITextField!
    @IBOutlet weak var confirmPin           : UITextField!
    @IBOutlet weak var submit               : UIButton!
    
    @IBOutlet weak var validPin             : UILabel!
    @IBOutlet weak var newPinValue          : UILabel!
    @IBOutlet weak var confirmPinValue      : UILabel!
    
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    
    @IBOutlet weak var changePinView        : UIView!

    @IBOutlet weak var changePinConstraint  : NSLayoutConstraint!
    
    
    var customerId  = ""
    var TokenNo     = ""
    var pin         = ""
    
    lazy var oldPinButtion : UIButton = {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 75, height: 44)
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 10)
        
        btn.setImage(UIImage(named: "lock"), for: .normal)
        
        btn.addTarget(self, action: #selector(PinButtonAction), for: .touchDown)
        return btn
        
    }()
    
    lazy var confirmPinButtion : UIButton = {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 75, height: 44)
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 10)
        btn.setImage(UIImage(named: "lock"), for: .normal)
        
        btn.addTarget(self, action: #selector(confirmPinButtonAction), for: .touchDown)
        return btn
        
    }()
    
    lazy var newPinButtion : UIButton = {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 75, height: 44)
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 10)
        btn.setImage(UIImage(named: "lock"), for: .normal)
        
        btn.addTarget(self, action: #selector(newPinButtonAction), for: .touchDown)
        return btn
        
    }()
    
    // instance of encryption settings
    var instanceOfEncryption: Encryption = Encryption()
    
    
    let mobilePadNextButton = UIButton(type: UIButton.ButtonType.custom)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        pinChange.roundCorners(10,[.topRight,.topLeft])
        
        cardView(changePinView)

        // Do any additional setup after loading the view.
        oldPin.delegate              = self
        newPin.delegate              = self
        confirmPin.delegate          = self
        // number typing in the text field is not shown
        oldPin.isSecureTextEntry     = !oldPin.isSecureTextEntry
        newPin.isSecureTextEntry     = !newPin.isSecureTextEntry
        confirmPin.isSecureTextEntry = !confirmPin.isSecureTextEntry
        // keyboard hiding in the case of touch the screen
        self.hideKeyboardWhenTappedAround()
        // udid generation
        UDID = udidGeneration.udidGen()
        //
        blurView.isHidden = true
        
        mobilePadNextButton.setTitle("Next", for: UIControl.State())//Set Done here
        mobilePadNextButton.setTitleColor(UIColor.black, for: UIControl.State())
        mobilePadNextButton.frame = CGRect(x: 0, y: 163, width: 106, height: 53)
        mobilePadNextButton.adjustsImageWhenHighlighted = false
        mobilePadNextButton.addTarget(self, action: #selector(self.mobilePadNextAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        self.setRightView(button: oldPinButtion, textField: self.oldPin)
        self.setRightView(button: newPinButtion, textField: self.newPin)
        self.setRightView(button: confirmPinButtion, textField: self.confirmPin)
    }
    
    func setRightView(button:UIButton,textField:UITextField) {
        
        
        textField.rightViewMode = .always
        textField.rightView = button
        
    }
    
    @objc func PinButtonAction(sender:UIButton){
        self.oldPin.isSecureTextEntry = !self.oldPin.isSecureTextEntry
        oldPinButtion.setImage(UIImage(named: self.oldPin.isSecureTextEntry == true ? "lock" : "unlock"), for: .normal)
        
    }
    @objc func confirmPinButtonAction(sender:UIButton){
        self.confirmPin.isSecureTextEntry = !self.confirmPin.isSecureTextEntry
        confirmPinButtion.setImage(UIImage(named: self.confirmPin.isSecureTextEntry == true ? "lock" : "unlock"), for: .normal)
        
    }
    @objc func newPinButtonAction(sender:UIButton){
        self.newPin.isSecureTextEntry = !self.newPin.isSecureTextEntry
        newPinButtion.setImage(UIImage(named: self.newPin.isSecureTextEntry == true ? "lock" : "unlock"), for: .normal)
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.keyboardWillShow()
    }
    func keyboardWillShow()
    {

        if oldPin.isFirstResponder
        {
            DispatchQueue.main.async { () -> Void in
                self.mobilePadNextButton.isHidden = false
                let keyBoardWindow = UIApplication.shared.windows.last
                self.mobilePadNextButton.frame = CGRect(x: 0, y: (keyBoardWindow?.frame.size.height)!-53, width: 106, height: 53)
                keyBoardWindow?.addSubview(self.mobilePadNextButton)
                keyBoardWindow?.bringSubviewToFront(self.mobilePadNextButton)

            }
        }
        else if newPin.isFirstResponder
        {
            DispatchQueue.main.async { () -> Void in
                self.mobilePadNextButton.isHidden = false
                let keyBoardWindow = UIApplication.shared.windows.last
                self.mobilePadNextButton.frame = CGRect(x: 0, y: (keyBoardWindow?.frame.size.height)!-53, width: 106, height: 53)
                keyBoardWindow?.addSubview(self.mobilePadNextButton)
                keyBoardWindow?.bringSubviewToFront(self.mobilePadNextButton)
            }
        }

        else
        {
            self.mobilePadNextButton.isHidden = true
        }

    }
    @objc func mobilePadNextAction(_ sender : UIButton){

        //Click action
        if oldPin.isFirstResponder{
            newPin.becomeFirstResponder()
        }
        else if newPin.isFirstResponder{
            confirmPin.becomeFirstResponder()
        }

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
       
        if textField.isEqual(oldPin) || textField.isEqual(newPin) || textField.isEqual(confirmPin)
        {
            maxLength = 6
        }
        return newLength <= maxLength
    }
    @IBAction func Back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func submit(_ sender: UIButton)
    {
        validPin.text              = ""
        newPinValue.text           = ""
        confirmPinValue.text       = ""
        blurView.isHidden          = false
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
        if oldPin.text?.count != 6 || oldPin.text! != pin
        {
            blurView.isHidden           = true
            activityIndicator.stopAnimating()
            validPin.text               = "Please enter your valid Pin No."
            return
        }
        else if oldPin.text! == newPin.text
        {
            blurView.isHidden          = true
            activityIndicator.stopAnimating()
            newPin.text                = ""
            confirmPin.text            = ""
            newPinValue.text           = "Please enter different new pin No."
            return

        }
        else if newPin.text?.count != 6
        {
            blurView.isHidden          = true
            activityIndicator.stopAnimating()
            newPinValue.text           = "Please enter new Pin No."
            return
        }
        else if confirmPin.text?.count != 6 || confirmPin.text != newPin.text
        {
            blurView.isHidden          = true
            activityIndicator.stopAnimating()
            confirmPinValue.text       = "New Pin No and confirm pin No does not match"
            return
        }
        let encryptedCusId = customerId
                                                               
        let encryptedOldPin = oldPin.text!
                                                                
        let encryptedNewPin = newPin.text!
                                                                 
    //// url settings
//        let url = URL(string: BankIP + APIBaseUrlPart + "/ChangeMpin?IDCustomer=\(encryptedCusId)&oldPin=\(encryptedOldPin)&newPin=\(encryptedNewPin)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
        
        let url = URL(string: BankIP + APIBaseUrlPart1 + "/Customer/ChangeMpin")
                      let parameter = ["FK_Customer":"\(encryptedCusId)",
                                   "oldPin":"\(encryptedOldPin)",
                                   "newPin":"\(encryptedNewPin)",
                                   "imei": "\(UDID)",
                                   "token": "\(TokenNo)",
                                   "BankKey": "\(BankKey)",
                                   "BankHeader": "\(BankHeader)",
                                   "BankVerified":""]
        
        print("{\(parameter)}")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do{
            
            let parsedParam = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            request.httpBody = parsedParam
            
        }catch let error{
            
            print("json error - \(error.localizedDescription)")
            
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { data,response,error in
            if error != nil
            {
                DispatchQueue.main.async {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                }
                return
            }
            
            do{
                let datas = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary ?? [:]
                print(datas)
                let changePin = datas.value(forKey: "ChangeMPinStatus") as? Bool ?? false
                if changePin == true{
                    
                    DispatchQueue.main.async {
                        self.present(messages.msg("Pin Changed Successfully."), animated: true) {
                            coredatafunction.newPin((self.newPin.text)!)
                            self.performSegue(withIdentifier: "pinChangeToLogin", sender: self)
                        }
                        
                        self.blurView.isHidden = true
                        self.activityIndicator.stopAnimating()
                         }
                    
                }else{
                    DispatchQueue.main.async {
                            self.present(messages.msg("Not able to change pin."), animated: true, completion: nil)
                            self.blurView.isHidden = true
                            self.oldPin.text = ""
                            self.newPin.text = ""
                            self.confirmPin.text = ""
                            self.activityIndicator.stopAnimating()
                    }
                }
                
                
            }catch{
                DispatchQueue.main.async {
                                    self.present(messages.msg("Not able to change pin."), animated: true, completion: nil)
                                    self.blurView.isHidden = true
                                   self.oldPin.text = ""
                                    self.newPin.text = ""
                                   self.confirmPin.text = ""
                                    self.activityIndicator.stopAnimating()
                    }
            }
//            let dataInString = String(data: data!, encoding: String.Encoding.utf8)
//            if dataInString == "true"
//            {
//                DispatchQueue.main.async { [weak self] in
//                    coredatafunction.newPin((self?.newPin.text)!)
//                    self?.performSegue(withIdentifier: "pinChangeToLogin", sender: self)
//                }
//            }
//            else if dataInString == "false"
//            {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(messages.msg("Not able to change pin."), animated: true, completion: nil)
//                    self?.blurView.isHidden = true
//                    self?.activityIndicator.stopAnimating()
//                }
//            }
        }
        task.resume()
    }
    // settings data to pass in the time of segue is setted here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from phone number screen to otp screen
        if segue.identifier == "pinChangeToLogin"
        {
            let vw = segue.destination as! Login
            vw.fromChangePin = true
        }
    }


}
