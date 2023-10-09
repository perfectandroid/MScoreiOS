//
//  addReceiverViewController.swift
//  mScoreNew
//
//  Created by Perfect on 14/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import DropDown

class addReceiverViewController: UIViewController,URLSessionDelegate,UITextFieldDelegate
{
    
    @IBOutlet weak var senderList: UIButton!
    
    @IBOutlet weak var recName: UITextField!
    @IBOutlet weak var mobNumb: UITextField!
    @IBOutlet weak var ifsc: UITextField!
    @IBOutlet weak var accNumb: UITextField!
    @IBOutlet weak var confAccNumb: UITextField!
    
    @IBOutlet weak var selectSender: UILabel!
    @IBOutlet weak var enterName: UILabel!
    @IBOutlet weak var enterMobNumb: UILabel!
    @IBOutlet weak var enterIFSC: UILabel!
    @IBOutlet weak var enterAccNumb: UILabel!
    @IBOutlet weak var enterConfAccNumb: UILabel!
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var senderDrop = DropDown()
    lazy var senderDropDowns: [DropDown] = {
        return[
            self.senderDrop]
    } ()
    var senderlist = [senderreciverlistData]()

    var instanceOfEncryption: Encryption = Encryption()
    
    // set var for get data in the time of segue
    var TokenNo = String()
    var customerId = String()
    var pin = String()
    var sList = [String]()
    var urlString = String()
    var otpRefCode = String()
    var senderId = String()
    var receverId = String()

