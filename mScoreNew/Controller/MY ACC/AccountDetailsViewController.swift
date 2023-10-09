//
//  AccountDetailsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 11/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class AccountDetailsViewController: UIViewController, URLSessionDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
  
    
    @IBOutlet weak var myAccTypeL               : UILabel!
    @IBOutlet weak var myAccNo                  : UILabel!
    @IBOutlet weak var myBalanceHdr             : UILabel!
    @IBOutlet weak var myBalanceL               : UILabel!
    @IBOutlet weak var myFundTransferL          : UILabel!
    @IBOutlet weak var ifscCodeL                : UILabel!
    @IBOutlet weak var share                    : UIButton!
    @IBOutlet weak var accDetalilTable          : UITableView!
    @IBOutlet weak var OptionalButtonCollection : UICollectionView!
    @IBOutlet weak var optDetails               : NSLayoutConstraint!
    @IBOutlet weak var hdrViewHt                : NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidth      : NSLayoutConstraint!
    
    @IBOutlet weak var blurView                 : UIView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    var custoID                             = Int()
    var TokenNo                             = String()
    var CustomerLoanAndDepositDetail        = NSDictionary()
    var DepositLoanSele                     = Int()
    var actvClsSele                         = Int()
    var CustomerLoanAndDepositDetailList    = [NSDictionary]()
    var HdrClick                            = ["Mini Statement"]
    var HdrClickImg                         = [#imageLiteral(resourceName: "icma_mini_stmnt")]
    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()
    var shareAcc                            = String()
    var shareList                           = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if CustomerLoanAndDepositDetail.value(forKey: "IsShareAc") as! Int == 0 {
            share.isHidden = true
            optDetails.constant = 0
            hdrViewHt.constant = 110
        }
        myAccTypeL.text = "A/C Type : " + (CustomerLoanAndDepositDetail.value(forKey: "LoanType") as! String)
        ifscCodeL.text = (CustomerLoanAndDepositDetail.value(forKey: "IFSCCode") as! String)
        myFundTransferL.text = (CustomerLoanAndDepositDetail.value(forKey: "FundTransferAccount") as! String)
        myAccNo.text = (CustomerLoanAndDepositDetail.value(forKey: "AccountNumber") as! String)
        myBalanceL.text = (CustomerLoanAndDepositDetail.value(forKey: "Balance") as! Double).currencyIN
        
        if DepositLoanSele == 1 {
            myBalanceHdr.text = "Balance"
        }
        else{
            myBalanceHdr.text = "Loan Amount"
        }
        if actvClsSele == 2 {
            OptionalButtonCollection.isHidden = true
            HdrClick    = []
            HdrClickImg = []
            if CustomerLoanAndDepositDetail.value(forKey: "IsShareAc") as! Int == 0 {
                UIView.animate(withDuration: 0.2) {
                    self.share.isHidden = true
                    self.optDetails.constant = 0
                    self.hdrViewHt.constant = 80
                    self.view.layoutIfNeeded()
                }
            }
            else{
                UIView.animate(withDuration: 0.2) {
                    self.share.isHidden = false
                    self.optDetails.constant = 70
                    self.hdrViewHt.constant = 150
                    self.view.layoutIfNeeded()
                }
                
            }
        }
        else if actvClsSele == 1 && DepositLoanSele == 1 {
            HdrClick    = ["Mini Statement"]
            HdrClickImg    = [#imageLiteral(resourceName: "icma_mini_stmnt")]
            collectionViewWidth.constant = (view.bounds.width - 40) / 2

        }
        else if actvClsSele == 1 && DepositLoanSele == 2 {
            HdrClick    = ["Mini Statement", "Loan Schedule"]
            collectionViewWidth.constant = (view.bounds.width - 40) / 1
            HdrClickImg    = [#imageLiteral(resourceName: "icma_mini_stmnt"),#imageLiteral(resourceName: "icma_share_acnt")]
        }
        OptionalButtonCollection.reloadData()
        AccountModuleDetailsListInfo()
    }
    
    
    
    
    func AccountModuleDetailsListInfo() {
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/AccountModuleDetailsListInfo")!
        
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("3", key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedSubModule    = instanceOfEncryptionPost.encryptUseDES((CustomerLoanAndDepositDetail.value(forKey: "SubModule") as! String), key: "Agentscr")
//        let encryptedFK_Account     = instanceOfEncryptionPost.encryptUseDES(String(CustomerLoanAndDepositDetail.value(forKey: "FK_Account") as! Int64), key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedLoanType     = instanceOfEncryptionPost.encryptUseDES(String(actvClsSele), key: "Agentscr")
        
        let subModules = CustomerLoanAndDepositDetail.value(forKey: "SubModule") as? String ?? ""
        
        let FK_Account  = CustomerLoanAndDepositDetail.value(forKey: "FK_Account") as! NSNumber
        
        
        
        let jsonDict            = ["ReqMode" : "3",
                                   "FK_Customer" : "\(custoID)" ,
                                   "SubModule" : subModules,
                                   "FK_Account" : "\(FK_Account)",
                                   "Token" : TokenNo,
                                   "LoanType": "\(actvClsSele)",
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]
    
        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
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
                    let sttsCode = responseJSONData.value(forKey: "StatusCode") as! Int
                    if sttsCode==0 {
                        let AccountModuleDetailsListInfo  = responseJSONData.value(forKey: "AccountModuleDetailsListInfo") as! NSDictionary
                        let data = AccountModuleDetailsListInfo.value(forKey: "Data") as! [NSDictionary]
                        CustomerLoanAndDepositDetailList = data[0].value(forKey: "Details") as! [NSDictionary]

                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self!.accDetalilTable.reloadData()

                        }
                    }
                
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                    }
                }
                catch{
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                        self?.blurView.isHidden = true
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HdrClick.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        let cellSize = CGSize(width: (Int(collectionView.bounds.width) - 10)/HdrClick.count, height: 30)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accDetailsHdrCell", for: indexPath as IndexPath) as! accDetailsCollectionViewCell
        cell.secImg.image = HdrClickImg[indexPath.row]
        cell.secL.text = HdrClick[indexPath.row]

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accDetailsHdrCell", for: indexPath as IndexPath) as! accDetailsCollectionViewCell
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "miniStatementSegue", sender: nil)
        }
        else if indexPath.row == 1 {
            self.performSegue(withIdentifier: "loanScheduleSegue", sender: nil)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CustomerLoanAndDepositDetailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accDetailsCell") as! AccountDetailsTableViewCell
        cell.keyLbl.text = (CustomerLoanAndDepositDetailList[indexPath.row].value(forKey: "Key") as! String)
        cell.valueLabel.text = (CustomerLoanAndDepositDetailList[indexPath.row].value(forKey: "Value") as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (CustomerLoanAndDepositDetailList[indexPath.row].value(forKey: "Key") as! String) == "Account No" ||
            (CustomerLoanAndDepositDetailList[indexPath.row].value(forKey: "Key") as! String) == "Account Type" ||
            (CustomerLoanAndDepositDetailList[indexPath.row].value(forKey: "Key") as! String) == "Aval Balance" ||
            (CustomerLoanAndDepositDetailList[indexPath.row].value(forKey: "Key") as! String) == "Fund Transfer Account" ||
            (CustomerLoanAndDepositDetailList[indexPath.row].value(forKey: "Key") as! String) == "IFSC Code" {
            return 0
        }
        else{
             return 50
        }
    }
    
    @IBAction func ShareDetails(_ sender: UIButton) {
        shareAcc = ""
        shareList = []
        shareAcc =  "\nAccount Type : " + (CustomerLoanAndDepositDetail.value(forKey: "LoanType") as! String) +  "\nBeneficiary Account : " + (CustomerLoanAndDepositDetail.value(forKey: "FundTransferAccount") as! String)
            + "\nIFSC CODE : " + (CustomerLoanAndDepositDetail.value(forKey: "IFSCCode") as! String) + "\n\n"
        shareList.append("\nAccount Type : " + (CustomerLoanAndDepositDetail.value(forKey: "LoanType") as! String) +  "\nBeneficiary Account : " + (CustomerLoanAndDepositDetail.value(forKey: "FundTransferAccount") as! String)
            + "\nIFSC CODE : " + (CustomerLoanAndDepositDetail.value(forKey: "IFSCCode") as! String) + "\n\n")
        let customReminderAlert = self.storyboard?.instantiateViewController(withIdentifier: "shareAlert") as! ShareAlertViewController
        customReminderAlert.providesPresentationContextTransitionStyle = true
        customReminderAlert.definesPresentationContext = true
        customReminderAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customReminderAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customReminderAlert.delegate = self
        customReminderAlert.shareListData = shareAcc
        customReminderAlert.shareList = shareList
        self.present(customReminderAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "miniStatementSegue"
        {
            let accDet = segue.destination as! miniStatementViewController
                accDet.custoID    = custoID
                accDet.TokenNo   = TokenNo
                accDet.CustomerLoanAndDepositDetail      = CustomerLoanAndDepositDetail
                accDet.DepositLoanSele      = DepositLoanSele
                accDet.actvClsSele = actvClsSele
            
        }
        if segue.identifier == "loanScheduleSegue"
        {
            let accDet = segue.destination as! loanScheduleViewController
                accDet.custoID    = custoID
                accDet.TokenNo   = TokenNo
                accDet.CustomerLoanAndDepositDetail      = CustomerLoanAndDepositDetail
                accDet.DepositLoanSele      = DepositLoanSele
                accDet.actvClsSele = actvClsSele
            
        }
    }
}


extension AccountDetailsViewController: ShareAlertDelegate{
    
    func shareButtonTapped() {
        print("share")
    }
    func cancelButtonTapped() {
        print("cancel")
    }

    
}
