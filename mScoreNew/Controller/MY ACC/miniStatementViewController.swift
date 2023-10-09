//
//  miniStatementViewController.swift
//  mScoreNew
//
//  Created by Perfect on 13/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit
import Charts

class miniStatementViewController: UIViewController, URLSessionDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout , ChartViewDelegate, UIDocumentInteractionControllerDelegate {
      
    @IBOutlet weak var myAccNo                  : UILabel!
    @IBOutlet weak var myBalanceHdr             : UILabel!
    @IBOutlet weak var myBalanceL               : UILabel!
    @IBOutlet weak var TransactionButton        : UIButton!
    @IBOutlet weak var AnalysisButton           : UIButton!
    @IBOutlet weak var HdrCollection            : UICollectionView!
    @IBOutlet weak var transactionTable         : UITableView!
    @IBOutlet weak var AnalysisView: UIView!{
        didSet {
            AnalysisView.isHidden = true
        }
    }
    @IBOutlet weak var TransactionView          : UIView!{
        didSet {
            TransactionView.isHidden = true
        }
    }
    @IBOutlet weak var chartBarView             : BarChartView!
    @IBOutlet weak var blurView                 : UIView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    
    var documentController                  = UIDocumentInteractionController()
    var custoID                             = Int()
    var TokenNo                             = String()
    var CustomerLoanAndDepositDetail        = NSDictionary()
    var DepositLoanSele                     = Int()
    var actvClsSele                         = Int()
//    var HdrClick                            = ["View Statement","Download Statement"]
//    var HdrClickImg                         = [#imageLiteral(resourceName: "instruction_white"),#imageLiteral(resourceName: "ic_download")]

