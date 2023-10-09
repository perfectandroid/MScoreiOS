//
//  ContactUsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 31/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController,URLSessionDelegate {

    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var branchName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var mobNumber: UILabel!
    @IBOutlet weak var landPhoneNumber: UILabel!
    @IBOutlet weak var workingHour: UILabel!
    @IBOutlet weak var blurView: UIView!{
        didSet{
            blurView.isHidden = false
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{
        didSet{
            activityIndicator.startAnimating()
        }
    }
    @IBOutlet weak var navItem: UINavigationItem!{
        didSet{
            navItem.title = "Contact Us"
        }
    }
    var TokenNo         = String()
    var custoID         = Int()
    var fetchedCusDetails       : [Customerdetails] = []
    var instanceOfPostEncryption: EncryptionPost    = EncryptionPost()

    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                custoID       = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
                TokenNo     = (fetchedCusDetail.value(forKey: "tokenNum") as? String)!
            }
        }
        catch
        {
        }
        contactDetails()
    }
    

    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }

    func contactDetails()
    {
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
        let url = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/CustomerBankDetails")!
        
//        let encryptedCusID      = instanceOfPostEncryption.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedToken      = instanceOfPostEncryption.encryptUseDES(TokenNo, key: "Agentscr")
        
//        "ReqMode":instanceOfPostEncryption.encryptUseDES("1", key: "Agentscr"),
//        "SubMode":instanceOfPostEncryption.encryptUseDES("1", key: "Agentscr"),
        
        let encryptedCusID      = String(custoID)
        let encryptedToken      = TokenNo
        let jsonDict            = ["ReqMode":"1",
                                   "SubMode":"1",
                                   "Token":encryptedToken,
                                   "FK_Customer":encryptedCusID,
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]

        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
        request.httpMethod  = "post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let BankBranchDetailsInfo  = responseJSONData.value(forKey: "BankBranchDetailsListInfo") as! NSDictionary
                        
                        DispatchQueue.main.async { [weak self] in
                            
                            self!.bankName.text = (BankBranchDetailsInfo.value(forKey: "BankName") as! String)
                            self!.branchName.text = (BankBranchDetailsInfo.value(forKey: "BranchName") as! String)
                            self!.address.text = BankBranchDetailsInfo.value(forKey: "Address") as? String ?? "null" + ", \n\( BankBranchDetailsInfo.value(forKey: "Place") as? String ?? "null"), \n\( BankBranchDetailsInfo.value(forKey: "Post") as? String ?? "null"), \n\( BankBranchDetailsInfo.value(forKey: "District") as? String ?? "null")"
                            
                            self!.mobNumber.text = BankBranchDetailsInfo.value(forKey: "ContactPersonMobile") as? String ?? "null" + ", \( BankBranchDetailsInfo.value(forKey: "BranchMobileNumber") as? String ?? "null")"
                            
                            self!.landPhoneNumber.text = (BankBranchDetailsInfo.value(forKey: "LandPhoneNumber") as? String ?? "null")
                            

                            self!.workingHour.text = BankBranchDetailsInfo.value(forKey: "OpeningTime") as? String  ?? "10:00 AM" + " to \( BankBranchDetailsInfo.value(forKey: "ClosingTime") as? String ?? "4:00 PM")"
                            
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            
                        }
                    }
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.present(messages.msg("No data found"), animated: true,completion: nil)
                        }
                    }
                }
                catch{
                    DispatchQueue.main.async { [self] in
                        self.blurView.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
            else{
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
                }
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
}