    override func viewDidLoad()
    {
        super.viewDidLoad()
    //// Do any additional setup after loading the view.
        // keyboard hiding in the case of touch the screen.
        self.hideKeyboardWhenTappedAround()
        // udid generation
        UDID = udidGeneration.udidGen()
        // bottomBorder
        recName.setBottomBorder(UIColor.lightGray,1.0)
        mobNumb.setBottomBorder(UIColor.lightGray,1.0)
        ifsc.setBottomBorder(UIColor.lightGray,1.0)
        accNumb.setBottomBorder(UIColor.lightGray,1.0)
        confAccNumb.setBottomBorder(UIColor.lightGray,1.0)

        // number typing in the text field is not shown
        accNumb.isSecureTextEntry = !accNumb.isSecureTextEntry

        senderDropDowns.forEach { $0.dismissMode = .onTap }
        senderDropDowns.forEach { $0.direction = .any }
        senderList.setTitle(sList[0], for: .normal)
        setSenderDropDown()
        
        blurView.isHidden = true
        
        nextButtonInClick.load().addTarget(self, action: #selector(self.mobilePadNextAction(_:)), for: UIControl.Event.touchUpInside)
    }
    
    func keyboardWillShow()
    {
        
        if mobNumb.isFirstResponder
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
        if mobNumb.isFirstResponder{
            ifsc.becomeFirstResponder()
        }
        
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSenderDropDown()
    {
        senderDrop.anchorView = senderList
        senderDrop.bottomOffset = CGPoint(x:0, y:40)
        senderDrop.dataSource = sList
        senderDrop.backgroundColor = UIColor.white
        senderDrop.selectionAction = {[weak self] (index, item) in
            self?.senderList.setTitle(item, for: .normal)
        }
    }
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func senderSelection(_ sender: UIButton)
    {
        senderDrop.show()
    }

    
    @IBAction func register(_ sender: UIButton)
    {
        blurView.isHidden = false
        activityIndicator.startAnimating()
            self.selectSender.text = ""
            self.enterName.text = ""
            self.enterMobNumb.text = ""
            self.enterIFSC.text = ""
            self.enterAccNumb.text = ""
            self.enterConfAccNumb.text = ""
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
        if senderList.currentTitle == "Select"
        {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()

            selectSender.text = "Please select sender"
            return
        }
        if recName.text == ""
        {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()

            enterName.text = "Please enter receiver name"
            return
        }
        if mobNumb.text == "" || mobNumb.text?.count != 10
        {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()

            enterMobNumb.text = "Please enter valid mobile number"
            return
        }
        if ifsc.text == "" || ifsc.text?.count != 11
        {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()

            enterIFSC.text = "Please enter IFSC number"
            return
        }
        if accNumb.text! == "" || (accNumb.text?.count)! < 5
        {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()

            enterAccNumb.text = "Please enter account number"
            return
        }
        if confAccNumb.text! == "" || (confAccNumb.text?.count)! < 5
        {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()

            enterAccNumb.text = "Please enter confirm account number"
            return
        }
        if accNumb.text != confAccNumb.text
        {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()

            enterConfAccNumb.text = "Account Number not matching"
            return
        }
        var senderid = String()
        if let range = self.senderList.currentTitle?.range(of: "\n")
        {
            senderid = (self.senderList.currentTitle?[range.upperBound...].trimmingCharacters(in: .whitespaces))!
        }
        let encryptedSenderID = instanceOfEncryption.encryptUseDES(senderid, key: "Agentscr") as String
        let encryptedRecName = instanceOfEncryption.encryptUseDES(recName.text, key: "Agentscr") as String
        let encryptedMobNumb = instanceOfEncryption.encryptUseDES(mobNumb.text, key: "Agentscr") as String
        let encryptedifsc = instanceOfEncryption.encryptUseDES(ifsc.text, key: "Agentscr") as String
        let encryptedAccNumb = instanceOfEncryption.encryptUseDES(accNumb.text, key: "Agentscr") as String
        let encryptedCusID = instanceOfEncryption.encryptUseDES(customerId, key: "Agentscr") as String
        urlString = BankIP + APIBaseUrlPart + "/MTAddnewreceiver?senderid=\(encryptedSenderID)&receiver_name=\(encryptedRecName)&IDCustomer=\(encryptedCusID)&receiver_mobile=\(encryptedMobNumb)&receiver_IFSCcode=\(encryptedifsc)&receiver_accountno=\(encryptedAccNumb)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)"

        let url = URL(string: urlString)
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
                if dataInString == "null"
                {
                    DispatchQueue.main.async{
                        self.blurView.isHidden = true
                        self.activityIndicator.stopAnimating()
                        print("error")
                        
                    }
                }
                else
                {
                    do
                    {
                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        if data1.value(forKey: "StatusCode") as! Int != 200
                        {
                            DispatchQueue.main.async{
                                self.blurView.isHidden = true
                                self.activityIndicator.stopAnimating()

                                self.present(messages.failureMsg(data1.value(forKey: "message") as! String), animated: true, completion: nil)
                            }

                        }
                        else
                        {
                            if data1.value(forKey: "otpRefNo") as! String == "0"
                            {
                                DispatchQueue.main.async{
                                    self.blurView.isHidden = true
                                    self.activityIndicator.stopAnimating()

                                    let successQuit = UIAlertController(title: "SUCCESS", message: (data1.value(forKey: "message") as! String), preferredStyle: UIAlertController.Style.alert)
                                    successQuit.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
                                        //after user press ok, the following code will be execute
                                        self.navigationController?.popViewController(animated: true)
                                    }))
                                    self.present(successQuit, animated: true, completion: nil)
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async{
                                    self.blurView.isHidden = true
                                    self.activityIndicator.stopAnimating()

                                    self.otpRefCode = data1.value(forKey: "otpRefNo") as! String
                                    self.senderId = data1.value(forKey: "ID_Sender") as! String
                                    self.receverId = data1.value(forKey: "ID_Receiver") as! String

                                    self.performSegue(withIdentifier: "receiverToOtp", sender: self)
                                }
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
        }
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from home screen to otp screen
        if segue.identifier == "receiverToOtp"
        {
            let vw = segue.destination as! PaymentOTPViewController
            vw.pin = pin
            vw.TokenNo = TokenNo

            vw.urlString = urlString
            vw.statusReff = otpRefCode
            vw.senderId = senderId
            vw.receverId = receverId
            vw.otpType = 3
        }
    }
    
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(UIColor.darkGray,2.0)
        moveTextField(textField, moveDistance: -125, up: true)
        self.keyboardWillShow()

    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(UIColor.lightGray,1.0)
        moveTextField(textField, moveDistance: -125, up: false)

    }
    // to next txtfld when the keyboard return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if recName.isFirstResponder{
            mobNumb.becomeFirstResponder()
        }
        else if ifsc.isFirstResponder {
            accNumb.becomeFirstResponder()
        }
        else if accNumb.isFirstResponder {
            confAccNumb.becomeFirstResponder()
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
        
        var maxLength = 0
        if textField.isEqual(mobNumb)
        {
            maxLength = 10
        }
        else if textField.isEqual(ifsc)
        {
            maxLength = 11
        }
        else if textField.isEqual(accNumb)
        {
            maxLength = 20
        }
        else if textField.isEqual(confAccNumb)
        {
            maxLength = 20
        }
        else if textField.isEqual(recName)
        {
            maxLength = 100
        }

        return newLength <= maxLength
    }

}
