//
//  StatementVDViewController.swift
//  mScoreNew
//
//  Created by Perfect on 18/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit
import DropDown


class StatementVDViewController: NetworkManagerVC, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var accSelectionBtn      : UIButton!
    @IBOutlet weak var monthHt              : NSLayoutConstraint!
    @IBOutlet weak var monthSeleVHt         : NSLayoutConstraint!
    @IBOutlet weak var dateHt               : NSLayoutConstraint!
    @IBOutlet weak var dateSeleVHt          : NSLayoutConstraint!
    @IBOutlet weak var monthSelectionBtn    : UIButton!
    @IBOutlet weak var fromDateSelectionBtn : UIButton!
    @IBOutlet weak var toDateSelectionBtn   : UIButton!
    @IBOutlet weak var monthRadioBtn        : UIButton!
    @IBOutlet weak var DateRadioBtn         : UIButton!
    @IBOutlet weak var monthV               : UIView! {
        didSet{
            monthV.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var fromV                : UIView!{
        didSet{
            fromV.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var toV                  : UIView!{
        didSet{
            toV.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var viewBt               : UIButton!{
        didSet{
            viewBt.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    
    
    let monthList = [ "January", "February", "March", "April", "May","June","July","August", "September","October","November","December"]
    var customerId = String()
    var TokenNo = String()
    var CustomerLoanAndDepositDetailsList = [NSDictionary]()
    
    var AccArray    = [String]()
    var accDrop     = DropDown()
    lazy var accDropDowns: [DropDown] = { return[self.accDrop] } ()
    
    var monthDrop     = DropDown()
    lazy var monthDropDowns: [DropDown] = { return[self.monthDrop] } ()
    var SubModule = String()
    var BranchCode = String()
    var FromNo = String()
    var documentController: UIDocumentInteractionController = UIDocumentInteractionController()
    var FileName  = String()
    var FilePath  = String()
    var monDat = 0
    var ViewDown = 0
    
    
    var FromDate = String()
    var ToDate = String()
    var DFromDate = String()
    var DToDate = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        FromDate = Date().startOfMonth("yyyy-MM-dd",Date())
        ToDate = Date().endOfMonth("yyyy-MM-dd",Date())
        monthHt.constant = 80
        monthSeleVHt.constant = 30
        dateHt.constant = 50
        dateSeleVHt.constant = 0
        monthSelectionBtn.setTitle(Date().currentDate(format: "MMMM"), for: .normal)
        let twoWBDate = twoWeeksBackDate()
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "dd-MM-yyyy"
        //        let date = dateFormatter.date(from: twoWBDate)
        DFromDate = Date().formattedDateFromString(dateString: twoWBDate, ipFormatter: "dd-MM-yyyy", opFormatter: "yyyy-MM-dd")!
        DToDate = Date().currentDate(format: "yyyy-MM-dd")
        fromDateSelectionBtn.setTitle(twoWBDate, for: .normal)
        toDateSelectionBtn.setTitle(Date().currentDate(format: "dd-MM-yyyy"), for: .normal)
        //accList()
        customerLoanAndDepositDetailsApi()
        setMonthDropDown()
    }
    
    //FIXME: - Get_Account_list_Api_Call()
    func customerLoanAndDepositDetailsApi() {
        
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
       
        let urlPath = APIBaseUrlPart1+"/AccountSummary/OwnAccounDetails"
        
        let arguments = ["FK_Customer":"\(customerId)","ReqMode":"13",
                         "token":"\(TokenNo)","BankKey":BankKey,
                         "BankHeader":BankHeader,
                         "SubMode":"1"]
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            switch getResult{
            case.success(let datas):
                print(datas)
                self.apiResponsStatusCheck(of: Int.self,datas) { statusCode  in
                    
                    let exMessage = datas.value(forKey: self.EXMessage) as? String ?? ""
                    let OwnAccountdetails = datas.value(forKey: "OwnAccountdetails") as? NSDictionary ?? [:]
                    let ResponseMessage = OwnAccountdetails.value(forKey: self.ResponseMessage) as? String ?? ""
                    
                    if statusCode == 0{
                        
                        let ownAccountDList = OwnAccountdetails.value(forKey: "OwnAccountdetailsList") as? [NSDictionary] ?? []
                        self.CustomerLoanAndDepositDetailsList = ownAccountDList.compactMap{$0}
                        self.AccArray = []
                        self.AccArray.append(contentsOf: self.CustomerLoanAndDepositDetailsList.map{ $0.value(forKey: "AccountNumber") as? String ?? "" })
                        
                        
                        DispatchQueue.main.async {
                            
                          
                            
                            self.setAccDropDown()
                        }
                        
                        
                    }else{
                        
                        let statusMessage = exMessage == "" ? ResponseMessage : exMessage
                        
                        DispatchQueue.main.async {
                            self.present(messages.msg(statusMessage), animated: true, completion: nil)
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
    
    func accList() {
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
        
//        let encryptedReqMode    = instanceOfEncryptionPost.encryptUseDES("26", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
//        let encryptedSubMode    = instanceOfEncryptionPost.encryptUseDES("0", key: "Agentscr")
//        let encryptedLoanType   = instanceOfEncryptionPost.encryptUseDES("0", key: "Agentscr")
        
        let encryptedReqMode    = "26"
        let encryptedTocken     = TokenNo
        let encryptedCusNum     = customerId
        let encryptedSubMode    = "0"
        let encryptedLoanType   = "0"
        let jsonDict            = ["ReqMode" : encryptedReqMode,
                                   "Token" : encryptedTocken,
                                   "FK_Customer" : encryptedCusNum ,
                                   "SubMode" : encryptedSubMode,
                                   "LoanType": encryptedLoanType,
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]
        
        print("parameters:\(jsonDict)")
        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody    = jsonData
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
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
                    let sttsCode = responseJSONData.value(forKey: "StatusCode") as! Int
                    if sttsCode == 0 {
                        
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.blurView.isHidden = true
                            self.view.layoutIfNeeded()
                        }
                        let CustomerLoanAndDepositDetails  = responseJSONData.value(forKey: "CustomerLoanAndDepositDetails") as! NSDictionary
                        self.CustomerLoanAndDepositDetailsList = CustomerLoanAndDepositDetails.value(forKey: "CustomerLoanAndDepositDetailsList") as! [NSDictionary]
                        DispatchQueue.main.async {
                            for PassbookAcc in self.CustomerLoanAndDepositDetailsList{
                                self.AccArray.append(PassbookAcc.value(forKey: "AccountNumber") as! String)
                            }
                            self.setAccDropDown()
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
    func setMonthDropDown()
    {
        monthDrop.anchorView      = monthSelectionBtn
        monthDrop.bottomOffset    = CGPoint(x: 0, y:40)
        monthDrop.dataSource      = monthList
        monthDrop.backgroundColor = UIColor.white
        monthDrop.selectionAction = {[weak self] (index, item) in
            DispatchQueue.main.async { [weak self] in
                self?.monthSelectionBtn.setTitle(item, for: .normal)
                let year = Calendar.current.component(.year, from: Date())
                var seleDate = ""

                if (String(index + 1)).count == 1{
                    seleDate = "\(year)-0\(String(index + 1))-01"
                }
                else{
                    seleDate = "\(year)-\(String(index + 1))-01"
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: seleDate)
                self?.FromDate = Date().startOfMonth("yyyy-MM-dd",date!)
                self?.ToDate = Date().endOfMonth("yyyy-MM-dd",date!)
                
            }
        }
    }
    
    func setAccDropDown()
    {
        accDrop.anchorView      = accSelectionBtn
        accDrop.bottomOffset    = CGPoint(x: 0, y:40)
        accDrop.dataSource      = AccArray
        accDrop.backgroundColor = UIColor.white
        accDrop.selectionAction = {[weak self] (index, item) in
            DispatchQueue.main.async { [weak self] in
                self?.accSelectionBtn.tag = 1
                self?.accSelectionBtn.setTitle(item, for: .normal)
                self?.FromNo = String(item.dropLast(5))

                self?.SubModule = self?.CustomerLoanAndDepositDetailsList[index].value(forKey: "SubModule") as! String
                self?.BranchCode     = ""
                do{
                    let fetchedAccDetails = try coredatafunction.fetchObjectofAcc()
                    for fetchedAccDetail in fetchedAccDetails
                    {
                        if item == (fetchedAccDetail.value(forKey: "accNum") as! String) + " (" + (fetchedAccDetail.value(forKey: "accTypeShort") as! String) + ")" {
                            self?.BranchCode     = (fetchedAccDetail.value(forKey: "codeOfBranch") as? String)!
                        }
                        
                    }
                }
                catch{
                }
            }
        }
    }
    
    func twoWeeksBackDate() -> String{
        let lastTwoWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let lastTwoWeekDateString = dateFormatter.string(from: lastTwoWeekDate)
        return lastTwoWeekDateString
    }
    
    @IBAction func selectAcc(_ sender: UIButton) {
        accDrop.show()
    }
    
    @IBAction func monthV(_ sender: UIButton) {
        monDat = 0
        monthHt.constant = 80
        monthSeleVHt.constant = 30
        dateHt.constant = 50
        dateSeleVHt.constant = 0
        DateRadioBtn.setImage(UIImage(named: "ic_radioUnchecked.png"), for: .normal)
        monthRadioBtn.setImage(UIImage(named: "ic_radioChecked.png"), for: .normal)

    }
    @IBAction func monthList(_ sender: UIButton) {
        monthDrop.show()
    }
    
    @IBAction func dateV(_ sender: UIButton) {
        monDat = 1
        monthHt.constant = 50
        monthSeleVHt.constant = 0
        dateHt.constant = 130
        dateSeleVHt.constant = 80
        monthRadioBtn.setImage(UIImage(named: "ic_radioUnchecked.png"), for: .normal)
        DateRadioBtn.setImage(UIImage(named: "ic_radioChecked.png"), for: .normal)
    }
    
    @IBAction func fromDate(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        var components = DateComponents()
            components.year  = 0
            components.day   = 0
            components.month = 0
        let maxDate            = Calendar.current.date(byAdding: components, to: Date())
        let myDatePicker: UIDatePicker  = UIDatePicker()
            myDatePicker.timeZone       = .current
            myDatePicker.datePickerMode = .date
            myDatePicker.maximumDate    = maxDate
            if #available(iOS 13.4, *) {
                myDatePicker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            alertController.view.addSubview(myDatePicker)
            myDatePicker.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .centerX,
                                                        multiplier: 1,
                                                        constant: 0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .centerY,
                                                        multiplier: 1,
                                                        constant: 0))
        alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: alertController.view,
                                                              attribute: .width,
                                                              multiplier: 1 ,
                                                              constant:0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: alertController.view.frame.height/4))
        let selectAction = UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
                let dateFormater: DateFormatter = DateFormatter()
                    dateFormater.dateFormat = "yyyy-MM-dd"
                self.DFromDate = dateFormater.string(from: myDatePicker.date) as String
            fromDateSelectionBtn.setTitle(Date().formattedDateFromString(dateString: self.DFromDate, ipFormatter: "yyyy-MM-dd", opFormatter: "dd-MM-yyyy"), for: .normal)
            })
            let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
    }
    
    @IBAction func toDate(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        var components = DateComponents()
            components.year  = 0
            components.day   = 0
            components.month = 0
        let maxDate            = Calendar.current.date(byAdding: components, to: Date())
        let myDatePicker: UIDatePicker  = UIDatePicker()
            myDatePicker.timeZone       = .current
            myDatePicker.datePickerMode = .date
            myDatePicker.maximumDate    = maxDate
            if #available(iOS 13.4, *) {
                myDatePicker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            alertController.view.addSubview(myDatePicker)
            myDatePicker.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .centerX,
                                                        multiplier: 1,
                                                        constant: 0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .centerY,
                                                        multiplier: 1,
                                                        constant: 0))
        alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: alertController.view,
                                                              attribute: .width,
                                                              multiplier: 1 ,
                                                              constant:0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: alertController.view.frame.height/4))
        
        let selectAction = UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            let dateFormater: DateFormatter = DateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd"
            self.DToDate = dateFormater.string(from: myDatePicker.date) as String
            toDateSelectionBtn.setTitle(Date().formattedDateFromString(dateString: self.DToDate, ipFormatter: "yyyy-MM-dd", opFormatter: "dd-MM-yyyy"), for: .normal)

        })
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func ViewStatement(_ sender: UIButton) {
        if accSelectionBtn.tag == 0{
            self.showToast(message: "Please Select Account Number.", controller: self)

        }
        else{
            ViewDown = 0
            statementsOfAccount()
            //StatementOfAccount()
            
        }
    }
    
    
    @IBAction func DownloadStatement(_ sender: UIButton) {
        if accSelectionBtn.tag == 0{
            self.showToast(message: "Please Select Account Number.", controller: self)

        }
        else{
            ViewDown = 1
            statementsOfAccount()
            //StatementOfAccount()
        }
    }
    
    //FIXME: - STATEMENTDETAILDOWNLOAD_API()
    func statementsOfAccount() {
        
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
       
        let urlPath = APIBaseUrlPart1+"/Statement/StatementOfAccount"
        
        let startDate = monDat == 0 ? FromDate : DFromDate
        let endDate = monDat == 0 ?  ToDate : DToDate
        
        let arguments = ["SubModule"  : self.SubModule,
                         "FromNo"     : self.FromNo,
                         "FromDate"   : startDate ,
                         "ToDate"     : endDate,
                         "BranchCode" : BranchCode,
                         "BankKey"    : BankKey,
                         "BankHeader" : BankHeader]
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            
            switch getResult{
                
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    
                    let exMessage = datas.value(forKey: "EXMessage") as? String ?? ""
                    if  let StatementOfAccountDet = datas.value(forKey: "StatementOfAccountDet") as? NSDictionary {
                        
                        let responseMessage = StatementOfAccountDet.value(forKey: "ResponseMessage") as? String ?? ""
                        
                        if statusCode == 0{
                            
                            
                            self.FileName  = StatementOfAccountDet.value(forKey: "FileName") as! String
                            self.FilePath  = StatementOfAccountDet.value(forKey: "FilePath") as! String

                            if let range = self.FilePath.range(of: "\\Statement") {
                                let FileP = self.FilePath[range.upperBound...]
                                print(FileP)
                                self.FilePath = "Statement/" + FileP
                                self.FilePath = self.FilePath.replacingOccurrences(of: "\\", with: "/")
                            }
                            
                            DispatchQueue.main.async {
                                if self.ViewDown == 0 {
                                    self.performSegue(withIdentifier: "viewDetailSegue", sender: self)
                                }
                                else{
                                    self.savePdf()
                                }
                            }
                            
                            
                        }else if statusCode == -1{
                            
                            if responseMessage != ""{
                                if responseMessage == "Invalid Token"{
                                    
                                    print("==============INVALID TOKEN============")
                                    
                                }else{
                                    
                                    DispatchQueue.main.async {
                                        self.present(messages.msg(responseMessage), animated: true, completion: nil)
                                    }
                                    
                                }
                            }
                            
                        }else{
                            
                            if responseMessage != ""{
                                
                                DispatchQueue.main.async {
                                    self.present(messages.msg(responseMessage), animated: true, completion: nil)
                                }
                            }
                            
                        }
                        
                        
                    }else{
                        
                        DispatchQueue.main.async {
                            
                            if exMessage != ""{
                                DispatchQueue.main.async {
                                    self.present(messages.msg(exMessage), animated: true, completion: nil)
                                }
                            }
                            
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
            // activity remove from superview
            self.removeIndicator(showMessagge: false, message: "",activityView: self.activityIndicator, blurview: self.blurView)
        }
        
    }
    
    
    func StatementOfAccount() {
        
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.blurView.isHidden = false
        }
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/Statement/StatementOfAccount")!
        
        let encryptedSubModule   = instanceOfEncryptionPost.encryptUseDES(SubModule, key: "Agentscr")
        let encryptedFromNo     = instanceOfEncryptionPost.encryptUseDES(FromNo, key: "Agentscr")
        var encryptedFromDate  = String()
        var encryptedToDate    = String()
        if monDat == 0 {
            encryptedFromDate  = instanceOfEncryptionPost.encryptUseDES(FromDate, key: "Agentscr")
            encryptedToDate    = instanceOfEncryptionPost.encryptUseDES(ToDate, key: "Agentscr")
        }
        else {
            encryptedFromDate  = instanceOfEncryptionPost.encryptUseDES(DFromDate, key: "Agentscr")
            encryptedToDate    = instanceOfEncryptionPost.encryptUseDES(DToDate, key: "Agentscr")
        }
        let encryptedBranchCode   = instanceOfEncryptionPost.encryptUseDES(BranchCode, key: "Agentscr")
        let jsonDict            = ["SubModule"  : encryptedSubModule,
                                   "FromNo"     : encryptedFromNo,
                                   "FromDate"   : encryptedFromDate ,
                                   "ToDate"     : encryptedToDate,
                                   "BranchCode" : encryptedBranchCode,
                                   "BankKey"    : BankKey,
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
                    print(responseJSONData)
                    let sttsCode = responseJSONData.value(forKey: "StatusCode") as! Int
                    if sttsCode == 0 {
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                        let StatementOfAccountDet  = responseJSONData.value(forKey: "StatementOfAccountDet") as! NSDictionary
                        FileName  = StatementOfAccountDet.value(forKey: "FileName") as! String
                        FilePath  = StatementOfAccountDet.value(forKey: "FilePath") as! String

                        if let range = FilePath.range(of: "\\Statement") {
                            let FileP = FilePath[range.upperBound...]
                            print(FileP)
                            FilePath = "Statement/" + FileP
                            FilePath = FilePath.replacingOccurrences(of: "\\", with: "/")
                        }
                        
                        DispatchQueue.main.async {
                            if self.ViewDown == 0 {
                                self.performSegue(withIdentifier: "viewDetailSegue", sender: self)
                            }
                            else{
                                self.savePdf()
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                        
                        let StatementOfAccountDet  = responseJSONData.value(forKey: "StatementOfAccountDet") as Any
                        if StatementOfAccountDet as? NSDictionary != nil {
                                let StatementOfAccountDet  = responseJSONData.value(forKey: "StatementOfAccountDet") as! NSDictionary
                            let ResponseMessage =  StatementOfAccountDet.value(forKey: "ResponseMessage") as! String

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
    
    
    
    
    
    func savePdf()
    {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.blurView.isHidden = false
        }
        // Create destination URL
        let documentsUrl:URL   =  (FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first as URL?)!
        let urlString = BankIP + "/" + FilePath + "/" + FileName
        let fileURL = URL(string: urlString)
        let fileNames = String((fileURL!.lastPathComponent)) as NSString
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let destinationFileUrl = resourceDocPath.appendingPathComponent("\(fileNames)")
        //Create URL to the source file you want to download
        let request = URLRequest(url:fileURL!)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let tasks   = session.downloadTask(with: request) { (data, response, error) in
            if let tempLocalUrl = data, error == nil
            {

                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode
                {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                if FileManager.default.fileExists(atPath: (destinationFileUrl.path)){
                    try! FileManager.default.removeItem(at: destinationFileUrl)
                }


                do {
                
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    DispatchQueue.main.async {
                        do
                        {
                            
                            //Show UIActivityViewController to save the downloaded file
                            let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                                        includingPropertiesForKeys: nil,
                                                                                        options: .skipsHiddenFiles)
                            
                            for indexx in 0..<contents.count
                            {
                                if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent
                                {
                                    self.openSelectedDocumentFromURL(documentURLString: destinationFileUrl)
                                }
                            }
                            DispatchQueue.main.async { [weak self] in
                                self?.activityIndicator.stopAnimating()
                                self?.blurView.isHidden = true
                            }
                        }
                        catch (let err)
                        {
                            DispatchQueue.main.async { [weak self] in
                                self?.activityIndicator.stopAnimating()
                                self?.blurView.isHidden = true
                            }
                            print("error: \(err)")
                        }
                    }
                }
                catch (let writeError)
                {
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                        self?.blurView.isHidden = true
                    }
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
            }
            else
            {
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    self?.blurView.isHidden = true
                }
                print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
            }
        }
        tasks.resume()
    }
    
    func openSelectedDocumentFromURL(documentURLString: URL)
    {
        DispatchQueue.main.async {
            self.documentController  = UIDocumentInteractionController.init(url: documentURLString)
           
            self.documentController.delegate = self
            //self.documentController.name = documentURLString.lastPathComponent
            self.documentController.presentPreview(animated: true)
            self.documentController.presentOptionsMenu(from: self.view.frame,
                                                       in: self.view,
                                                       animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "viewDetailSegue"
        {
            let searchDet = segue.destination as! StatementResultViewController
                searchDet.fileName   = FileName
                searchDet.filePath = FilePath
        }
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        
        UINavigationBar.appearance().tintColor = UIColor.black


       return self
    }
}