    var HdrClick                            = ["Download Statement"]
    var HdrClickImg                         = [#imageLiteral(resourceName: "instruction_white")]
    var LoanMiniStatementList               = [NSDictionary]()
    var DepositMiniStatementList            = [NSDictionary]()
    var NoOfDays                            = String()
    var sectio                              = Int()
    var SubModule                           = String()
    var BranchCode                          = String()
    var FromNo                              = String()
    var FileName  = String()
    var FilePath  = String()
    var monDat = Int()

    var FromDate = String()
    var ToDate = String()
    var DFromDate = String()
    var DToDate = String()
    
    
    var AnalysisString = [String]()
    var AnalysisValue = [Double]()
    
    var transAnalyErrorMsg = String()
    let colorsList = [#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)]
    var barGraColors = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if DepositLoanSele == 1 {
            myBalanceHdr.text = "Balance"
        }
        else{
            myBalanceHdr.text = "Loan Amount"
        }
        myAccNo.text = (CustomerLoanAndDepositDetail.value(forKey: "AccountNumber") as! String)
        myBalanceL.text = (CustomerLoanAndDepositDetail.value(forKey: "Balance") as! Double).currencyIN
        
        SubModule  = (CustomerLoanAndDepositDetail.value(forKey: "SubModule") as! String)
        FromNo     = (CustomerLoanAndDepositDetail.value(forKey: "AccountNumber") as! String)
        
        do{
            let fetchedAccDetails = try coredatafunction.fetchObjectofAcc()
            for fetchedAccDetail in fetchedAccDetails
            {
                if (CustomerLoanAndDepositDetail.value(forKey: "AccountNumber") as! String) == (fetchedAccDetail.value(forKey: "accNum") as! String) + " (" + (fetchedAccDetail.value(forKey: "accTypeShort") as! String) + ")" {
                    self.BranchCode     = (fetchedAccDetail.value(forKey: "codeOfBranch") as? String)!
                }
                
            }
        }
        catch{
        }
        TransactionButton.buttonUnderLineColor(UIColor.blue)
        AnalysisButton.buttonUnderLineColor(UIColor.white)
        TransactionButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        AnalysisButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        do
        {
            let fetchedSettings = try coredatafunction.fetchObjectofSettings()
            for fetchedSetting in fetchedSettings
            {
                NoOfDays = (fetchedSetting.value(forKey: "days") as? String)!
            }
        }
        catch{
        }
        if DepositLoanSele == 1 {
            PassBookAccountStatement()
        }
        else{
            LoanMiniStatement()
        }
    }
    
    override func viewDidLayoutSubviews() {
        transactionTable.frame = CGRect(x: transactionTable.frame.origin.x, y: transactionTable.frame.origin.y, width: transactionTable.frame.size.width, height: transactionTable.contentSize.height)
        transactionTable.reloadData()
    }
    
    func PassBookAccountStatement() {
        // network reachability checking
        if Reachability.isConnectedToNetwork() {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.activityIndicator.startAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/PassBookAccountStatement")!
        
//        let encryptedReqMode    = instanceOfEncryptionPost.encryptUseDES("28", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedSubModule    = instanceOfEncryptionPost.encryptUseDES((CustomerLoanAndDepositDetail.value(forKey: "SubModule") as! String), key: "Agentscr")
//        let encryptedFK_Account     = instanceOfEncryptionPost.encryptUseDES(String(CustomerLoanAndDepositDetail.value(forKey: "FK_Account") as! Int64), key: "Agentscr")
//        let encryptedNoOfDays   = instanceOfEncryptionPost.encryptUseDES(NoOfDays, key: "Agentscr")
        
        let subModules = CustomerLoanAndDepositDetail.value(forKey: "SubModule") as? String ?? ""
        
        let FK_Account  = CustomerLoanAndDepositDetail.value(forKey: "FK_Account") as! NSNumber

        let jsonDict            = ["ReqMode"    : "28",
                                   "Token"      : "\(TokenNo)",
                                   "FK_Account" : "\(FK_Account)",
                                   "SubModule"  : subModules,
                                   "NoOfDays"   : "\(NoOfDays)",
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
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let PassBookAccountStatement  = responseJSONData.value(forKey: "PassBookAccountStatement") as! NSDictionary
                        DepositMiniStatementList = PassBookAccountStatement.value(forKey: "PassBookAccountStatementList") as! [NSDictionary]
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.TransactionView.isHidden = false
                            self!.transactionTable.reloadData()
                            
                            for DepositMiniStatement in self!.DepositMiniStatementList {
                                self!.AnalysisString.append(DepositMiniStatement.value(forKey: "TransType") as! String + "r")
                                self!.AnalysisValue.append((DepositMiniStatement.value(forKey: "Amount") as! Double))
                                if DepositMiniStatement.value(forKey: "TransType") as! String == "D" {
                                    self!.barGraColors.append(self!.colorsList[0])
                                }
                                else{
                                    self!.barGraColors.append(self!.colorsList[1])
                                }
                            }
                            self!.customizeBarChart(dataPoints: self!.AnalysisString, values: self!.AnalysisValue)
                        }
                    }
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.TransactionView.isHidden = true
                        }
                        let PassBookAccountStatement  = responseJSONData.value(forKey: "PassBookAccountStatement") as Any
                        if PassBookAccountStatement as? NSDictionary != nil {
                                let PassBookAccountStatemen  = responseJSONData.value(forKey: "PassBookAccountStatement") as! NSDictionary
                            let ResponseMessage =  PassBookAccountStatemen.value(forKey: "ResponseMessage") as! String
                            transAnalyErrorMsg = ResponseMessage
                            DispatchQueue.main.async { [weak self] in
                                self?.present(messages.msg(transAnalyErrorMsg), animated: true,completion: nil)
                            }
                        }
                        else {
                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String
                            transAnalyErrorMsg = EXMessage
                            DispatchQueue.main.async { [weak self] in
                                self?.present(messages.msg(transAnalyErrorMsg), animated: true,completion: nil)
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
                    self?.TransactionView.isHidden = true
                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
                }
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    func LoanMiniStatement() {
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/LoanMiniStatement")!
        
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("16", key: "Agentscr")
//        let encryptedSubModule    = instanceOfEncryptionPost.encryptUseDES((CustomerLoanAndDepositDetail.value(forKey: "SubModule") as! String), key: "Agentscr")
//        let encryptedFK_Account     = instanceOfEncryptionPost.encryptUseDES(String(CustomerLoanAndDepositDetail.value(forKey: "FK_Account") as! Int64), key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
        
        let subModules = CustomerLoanAndDepositDetail.value(forKey: "SubModule") as? String ?? ""
        
        let FK_Account  = CustomerLoanAndDepositDetail.value(forKey: "FK_Account") as! NSNumber
        
        let jsonDict            = ["ReqMode" : "16",
                                   "SubModule" : subModules,
                                   "FK_Account" : "\(FK_Account)" ,
                                   "Token" : "\(TokenNo)",
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
                        let LoanMiniStatement  = responseJSONData.value(forKey: "LoanMiniStatement") as! NSDictionary
                        LoanMiniStatementList = LoanMiniStatement.value(forKey: "LoanMiniStatementList") as! [NSDictionary]

                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.TransactionView.isHidden = false
                            self!.transactionTable.reloadData()
                            
                            for LoanMiniStatementLi in self!.LoanMiniStatementList {
                                self!.AnalysisString.append(LoanMiniStatementLi.value(forKey: "TransType") as! String + "r")
                                self!.AnalysisValue.append((LoanMiniStatementLi.value(forKey: "Amount") as! Double))
                                if LoanMiniStatementLi.value(forKey: "TransType") as! String == "D" {
                                    self!.barGraColors.append(self!.colorsList[0])
                                }
                                else{
                                    self!.barGraColors.append(self!.colorsList[1])
                                }
                            }

                            self!.customizeBarChart(dataPoints: self!.AnalysisString, values: self!.AnalysisValue)
                        }
                    }
                
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.TransactionView.isHidden = true
                        }
                        let LoanMiniStatement  = responseJSONData.value(forKey: "LoanMiniStatement") as Any
                        if LoanMiniStatement as? NSDictionary != nil {
                            let LoanMiniStatement  = responseJSONData.value(forKey: "LoanMiniStatement") as! NSDictionary
                            let ResponseMessage =  LoanMiniStatement.value(forKey: "ResponseMessage") as! String
                            transAnalyErrorMsg = ResponseMessage

                            DispatchQueue.main.async { [weak self] in
                                self?.present(messages.msg(transAnalyErrorMsg), animated: true,completion: nil)
                            }
                        }
                        else {
                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String
                            transAnalyErrorMsg = EXMessage
                            DispatchQueue.main.async { [weak self] in
                                self?.present(messages.msg(transAnalyErrorMsg), animated: true,completion: nil)
                            }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "miniStatementHdrCell", for: indexPath as IndexPath) as! accDetailsCollectionViewCell
        cell.secImg.image = HdrClickImg[indexPath.row]
        cell.secL.text = HdrClick[indexPath.row]

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "miniStatementHdrCell", for: indexPath as IndexPath) as! accDetailsCollectionViewCell
//        if indexPath.row == 0 {
//            sectio = 0
//            vdPopup()
//        }
//        else if indexPath.row == 1 {
            sectio = 1
            vdPopup()
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var noOfRows = 10
    
