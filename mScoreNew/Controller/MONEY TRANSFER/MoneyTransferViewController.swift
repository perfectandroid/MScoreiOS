//
//  OtherBankViewController.swift
//  mScoreNew
//
//  Created by Perfect on 06/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class MoneyTransferViewController: UIViewController, URLSessionDelegate,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var table            : UITableView!
    @IBOutlet weak var ownAcctable      : UITableView!
    @IBOutlet weak var otherAcctable    : UITableView!
    @IBOutlet weak var OwnbankView      : UIView!
    @IBOutlet weak var OwnbankBtn       : UIButton!
    @IBOutlet weak var OtherBankBtn     : UIButton!
    @IBOutlet weak var multiBankHdr     : NSLayoutConstraint!
    @IBOutlet weak var blurView         : UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ownAccHdr: UILabel!{
        didSet{
            ownAccHdr.isHidden = true
        }
    }
    @IBOutlet weak var otherAccHdr: UILabel!{
        didSet{
            otherAccHdr.isHidden = true
        }
    }
    @IBOutlet weak var ownAccTblHt: NSLayoutConstraint! {
        didSet{
            ownAccTblHt.constant = CGFloat(0)
        }
    }
    @IBOutlet weak var otherAccTblHt: NSLayoutConstraint! {
        didSet{
            otherAccTblHt.constant = CGFloat(0)
        }
    }
    @IBOutlet weak var ownAccVwHt: NSLayoutConstraint! {
        didSet{
            ownAccVwHt.constant = CGFloat(0)
        }
    }
    @IBOutlet weak var otherAccVwHt: NSLayoutConstraint! {
        didSet{
            otherAccVwHt.constant = CGFloat(0)
        }
    }
    var TokenNo = String()
    var ownAccMoneyTransfer = Bool()
    var customerId = String()
    var pin = String()
    var sectionName = String()
    var tag: Int!
    var dmenus = [String]()
    var otherbankMenus = [String]()
    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()
    var OwnAccountdetailsList = [NSDictionary]()
    var fromAccDetails = NSDictionary()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // header top space settings
        otherbankMenus = dmenus
        if ownAccMoneyTransfer == true {
            multiBankHdr.constant = CGFloat(0)
            OwnbankBtn.isHidden = true
            OtherBankBtn.isHidden = true
        }
        else {
            multiBankHdr.constant = CGFloat(45)
            OwnbankBtn.isHidden = false
            OtherBankBtn.isHidden = false
        }
        otherbankMenus.append("FUND TRANSFER STATUS")
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        OwnAccounDetails()
        
        
        OwnbankBtn.buttonUnderLineColor(underLineGreen)
        OtherBankBtn.buttonUnderLineColor(UIColor.white)
        OwnbankBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        OtherBankBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
    }
    
    func OwnAccounDetails() {
        DispatchQueue.main.async { [self] in
            self.blurView.isHidden = false
            self.activityIndicator.startAnimating()
        }
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [self] in
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
                self.blurView.isHidden = true
                self.activityIndicator.stopAnimating()
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/OwnAccounDetails")!
        
        
        
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("13", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
//        let encryptedSubMode     = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
        
        let encryptedReqMode     = "13"
        let encryptedTocken     = TokenNo
        let encryptedCusNum     = customerId
        let encryptedSubMode     = "1"
        let jsonDict            = ["ReqMode" : encryptedReqMode,
                                   "Token" : encryptedTocken,
                                   "FK_Customer" : encryptedCusNum ,
                                   "SubMode" : encryptedSubMode,
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
        let task = session.dataTask(with: request) { [self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { [self] in
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                    self.blurView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    DispatchQueue.main.async { [self] in
                        self.blurView.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }

                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
                        OwnAccountdetailsList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as! [NSDictionary]
                        DispatchQueue.main.async { [weak self] in
                            self?.ownAcctable.reloadData()
                            self?.otherAcctable.reloadData()
                        }
                    }
                    else {
                        
                        let OwnAccountdetails  = responseJSONData.value(forKey: "OwnAccountdetails") as Any
                        if OwnAccountdetails as? String != nil {
                                let OwnAccountdetail  = responseJSONData.value(forKey: "OwnAccountdetails") as! NSDictionary
                            let ResponseMessage =  OwnAccountdetail.value(forKey: "ResponseMessage") as! String

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
    
    
    
    @IBAction func OwnAccListBtn(_ sender: UIButton) {
        if ownAccVwHt.constant == CGFloat(0) {
            ownAccTblHt.constant = CGFloat((60 * OwnAccountdetailsList.count) )
            ownAccVwHt.constant = CGFloat((60 * OwnAccountdetailsList.count) + 50)
            ownAccHdr.isHidden = false
            otherAccTblHt.constant = CGFloat(0)
            otherAccVwHt.constant = CGFloat(0)
            otherAccHdr.isHidden = true

        }
        else {
            ownAccTblHt.constant = CGFloat(0)
            ownAccVwHt.constant = CGFloat(0)
            ownAccHdr.isHidden = true

        }
    }
    
    @IBAction func otherAccListBtn(_ sender: UIButton) {
        if otherAccVwHt.constant == CGFloat(0) {
            otherAccTblHt.constant = CGFloat((60 * OwnAccountdetailsList.count) )
            otherAccVwHt.constant = CGFloat((60 * OwnAccountdetailsList.count) + 50)
            otherAccHdr.isHidden = false
            ownAccTblHt.constant = CGFloat(0)
            ownAccVwHt.constant = CGFloat(0)
            ownAccHdr.isHidden = true
            self.view.layoutIfNeeded()

        }
        else {
            otherAccTblHt.constant = CGFloat(0)
            otherAccVwHt.constant = CGFloat(0)
            otherAccHdr.isHidden = true
            self.view.layoutIfNeeded()

        }
    }
    // function for convert string to dictionary format
    func convertToDictionary(text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8)
        {
            do
            {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }
            catch
            {
                self.present(messages.msg(error.localizedDescription), animated: true, completion: nil)
            }
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == table {
            return otherbankMenus.count
        }
        return OwnAccountdetailsList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == table {
            
            print("table view height --- \(tableView.bounds.height)")
            return tableView.bounds.height / CGFloat(otherbankMenus.count)
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == table {
            let cell = tableView.dequeueReusableCell(withIdentifier: "otherBankOpt") as! otherBankTableViewCell
            cell.otherBankSelection?.text = otherbankMenus[indexPath.item]
            
            if otherbankMenus[indexPath.item] == "QUICK PAY" {
                cell.otherBankIcon.image = UIImage(imageLiteralResourceName: "ic_mtot_quick_pay.png")
            }
            else if otherbankMenus[indexPath.item] == "RTGS" {
                cell.otherBankIcon.image =  UIImage(imageLiteralResourceName: "ic_mtot_rtgs.png")
            }
            else if otherbankMenus[indexPath.item] == "IMPS" {
                cell.otherBankIcon.image =  UIImage(imageLiteralResourceName: "ic_mtot_imps.png")
            }
            else if otherbankMenus[indexPath.item] == "NEFT" {
                cell.otherBankIcon.image =  UIImage(imageLiteralResourceName: "ic_mtot_neft.png")
            }
            else{
                cell.otherBankIcon.image = UIImage(imageLiteralResourceName: "ic_mtot_txn_history.png")
            }
            return cell
        }
        else if tableView == ownAcctable{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ownAccList") as! ownBankAccListTableViewCell
            cell.accNumberL?.text =  OwnAccountdetailsList[indexPath.item].value(forKey: "AccountNumber") as? String
            cell.hdOfficeL?.text =  OwnAccountdetailsList[indexPath.item].value(forKey: "BranchName") as? String
            cell.accBalanceL?.text =  (OwnAccountdetailsList[indexPath.item].value(forKey: "Balance") as? Double)?.currencyIN

            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherAccList") as! ownBankAccListTableViewCell
        cell.accNumberL?.text =  OwnAccountdetailsList[indexPath.item].value(forKey: "AccountNumber") as? String
        cell.hdOfficeL?.text =  OwnAccountdetailsList[indexPath.item].value(forKey: "BranchName") as? String
        cell.accBalanceL?.text =  (OwnAccountdetailsList[indexPath.item].value(forKey: "Balance") as? Double)?.currencyIN

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == table{
            let currentCell = tableView.cellForRow(at: indexPath) as! otherBankTableViewCell
            tag = 0
            sectionName =  currentCell.otherBankSelection.text!
            if sectionName == "QUICK PAY"
            {
                tag = 1
                performSegue(withIdentifier: "quickPay", sender: self)
            }
            else if sectionName == "FUND TRANSFER STATUS"
            {
                performSegue(withIdentifier: "fundTransferStatusSegue", sender: self)
            }
            else{
                performSegue(withIdentifier: "imps/rtgs/neft", sender: self)
            }
        }
        else if tableView == ownAcctable {
            fromAccDetails = OwnAccountdetailsList[indexPath.item]
            performSegue(withIdentifier: "OwnBankOwnAccount", sender: self)
        }
        else if tableView == otherAcctable {
            fromAccDetails = OwnAccountdetailsList[indexPath.item]
            performSegue(withIdentifier: "OwnBankOtherAccount", sender: self)
        }
        
    }
    
    @IBAction func OwnBank(_ sender: UIButton) {
        OwnbankView.isHidden = false
        OwnbankBtn.buttonUnderLineColor(underLineGreen)
        OtherBankBtn.buttonUnderLineColor(UIColor.white)
        OwnbankBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        OtherBankBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)


    }
    
    @IBAction func OtherBank(_ sender: UIButton) {
        OwnbankView.isHidden = true
        OwnbankBtn.buttonUnderLineColor(UIColor.white)
        OtherBankBtn.buttonUnderLineColor(underLineGreen)
        OwnbankBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        OtherBankBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        
    }

    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from home screen to accInfo screen
        if segue.identifier == "quickPay"
        {
            let vw = segue.destination as! QuickPayViewController
            vw.pin = pin
            vw.customerId = customerId
            vw.TokenNo = TokenNo
            vw.sectionName = sectionName
        }
        // from home screen to search screen
        else if segue.identifier == "imps/rtgs/neft"
        {
            let vw = segue.destination as! ImpsNeftRtgsViewController
            vw.pin = pin
            vw.customerId = customerId
            vw.TokenNo = TokenNo
            vw.sectionName = sectionName
        }
        else if segue.identifier == "OwnBankOtherAccount"
        {
            let otherAccBank = segue.destination as! OwnBankOtherAccountViewController
            otherAccBank.pin        = pin
            otherAccBank.TokenNo    = TokenNo
            otherAccBank.customerId = customerId
            otherAccBank.payingFromAccDetails = fromAccDetails
        }
        
        else if segue.identifier == "OwnBankOwnAccount"
        {
            let ownAccBank = segue.destination as! OwnBankOwnAccountViewController
            ownAccBank.pin        = pin
            ownAccBank.TokenNo    = TokenNo
            ownAccBank.customerId = customerId
            ownAccBank.payingFromAccDetails = fromAccDetails
        }
        else if segue.identifier == "fundTransferStatusSegue"
        {
            let vw = segue.destination as! FundTransferStatusViewController
            vw.customerId = customerId
            vw.TokenNo = TokenNo
            vw.SubMode = "0"
        }
    }
    
}
