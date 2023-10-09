//
//  ShareAccountsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 08/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class ShareAccountsViewController: UIViewController, URLSessionDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    @IBOutlet weak var shareAccListTbl      : UITableView!
    
    var customerId      = String()
    var TokenNo         = String()
    var accHolderName   = String()
    var instanceOfEncryptionPost: EncryptionPost    = EncryptionPost()
    var CustomerLoanAndDepositDetailsList           = [NSDictionary]()
    let checkedImage    = #imageLiteral(resourceName: "ic_check_box_tick")
    let uncheckedImage  = #imageLiteral(resourceName: "ic_check_box")
    var isChecked: Bool = false
    var selectedItems   = [Int]()
    var ShareList        = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do{
            let fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                accHolderName = (fetchedCusDetail.value(forKey: "name") as? String)!
            }
        }
        catch{
        }
        blurView.isHidden = false
        activityIndicator.startAnimating()
        setAccBalance()

        
    }
    
    
    func setAccBalance() {
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
        let url = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/CustomerLoanAndDepositDetails")!
//        let encryptedReqMode = instanceOfEncryptionPost.encryptUseDES("14", key: "Agentscr")
//        let encryptedTocken = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
//        let encryptedSubMode = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
//        let encryptedLoanType = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
        
        let encryptedReqMode = "14"
        let encryptedTocken = TokenNo
        let encryptedCusNum = customerId
        let encryptedSubMode = "1"
        let encryptedLoanType = "1"
        let jsonDict = ["ReqMode"       : encryptedReqMode,
                        "Token"         : encryptedTocken,
                        "FK_Customer"   : encryptedCusNum ,
                        "SubMode"       : encryptedSubMode,
                        "LoanType"      : encryptedLoanType,
                        "BankKey"       : BankKey,
                        "BankHeader"    : BankHeader]
        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { [self] data, response, error in
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
                        let CustomerLoanAndDepositDetails  = responseJSONData.value(forKey: "CustomerLoanAndDepositDetails") as! NSDictionary
                        CustomerLoanAndDepositDetailsList = CustomerLoanAndDepositDetails.value(forKey: "CustomerLoanAndDepositDetailsList") as! [NSDictionary]
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self!.shareAccListTbl.reloadData()
                        }

                    }
                    
                    else {
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.shareAccListTbl.isHidden = true
                        }
                        let CustomerLoanAndDepositDetails  = responseJSONData.value(forKey: "CustomerLoanAndDepositDetails") as Any
                        if CustomerLoanAndDepositDetails as? NSDictionary != nil {
                                let CustomerLoanAndDepositDetail  = responseJSONData.value(forKey: "CustomerLoanAndDepositDetails") as! NSDictionary
                            let ResponseMessage =  CustomerLoanAndDepositDetail.value(forKey: "ResponseMessage") as! String

                            DispatchQueue.main.async { [weak self] in
                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
                            }
                        }
                        else {
                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String

                            DispatchQueue.main.async { [weak self] in
                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
                            }
                        }
                    }
                    
        
                }
                catch{
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                        self?.blurView.isHidden = true
                        self?.shareAccListTbl.isHidden = true
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CustomerLoanAndDepositDetailsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccShareCell") as! AccShareTableViewCell
        
            cell.accHolderName.text = accHolderName
        
        cell.accHolderDetails.text = "A/C NUMBER : " + (CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "AccountNumber") as! String)
            + "\nBRANCH NAME : " + (CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "BranchName") as! String)
            + "\nFUND TRANSFER A/C : " + (CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "FundTransferAccount") as! String)
            + "\nIFSC CODE : " + (CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "IFSCCode") as! String)

        cell.accSelectionCheckbox.tag = indexPath.row
        if (selectedItems.contains(indexPath.row)) {
            cell.accSelectionCheckbox.setImage(checkedImage, for: UIControl.State.normal)
        }
        else {
            cell.accSelectionCheckbox.setImage(uncheckedImage, for: UIControl.State.normal)
        }
        cell.accSelectionCheckbox.tag = indexPath.row
        cell.accSelectionCheckbox.addTarget(self, action: #selector(checkButtonPressed(_:)), for: .touchUpInside)
        return cell
    }
    
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        isChecked = !isChecked
        if (self.selectedItems.contains(sender.tag)) {
            var i = 0
            for seItem in selectedItems {
                i = i + 1
                if seItem == sender.tag {
                    self.selectedItems.remove(at:i-1)
                }
            }
        }
        else {
            self.selectedItems.append(sender.tag)
        }
        DispatchQueue.main.async { [weak self] in
            self!.shareAccListTbl.reloadData()
        }
        
    }
    var shareAcc = String()
    @IBAction func ShareAccounts(_ sender: UIButton) {
        if selectedItems.count == 0 {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg("Please Select Account To Share."), animated: true,completion: nil)
            }
        }
        else {
//            shareAcc = "Beneficiary Name : " + accHolderName
            shareAcc = ""
            ShareList = []
            for ItemListIndex in selectedItems {
                shareAcc +=  "\nAccount Type : " + (CustomerLoanAndDepositDetailsList[ItemListIndex].value(forKey: "LoanType") as! String) +  "\nBeneficiary Account : " + (CustomerLoanAndDepositDetailsList[ItemListIndex].value(forKey: "FundTransferAccount") as! String)
                    + "\nIFSC CODE : " + (CustomerLoanAndDepositDetailsList[ItemListIndex].value(forKey: "IFSCCode") as! String) + "\n\n"
                ShareList.append("\nAccount Type :  \((CustomerLoanAndDepositDetailsList[ItemListIndex].value(forKey: "LoanType") as! String)) \nBeneficiary Account : \(CustomerLoanAndDepositDetailsList[ItemListIndex].value(forKey: "FundTransferAccount") as! String) \nIFSC CODE : \(CustomerLoanAndDepositDetailsList[ItemListIndex].value(forKey: "IFSCCode") as! String) \n\n")
            }
            share()
        }
    }
    func share(){
        let customReminderAlert = self.storyboard?.instantiateViewController(withIdentifier: "shareAlert") as! ShareAlertViewController
        customReminderAlert.providesPresentationContextTransitionStyle = true
        customReminderAlert.definesPresentationContext = true
        customReminderAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customReminderAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customReminderAlert.delegate = self
        customReminderAlert.shareListData = shareAcc
        customReminderAlert.shareList = ShareList
        self.present(customReminderAlert, animated: true, completion: nil)
    }
}

extension ShareAccountsViewController: ShareAlertDelegate{
    
    func shareButtonTapped() {
        print("share")
    }
    func cancelButtonTapped() {
        print("cancel")
    }

    
}
