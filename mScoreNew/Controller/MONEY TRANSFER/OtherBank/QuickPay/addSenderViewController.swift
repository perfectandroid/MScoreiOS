//
//  addSenderViewController.swift
//  mScoreNew
//
//  Created by Perfect on 14/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class addSenderViewController: NetworkManagerVC,UITextFieldDelegate
{
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var dobSelection: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var instanceOfEncryption: Encryption = Encryption()
    let blurViews = UIView()
    
    // date fomate settings
    let date = Date()
    var dates = DateFormatter()
    
    // set var for get data in the time of segue
    var TokenNo = String()
    var customerId = String()
    var pin = String()
    var otpRefCode = String()
    var urlString = String()
    var senderId = String()
    var mobNumb = String()


    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        blurView.isHidden = true
        // keyboard hiding in the case of touch the screen.
        self.hideKeyboardWhenTappedAround()
        // udid generation
        UDID = udidGeneration.udidGen()
        // bottomBorder
        firstName.setBottomBorder(UIColor.lightGray,1.0)
        lastName.setBottomBorder(UIColor.lightGray,1.0)
        mobileNumber.setBottomBorder(UIColor.lightGray,1.0)
        // date in button settings
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            
            // Fallback on earlier versions
        }
        dobSelection.setTitle("01-01-1990", for: .normal)

        // max date in picker settings
        var components = DateComponents()
        components.year = 0
        components.day = 0
        components.month = 0
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        datePicker.maximumDate = maxDate
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
    @IBAction func dob(_ sender: UIButton)
    {
        activityIndicator.isHidden = true
        blurView.isHidden = false
        UIView.animate(withDuration: 0.6, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    @IBAction func cancel(_ sender: UIButton)
    {
        blurView.isHidden = true
    }
    @IBAction func done(_ sender: UIButton)
    {
        blurView.isHidden = true
        datePickerAction(datePicker)
    }
    
    //FIXME: - ADD_NEW_SENDER()
    func addNewSenderApiCall() {
       
        blurViews.frame = self.view.frame
        blurViews.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(blurViews)
        activityIndicator.center = self.view.center
        self.blurViews.addSubview(activityIndicator)
        
       
        self.displayIndicator(activityView: activityIndicator, blurview: blurViews)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurViews)
            return
        }
        
        
        let urlPath = APIBaseUrlPart1+"/AccountSummary/MTAddnewsender"
        
        let firstName = firstName.text ?? ""
        let lastName = lastName.text ?? ""
        let mobileNumber = mobileNumber.text ?? ""
        let dob = dobSelection.currentTitle
        let customerID = customerId
        
        let arguments = ["sender_fname":"\(firstName)","FK_Customer":"\(customerID)","sender_lname":"\(lastName)","sender_dob":"\(dob)","sender_mobile":"\(mobileNumber)","imei":"","token":"\(TokenNo)","BankKey":BankKey,"BankHeader":BankHeader,"BankVerified":""]
        
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            
            switch getResult{
            case.success(let datas):
                print(datas)
            case.failure(let errResponse):
               
                var msg = ""
                
                let response = self.apiErrorResponseResult(errResponse: errResponse)
                msg = response.1
                
                    
                DispatchQueue.main.async {
                    self.present(messages.msg(msg), animated: true, completion: nil)
                }
            }
            self.removeIndicator(showMessagge: false, message: "",activityView: self.activityIndicator, blurview: self.blurViews)
        }
        
    }
    @IBAction func register(_ sender: UIButton)
    {
        let firstname = firstName.text?.trimmingCharacters(in: .whitespaces)
        let lastname = lastName.text?.trimmingCharacters(in: .whitespaces)
        let mobilNumber = mobileNumber.text?.trimmingCharacters(in: .whitespaces)
        let dob = dobSelection.currentTitle
        let errorMessage =  firstname?.count == 0 ? "First name cannot be blank" : lastname?.count == 0 ? "Last name cannot be blank" : mobilNumber?.count != 10 ? "Enter valid mobile Number" : dob == "" ? "Select date of birth" : ""
        
        errorMessage == "" ?  addNewSenderApiCall() :  self.present(messages.msg(errorMessage), animated: true, completion: nil)
        
        
    }
    
    func oldAddnewSender(){
        blurView.isHidden = false
        activityIndicator.startAnimating()
        datePicker.isHidden = true
        doneButton.isHidden = true
        cancelButton.isHidden = true
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.activityIndicator.startAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        let encryptedFirstName = instanceOfEncryption.encryptUseDES(firstName.text, key: "Agentscr") as String
        let encryptedLastName  = instanceOfEncryption.encryptUseDES(lastName.text, key: "Agentscr") as String
        let encryptedMobNumb   = instanceOfEncryption.encryptUseDES(mobileNumber.text, key: "Agentscr") as String
        let encryptedDob       = instanceOfEncryption.encryptUseDES(dobSelection.currentTitle, key: "Agentscr") as String
        let encryptedCusID     = instanceOfEncryption.encryptUseDES(customerId, key: "Agentscr") as String
        urlString              = BankIP + APIBaseUrlPart + "/MTAddnewsender?sender_fname=\(encryptedFirstName)&IDCustomer=\(encryptedCusID)&sender_lname=\(encryptedLastName)&sender_dob=\(encryptedDob)&sender_mobile=\(encryptedMobNumb)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)"
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
                    }
                }
                else
                {
                    do
                    {
                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        if data1.value(forKey: "StatusCode") as! Int == 200 && data1.value(forKey: "otpRefNo") as! String == "0"
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
                        else if data1.value(forKey: "StatusCode") as! Int == 200 && data1.value(forKey: "otpRefNo") as! String != "0"
                        {
                            DispatchQueue.main.async{
                                self.blurView.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.otpRefCode = data1.value(forKey: "otpRefNo") as! String
                                self.senderId = data1.value(forKey: "ID_Sender") as! String
                                self.performSegue(withIdentifier: "senderToOtp", sender: self)

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
        // from home screen to search screen
        if segue.identifier == "senderToOtp"
        {
            let vw = segue.destination as! PaymentOTPViewController
            vw.pin = pin
            vw.TokenNo = TokenNo

            vw.urlString = urlString
            vw.statusReff = otpRefCode
            vw.senderId = senderId
            vw.otpType = 2
            vw.mobNumb = mobileNumber.text!
        }
    }

    func datePickerAction(_ sender: UIDatePicker)
    {
        dates.dateFormat = "dd-MM-yyyy"
        dobSelection.setTitle(dates.string(from: sender.date), for: .normal)
    }
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(UIColor.darkGray,2.0)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.setBottomBorder(UIColor.lightGray,1.0)
    }
    
    // to next txtfld when the keyboard return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if firstName.isFirstResponder{
            lastName.becomeFirstResponder()
        }
        else if lastName.isFirstResponder {
            mobileNumber.becomeFirstResponder()
        }
        
        return true
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
        if textField.isEqual(firstName)
        {
            maxLength = 100
        }
        else if textField.isEqual(lastName)
        {
            maxLength = 100
        }
        else if textField.isEqual(mobileNumber)
        {
            maxLength = 10
        }

        return newLength <= maxLength
    }
}
