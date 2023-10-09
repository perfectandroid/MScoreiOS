//
//  AccInfo.swift
//  mScoreNew
//
//  Created by Perfect on 03/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class MyAccViewController: NetworkManagerVC, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var depositButton            : UIButton!
    @IBOutlet weak var loanButton               : UIButton!
    @IBOutlet weak var activeClosedSelection    : UISegmentedControl!
    @IBOutlet weak var listAsOnL                : UILabel!{
        didSet{
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let result = formatter.string(from: date)
            listAsOnL.text = "**List As On " + result
        }
    }
    @IBOutlet weak var myAccTable               : UITableView!
    @IBOutlet weak var blurView                 : UIView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    
    var accountInfo:[Customerdetails]               = []
    var instanceOfEncryptionPost: EncryptionPost    = EncryptionPost()
    var custoID                                     = Int()
    var TokenNo                                     = String()
    lazy var CustomerLoanAndDepositDetailsList           = [NSDictionary](){
        didSet{
            DispatchQueue.main.async {
                self.myAccTable.reloadData()
            }
            
        }
    }
    var CustomerLoanAndDepositDetail                = NSDictionary()
    var DepositLoanSele                             = 1
    var actvClsSele                                 = 1
    
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        for fetchedCusDetail in accountInfo
        {
            custoID     = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
            TokenNo     = (fetchedCusDetail.value(forKey: "tokenNum") as? String)!
        }
        
            
            if(self.activeClosedSelection.selectedSegmentIndex == 0){
                self.actvClsSele = 1
                customerLoanAndDepositDetailsApi(selected_type: self.DepositLoanSele, status: self.actvClsSele)
               // self!.CustomerLoanAndDepositDetails(self!.DepositLoanSele , self!.actvClsSele) 4
            }
            else{
                self.actvClsSele = 2
                customerLoanAndDepositDetailsApi(selected_type: self.DepositLoanSele, status: self.actvClsSele)
                //self!.CustomerLoanAndDepositDetails(self!.DepositLoanSele , self!.actvClsSele) 5
            }
        
        
        depositButton.buttonUnderLineColor(underLineGreen)
        loanButton.buttonUnderLineColor(UIColor.white)
        depositButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        loanButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
    }
    
    @IBAction func Deposit(_ sender: UIButton) {
        activityIndicator.startAnimating()
        blurView.isHidden = false
        activeClosedSelection.selectedSegmentIndex = 0
        DepositLoanSele = 1
        actvClsSele = 1
        depositButton.buttonUnderLineColor(underLineGreen)
        loanButton.buttonUnderLineColor(UIColor.white)
        depositButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        loanButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        //CustomerLoanAndDepositDetails( DepositLoanSele , actvClsSele) 6
        customerLoanAndDepositDetailsApi(selected_type: self.DepositLoanSele, status: self.actvClsSele)
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let result = formatter.string(from: date)
            listAsOnL.text = "**List As On " + result

    }
    
    @IBAction func Loan(_ sender: UIButton) {
        activityIndicator.startAnimating()
        blurView.isHidden = false
        activeClosedSelection.selectedSegmentIndex = 0
        DepositLoanSele = 2
        actvClsSele = 1
        loanButton.buttonUnderLineColor(underLineGreen)
        depositButton.buttonUnderLineColor(UIColor.white)
        loanButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        depositButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        //CustomerLoanAndDepositDetails( DepositLoanSele , actvClsSele) 7
        customerLoanAndDepositDetailsApi(selected_type: self.DepositLoanSele, status: self.actvClsSele)
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let result = formatter.string(from: date)
            listAsOnL.text = "**List As On " + result
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func modeSelection(_ sender: UISegmentedControl)
    {
        activityIndicator.startAnimating()
        blurView.isHidden = false
        if(activeClosedSelection.selectedSegmentIndex == 0){
            actvClsSele = 1
           // CustomerLoanAndDepositDetails( DepositLoanSele , actvClsSele) 1
            customerLoanAndDepositDetailsApi(selected_type: self.DepositLoanSele, status: self.actvClsSele)
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                let result = formatter.string(from: date)
                listAsOnL.text = "**List As On " + result
        }
        else{
            actvClsSele = 2
            //CustomerLoanAndDepositDetails(DepositLoanSele , actvClsSele) 2
            customerLoanAndDepositDetailsApi(selected_type: self.DepositLoanSele, status: self.actvClsSele)
            listAsOnL.text = "**List Of Last Three Months."

        }
    }
    
    func customerLoanAndDepositDetailsApi( selected_type:Int, status:Int) {
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = APIBaseUrlPart1 + "/AccountSummary/CustomerLoanAndDepositDetails"
        
        let ReqMode    = "14"
        let tocken     = TokenNo
        let CusNum     = String(custoID)
        let SubMode    = String(selected_type)
        let LoanType   = String(status)
        
        let arguments = ["ReqMode"        : ReqMode,
                         "Token"          : tocken,
                         "FK_Customer"    : CusNum ,
                         "SubMode"        : SubMode,
                         "LoanType"       : LoanType,
                         "BankKey"        : BankKey,
                         "BankHeader"     : BankHeader]
        
       
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    
                       let exMessage = datas.value(forKey: self.EXMessage) as? String ?? ""
                        let CustomerLoanAndDepositDetails = datas.value(forKey: "CustomerLoanAndDepositDetails") as? NSDictionary ?? [:]
                        let info = CustomerLoanAndDepositDetails
                        let infoList = info.value(forKey: "CustomerLoanAndDepositDetailsList") as? [NSDictionary] ?? []
                        let responseMessage = info.value(forKey: self.ResponseMessage) as? String ?? ""
                        
                        self.CustomerLoanAndDepositDetailsList = []
                        if statusCode == 0{
                            
                            if infoList.count > 0{
                            self.CustomerLoanAndDepositDetailsList = infoList.map{ $0 }
                            }else{
                                DispatchQueue.main.async {
                                    self.present(messages.msg(responseMessage), animated: true,completion: nil)
                                }
                            }
        
                        }else{
                                
                         let messageData  = responseMessage == "" ? exMessage : responseMessage
                            DispatchQueue.main.async {
                                self.present(messages.msg(messageData), animated: true,completion: nil)
                            }
                                
                        }
                    
                            
                }
            case.failure(let errResponse):
               
                var msg = ""
                
                let response = self.apiErrorResponseResult(errResponse: errResponse)
                msg = response.1
                
                    
                DispatchQueue.main.async {
                    self.present(messages.msg(msg), animated: true, completion: nil)
                }
            }
            self.removeIndicator(showMessagge: false, message: "",activityView: self.activityIndicator, blurview: self.blurView)
        }
        
    }
    
 

    func CustomerLoanAndDepositDetails(_ Type : Int, _ Status : Int) {
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/CustomerLoanAndDepositDetails")!
//        let encryptedReqMode    = instanceOfEncryptionPost.encryptUseDES("14", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedSubMode    = instanceOfEncryptionPost.encryptUseDES(String(Type), key: "Agentscr")
//        let encryptedLoanType   = instanceOfEncryptionPost.encryptUseDES(String(Status), key: "Agentscr")
        
        let encryptedReqMode    = "14"
        let encryptedTocken     = TokenNo
        let encryptedCusNum     = String(custoID)
        let encryptedSubMode    = String(Type)
        let encryptedLoanType   = String(Status)
        let jsonDict            = ["ReqMode"        : encryptedReqMode,
                                   "Token"          : encryptedTocken,
                                   "FK_Customer"    : encryptedCusNum ,
                                   "SubMode"        : encryptedSubMode,
                                   "LoanType"       : encryptedLoanType,
                                   "BankKey"        : BankKey,
                                   "BankHeader"     : BankHeader]
        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody    = jsonData
        let session             = URLSession(configuration: .default,
                                             delegate: self,
                                             delegateQueue: nil)
        let task                = session.dataTask(with: request) { [self] data, response, error in
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
                        let CustomerLoanAndDepositDetails   = responseJSONData.value(forKey: "CustomerLoanAndDepositDetails") as! NSDictionary
                        CustomerLoanAndDepositDetailsList   = CustomerLoanAndDepositDetails.value(forKey: "CustomerLoanAndDepositDetailsList") as! [NSDictionary]
                        
                            DispatchQueue.main.async { [weak self] in
                                self?.activityIndicator.stopAnimating()
                                self?.blurView.isHidden = true
                                self?.myAccTable.reloadData()
                            }
                    }
                    else {
                        CustomerLoanAndDepositDetailsList = []
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.myAccTable.reloadData()
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
                    CustomerLoanAndDepositDetailsList = []
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                        self?.blurView.isHidden = true
                        self?.myAccTable.reloadData()
                    }
                }
            }
            else{
                CustomerLoanAndDepositDetailsList = []
                
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                    self?.myAccTable.reloadData()
                
                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
                }
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return CustomerLoanAndDepositDetailsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (myAccTable.dequeueReusableCell(withIdentifier: "myAccCell") as! myAccTableViewCell)
        cell.myAccTypeL.text = (CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "LoanType") as! String)
        cell.myAccNoDetailL.text = (CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "AccountNumber") as! String) + "\n" + (CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "BranchName") as! String)
        cell.myAccBalanceL.text = (CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "Balance") as! Double).currencyIN
        let  SubModule = CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "SubModule") as! String
        switch SubModule {
            case "DDSB":
                    cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_ddsb.png")
            case "DDCA":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_ddca.png")
            case "DDTD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_ddtd.png")
            case "TDFD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tdfd.png")
            case "TDCC":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tdcc.png")
            case "ODMD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_odmd.png")
            case "TDCH":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tdch.png")
            case "TDSD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tdsd.png")
            case "TDCD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tdcd.png")
            case "TDED":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tded.png")
            case "TDEM":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tdem.png")
            case "PDDD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_pddd.png")
            case "PDRD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_pdrd.png")
            case "PDGD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_pdgd.png")
            case "PDHD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_pdhd.png")
            case "ODGD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_odgd.png")
            case "SHAS":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_shas.png")
            case "SHNS":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_shns.png")
            case "SHSG":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_shsg.png")
            case "TLML":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tlml.png")
            case "TLSL":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tlsl.png")
            case "TLOD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tlod.png")
            case "TLSD":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_tlsd.png")
            case "SLJL":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_sljl.png")
            case "SLDL":
                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "icon_sldl.png")
            default: break
//                cell.myAccTypeImage.image = UIImage(imageLiteralResourceName: "ic_mtot_quick_pay.png")
        }

        if CustomerLoanAndDepositDetailsList[indexPath.row].value(forKey: "IsDue") as! Int == 1 {
            cell.backgroundColor = UIColor(red: 255.0/255.0,
                                           green: 239.0/255.0,
                                           blue: 213.0/255.0,
                                           alpha: 1.0)
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        CustomerLoanAndDepositDetail = CustomerLoanAndDepositDetailsList[indexPath.row]
        performSegue(withIdentifier: "accDetailsSegue",
                     sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "accDetailsSegue"
        {
            let accDet = segue.destination as! AccountDetailsViewController
                accDet.custoID    = custoID
                accDet.TokenNo   = TokenNo
                accDet.CustomerLoanAndDepositDetail      = CustomerLoanAndDepositDetail
                accDet.DepositLoanSele      = DepositLoanSele
                accDet.actvClsSele = actvClsSele
            
        }
    }
}