        if DepositLoanSele == 1 {
            if DepositMiniStatementList.count < 10 {
                noOfRows = DepositMiniStatementList.count
            }
        }
        else{
            if LoanMiniStatementList.count < 10 {
                noOfRows = LoanMiniStatementList.count
            }
        }
        return noOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath as IndexPath) as!  TransactionTable
        
        if DepositLoanSele == 1 {
            cell.cd.text = Date().formattedDateFromString(dateString: DepositMiniStatementList[indexPath.row].value(forKey: "TransDate") as! String, ipFormatter: "MM/dd/yyyy HH:mm:ss a", opFormatter: "dd MMM yyyy")
            
            if DepositMiniStatementList[indexPath.row].value(forKey: "TransType") as! String == "D" {
                cell.amount.textColor = colorsList[0]
                cell.amount.text = (DepositMiniStatementList[indexPath.row].value(forKey: "Amount") as! Double).currencyIN + " Dr"
            }
            else {
                cell.amount.textColor = colorsList[1]
                cell.amount.text = (DepositMiniStatementList[indexPath.row].value(forKey: "Amount") as! Double).currencyIN + " Cr"
            }
                cell.narration.text =  DepositMiniStatementList[indexPath.row].value(forKey: "Narration") as! String + "\n \n"
            
        }
        else{
            cell.cd.text = Date().formattedDateFromString(dateString: LoanMiniStatementList[indexPath.row].value(forKey: "TransDate") as! String, ipFormatter: "MM/dd/yyyy HH:mm:ss a", opFormatter: "dd MMM yyyy")
            
            if LoanMiniStatementList[indexPath.row].value(forKey: "TransType") as! String == "D" {
                cell.amount.textColor = colorsList[0]
                cell.amount.text = (LoanMiniStatementList[indexPath.row].value(forKey: "Amount") as! Double).currencyIN + " Dr"
            }
            else {
                cell.amount.textColor = colorsList[1]
                cell.amount.text = (LoanMiniStatementList[indexPath.row].value(forKey: "Amount") as! Double).currencyIN + " Cr"
            }
                cell.narration.text =  LoanMiniStatementList[indexPath.row].value(forKey: "Narration") as! String + "\n \n"
        }
        return cell
    }

    
    @IBAction func Transaction(_ sender: UIButton) {
        if DepositLoanSele == 1 {
            if DepositMiniStatementList.count != 0 {
                TransactionView.isHidden = false
            }
            else{
                TransactionView.isHidden = true
                DispatchQueue.main.async { [weak self] in
                    self?.present(messages.msg(self!.transAnalyErrorMsg), animated: true,completion: nil)
                }
            }
        }
        else {
            if LoanMiniStatementList.count != 0 {
                TransactionView.isHidden = false
            }
            else{
                TransactionView.isHidden = true
                DispatchQueue.main.async { [weak self] in
                    self?.present(messages.msg(self!.transAnalyErrorMsg), animated: true,completion: nil)
                }
            }
        }
        TransactionButton.buttonUnderLineColor(UIColor.blue)
        AnalysisButton.buttonUnderLineColor(UIColor.white)
        TransactionButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        AnalysisButton.setTitleColor(UIColor.black, for: UIControl.State.normal)

    }
    
    @IBAction func Analysis(_ sender: UIButton) {
        AnalysisButton.buttonUnderLineColor(UIColor.blue)
        TransactionButton.buttonUnderLineColor(UIColor.white)
        AnalysisButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        TransactionButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        TransactionView.isHidden = true
        if DepositLoanSele == 1 {
            if DepositMiniStatementList.count != 0 {
                AnalysisView.isHidden = false
            }
            else{
                AnalysisView.isHidden = true
                DispatchQueue.main.async { [weak self] in
                    self?.present(messages.msg(self!.transAnalyErrorMsg), animated: true,completion: nil)
                }
            }
        }
        else {
            if LoanMiniStatementList.count != 0 {
                AnalysisView.isHidden = false
            }
            else{
                AnalysisView.isHidden = true
                DispatchQueue.main.async { [weak self] in
                    self?.present(messages.msg(self!.transAnalyErrorMsg), animated: true,completion: nil)
                }
            }
        }
    }
    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
        
    func vdPopup(){
        let customVDAlert = self.storyboard?.instantiateViewController(withIdentifier: "vdAlert") as! VDAlertViewController
        customVDAlert.providesPresentationContextTransitionStyle = true
        customVDAlert.definesPresentationContext = true
        customVDAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customVDAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customVDAlert.delegate = self
        customVDAlert.TokenNo = TokenNo
        customVDAlert.customerId = String(custoID)
//        if sectio == 0 {
//            customVDAlert.hdrLbltxt = "View"
//        }
//        else{
            customVDAlert.hdrLbltxt = "Download"
//        }
        self.present(customVDAlert, animated: true, completion: nil)
    }
    
    func customizeBarChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntryn = BarChartDataEntry(x: Double(i), y: Double(values[i]), data: values)
            dataEntries.append(dataEntryn)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "")
            chartDataSet.colors = barGraColors
