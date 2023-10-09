//
//  KsebBillStatusViewController.swift
//  mScoreNew
//
//  Created by Perfect on 04/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class KsebBillStatusViewController: NetworkManagerVC,UITextFieldDelegate
{
    @IBOutlet weak var statusNumber: UITextField!
    
    var customerId  = ""
    var TokenNo     = ""
    var pin         = ""
    var instanceOfEncryption: Encryption = Encryption()
    private let parserViewModel  : ParserViewModel = ParserViewModel()
    let group = DispatchGroup()
    
    var statusNumberCheck:Bool{
        return !statusNumber.text!.isEmpty && statusNumber.text!.range(of: "[^a-zA-Z0-9]", options: String.CompareOptions.regularExpression) == nil
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // keyboard hiding in the case of touch the screen
        self.hideKeyboardWhenTappedAround()
        // udid generation
        
        UDID = udidGeneration.udidGen()

    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    // FIXME: - ==== CHECK TRANSACTION VALID() ====
    fileprivate func checkTransactionIDValid(){
        
        if statusNumberCheck == true{
            
        }else{
            
        
            self.parserViewModel.mainThreadCall {
                self.present(messages.msg("Enter Valid Transaction ID"), animated: true, completion: nil)
                
            }
        }
        
    }
    
    // FIXME: == STATUSCHEKAPI() ===
    fileprivate func statusCheckApi(){
        
        if Reachability.isConnectedToNetwork(){
            
            parserViewModel.mainThreadCall {
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
                
            }
            
            return
        }
        
        
        
        let urlPath = "/Recharge/KSEBTransactionResponse"
        
        let transactionId = self.statusNumber.text ?? "0000"
        let arguMents = ["TransactioID":transactionId,
                         "Pin":pin,
                         "imei":"",
                         "Token":TokenNo,
                         "BankKey":BankKey,
                         "BankHeader":BankHeader,
                         "BankVerifier":""]
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey:"KSEBResponse")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        
                        
                        
                    }
                    
                    self.group.leave()
                }
            case.failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
                self.group.leave()
            }
            
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.group.wait()
            
            DispatchQueue.main.async {
                print("successfully reached destination")
            }
        }
    }
   
    @IBAction func checkStatus(_ sender: UIButton)
    {
        
        self.statusNumber.text?.count == 0 ?  parserViewModel.mainThreadCall {
            self.present(messages.msg("Transaction ID cannot be blank"), animated: true, completion: nil)
            
        }   : statusCheckApi()
        
        
        // network reachability checking
        
        
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//            }
//            return
//        }
//        
//        let encryptedPin = instanceOfEncryption.encryptUseDES(pin, key: "Agentscr") as String
//        let encryptedTransactionId = instanceOfEncryption.encryptUseDES(statusNumber.text, key: "Agentscr") as String
//        let url = URL(string: BankIP + APIBaseUrlPart + "/KSEBTransactionResponse?TransactioID=\(encryptedTransactionId)&Pin=\(encryptedPin)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)")
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//        let task = session.dataTask(with: url!) { data,response,error in
//            if error != nil
//            {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                }
////                self.activityIndicator.stopAnimating()
////                self.blurView.isHidden = true
//                return
//            }
//            let dataInString = String(data: data!, encoding: String.Encoding.utf8)
//            if dataInString == "1"
//            {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(messages.msg("Your bill payment was successfull"), animated: true, completion: nil)
//                }
//            }
//            else if dataInString == "2"
//            {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(messages.msg("Your bill payment was failed"), animated: true, completion: nil)
//                }
//            }
//            else if dataInString == "3"
//            {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(messages.msg("Your bill payment is on pending"), animated: true, completion: nil)
//                }
//            }
//            else if dataInString == "4"
//            {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(messages.msg("Wrong transaction Id"), animated: true, completion: nil)
//                }
//            }
//            else if dataInString == "5"
//            {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(messages.msg("Due to some technical issues, your transaction was reversed. The amount will be reversed with in few hours"), animated: true, completion: nil)
//                }
//            }
//        }
//        task.resume()
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
        
        if textField.isEqual(statusNumber)
        {
            maxLength = 20
        }
        return newLength <= maxLength
    }
}
