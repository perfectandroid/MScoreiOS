//
//  OTPScreen.swift
//  mScoreNew
//
//  Created by Perfect on 22/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class OtpScreen: UIViewController,URLSessionDelegate
{
    @IBOutlet weak var otp              : UITextField!{
        didSet{
            // text field bottomboarder
            otp.setBottomBorder(UIColor.white,2.0)
            // number typing in the otp text field is not shown
            otp.isSecureTextEntry = !otp.isSecureTextEntry
            //  otp number count is setting
            otp.delegate = self
        }
    }
    @IBOutlet weak var blurView         : UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activateButtonSet: UIButton!{
        didSet{
            activateButtonSet.layer.cornerRadius = 10
        }
    }
    // instance of encryption settings
    var instanceOfEncryption            : Encryption = Encryption()
    // variables for getting value from login screen in the time of segue
    var phoneNumberForOtp = ""
    var otpString         = ""
    var udid              = ""
    override func viewDidLoad()
    {
        super.viewDidLoad()
    //// Do any additional setup after loading the view.
        // keyboard hiding in the case of touch the screen.
        self.hideKeyboardWhenTappedAround()
        // view setting
        blurView.isHidden = true
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // action for oto verify button
    @IBAction func verifyOtp(_ sender: UIButton)
    {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        // error message for no value & less than 6 digit in otp number
        otpString = otp.text!
        if otpString.count != 6 || Int(otpString) == nil
        {
            self.present(messages.msg(invalidOtpMsg), animated: true, completion: nil)
            otp.text = ""
            return
        }
        // activity indicator and blur view viewing settings
        activityIndicator.startAnimating()
        blurView.isHidden = false
        // encrypt otp number
        let encryptedOtp = otpString as String
        let encryptedNoOfDays = "30" as String
        
        
    //// url settings
        
        
        let url = URL(string: BankIP + APIBaseUrlPart1 + "/Customer/VerifyOTP")
        
        let parameter = [
        
            "MobileNo" : "\(phoneNumberForOtp)",
               "OTPCode":"\(encryptedOtp)",
               "NoOfDays":"\(encryptedNoOfDays)",
               "Token" : "token",
               "imei": "123456",
               "BankKey": BankKey,
               "BankHeader": BankHeader
        
        ]
        
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
                   
                      
                      
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { data,response,error in
            if let error = error
            {
                
                DispatchQueue.main.async { [weak self] in
                    self?.present(errorMessages.error(error as NSError), animated: true, completion: nil)
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                }
                return
            }
            if let datas = data
            {
               
                    do
                    {
                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as? NSDictionary ?? [:]
                        print(data1)
                        let acInfos = data1.value(forKey: "acInfo") as? [NSDictionary] ?? []
                        print(acInfos)
                        
                        if let statusCode = data1.value(forKey: "StatusCode") as? NSNumber, let message = data1.value(forKey: "EXMessage") as? String{
                            
                            
                            if statusCode == 0{
                                
                                DispatchQueue.main.async {
                                    

                                    
                                    
                                    
                                    saveCoreData.data(acInfos, true)
                                    UserDefaults.standard.set(Date().currentDate(format: "dd-MM-yyyy, h:mm a"), forKey: "LastLogin")
                                    self.performSegue(withIdentifier: "mainVC", sender: self)
                                }
                                
                            }else{
                                
                                DispatchQueue.main.async { [weak self] in
                                  self?.present(messages.msg(message), animated: true, completion: nil)
                                   
                                }
                            }
                            
                            DispatchQueue.main.async {
                                
                                self.activityIndicator.stopAnimating()
                                self.blurView.isHidden = true
                                self.otp.text = ""
                                
                            }
                            
                            
                            
                        }else{
                            
                            DispatchQueue.main.async { [weak self] in
    //                            self?.present(messages.msg(invalidOtpMsg), animated: true, completion: nil)
                                self?.activityIndicator.stopAnimating()
                                self?.blurView.isHidden = true
                                self?.otp.text = ""
                            }
                            
                        }

                       
//                        self.activityIndicator.stopAnimating()
//                        self.blurView.isHidden = true
                    }
                    catch
                    {
                        DispatchQueue.main.async { [weak self] in
//                            self?.present(messages.msg(invalidOtpMsg), animated: true, completion: nil)
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.otp.text = ""
                        }
                    }
                // if end
            }
        }
        task.resume()
    }
    @IBAction func otpScreen(_ otp:UIStoryboardSegue)
    {
    }
}
extension OtpScreen: UITextFieldDelegate
{
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // limit to 6 characters
        let characterCountLimit = 6
        
        // We need to figure out how many characters would be in the string after the change happens
        let startingLength = textFieldToChange.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
    }
}