//            chartDataSet.stackLabels = dataPoints
        let chartData = BarChartData(dataSet: chartDataSet)
        chartBarView.xAxis.drawGridLinesEnabled = false
        chartBarView.xAxis.drawLabelsEnabled = false
        chartBarView.xAxis.drawAxisLineEnabled = false
        chartBarView.rightAxis.enabled = false
        chartBarView.drawBordersEnabled = false
        chartBarView.rightAxis.axisMinimum = 0
        chartBarView.legend.enabled = false
        chartBarView.data = chartData
        AnalysisView.isHidden = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "viewSegue"
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

extension miniStatementViewController: VDAlertDelegate{

    func refresh(_ monDat : Int,_ FromDate: String, _ ToDate: String, _ DFromDate: String, _ DToDate: String) {
        self.ToDate = ToDate
        self.FromDate = FromDate
        self.DFromDate = DFromDate
        self.DToDate = DToDate
    }
        
    func VDButtonTapped() {
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
        
        let encryptedSubModule   = SubModule
        let encryptedFromNo     = FromNo
        var encryptedFromDate  = String()
        var encryptedToDate    = String()
        if monDat == 0 {
            encryptedFromDate  = FromDate
            encryptedToDate    = ToDate
        }
        else {
            encryptedFromDate  = DFromDate
            encryptedToDate    = DToDate
        }
        let encryptedBranchCode   = BranchCode
        let jsonDict            = ["SubModule" : encryptedSubModule,
                                   "FromNo" : encryptedFromNo,
                                   "FromDate" : encryptedFromDate ,
                                   "ToDate" : encryptedToDate,
                                   "BranchCode": encryptedBranchCode,
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
                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
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
                        
//                        if let range = FilePath.range(of: "\\Mscore") {
//                            let FileP = FilePath[range.upperBound...]
//                            FilePath = String(FileP)
//                            FilePath = FilePath.replacingOccurrences(of: "\\", with: "/")
//                        }
                        
                        DispatchQueue.main.async { [weak self] in
//                            if self!.sectio == 0  {
////                                self!.dismiss(animated: true, completion: nil)
//                                self!.performSegue(withIdentifier: "viewSegue", sender: self)
//                            }
//                            else{
                                self?.savePdf()
//                            }
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
    func cancelButtonTapped() {
        print("cancel")
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
        
        let filePath = FilePath.replacingOccurrences(of: "/", with: "")
        let urlString = BankIP + "/" + filePath + "/" + FileName
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
                if FileManager.default.fileExists(atPath: (destinationFileUrl.path)) {
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
            self.documentController          = UIDocumentInteractionController(url: documentURLString)
            self.documentController.delegate = self
            self.documentController.presentPreview(animated: true)

            self.documentController.presentOptionsMenu(from: self.view.frame,
                                                       in: self.view,
                                                       animated: true)
        }
    }
    
}
