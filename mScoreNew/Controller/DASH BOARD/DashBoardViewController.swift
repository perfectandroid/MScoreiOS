//
//  DashBoardViewController.swift
//  mScoreNew
//
//  Created by Perfect on 12/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import EventKit
import Charts

class DashBoardViewController: NetworkManagerVC, ChartViewDelegate, UITableViewDataSource, UITableViewDelegate {

    
    
    @IBOutlet weak var dateSettings: UILabel!
    @IBOutlet weak var segSelectionIndex: UISegmentedControl!{
        didSet{
            segSelectionIndex.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        }
    }
    @IBOutlet weak var chartPieView: PieChartView!
    @IBOutlet weak var chartBarView: BarChartView!{
        didSet{
            chartBarView.isHidden = true
        }
    }
    @IBOutlet weak var TAViewHeight: NSLayoutConstraint!{
        didSet{
            TAViewHeight.constant = 0
        }
    }
    @IBOutlet weak var LListViewHeight: NSLayoutConstraint!{
        didSet{
            LListViewHeight.constant = 0
        }
    }
    @IBOutlet weak var liaTableView                 : UITableView!
    @IBOutlet weak var blurView                     : UIView!
    @IBOutlet weak var activityIndicator            : UIActivityIndicatorView!
    
    var items                                           = [NSDictionary]()
    let populationReplacementRate                       = 2.1
    let highIncomeAvg                                   = 1.6
    var fetchedCusDetails        : [Customerdetails]    = []
    var instanceOfEncryptionPost : EncryptionPost       = EncryptionPost()
    var custoID         = Int()
    var TokenNo         = String()
    var DisplayData     = [NSDictionary]()
    var assetsString    = [String]()
    var assetsValue     = [Double]()
    var liaString       = [String]()
    var liaValue        = [Double]()
    var transAnaString  = [String]()
    var transAnaValue   = [Double]()
    var liaTable        = Int()
    
    var segmentSelectedValue = 0 {
        
        didSet{
            
            switch segmentSelectedValue{
            case 0 : //Assets()
                     getChartDetails(segmentSelectedValue, urlPath: APIBaseUrlPart1 + "/AccountSummary/DashBoardAssetsDataDetails")
            case 1 : //Liabilities()
                     getChartDetails(segmentSelectedValue, urlPath: APIBaseUrlPart1 + "/AccountSummary/DashBoardLaibilityDataDetails")
            case 2 : getChartDetails(segmentSelectedValue, urlPath: APIBaseUrlPart1 + "/AccountSummary/DashBoardDataPaymentAndReceiptDetails")
                     //TransactionAnalysis()
                     
            default:
                print("selectedIndex = default")
            }
            
            
        }
    }
    
    
    let colorsList = [UIColor(hexString: "#4FC3F7"),UIColor(hexString: "#F06292"),
                    UIColor(hexString: "#FFD54F"),UIColor(hexString: "#9575CD"),
                    UIColor(hexString: "#81C784"),UIColor(hexString: "#90A4AE"),
                    UIColor(hexString: "#BA68C8"),UIColor(hexString: "#A1887F"),
                    UIColor(hexString: "#E57373"),UIColor(hexString: "#AED581"),
                    UIColor(hexString: "#64B5F6"),UIColor(hexString: "#7986CB"),
                    UIColor(hexString: "#4DB6AC"),UIColor(hexString: "#FFF176"),
                    UIColor(hexString: "#FF8A65"),UIColor(hexString: "#4DD0E1"),
                    UIColor(hexString: "#E0E0E0"),UIColor(hexString: "#FFB74D"),
                    UIColor(hexString: "#B388FF"),UIColor(hexString: "#DCE775")]
    var barGraColors = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                custoID = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
                TokenNo = fetchedCusDetail.value(forKey: "tokenNum") as! String
            }
        }
        catch{}
        
        self.blurView.isHidden = false
        self.activityIndicator.startAnimating()
        self.segmentSelectedValue = 0
        
    }
    
    func customizePieChart(dataPoints: [String], values: [Double]) {
        
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
          let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: values[i] as AnyObject)
          dataEntries.append(dataEntry)
        }
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries)
            pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
            pieChartDataSet.entryLabelColor = UIColor.clear
            pieChartDataSet.label = ""
            
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
            format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
            pieChartData.setValueFormatter(formatter)
        
        // 4. Assign it to the chart’s data

        chartPieView.data = pieChartData
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.blurView.isHidden = true
        }
    }
    func customizeBarChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntryn = BarChartDataEntry(x: Double(i), y: Double(values[i]), data: values)
            dataEntries.append(dataEntryn)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "")
            chartDataSet.colors = barGraColors
        let chartData = BarChartData(dataSet: chartDataSet)
        chartBarView.xAxis.drawGridLinesEnabled = false
        chartBarView.xAxis.drawLabelsEnabled = false
        chartBarView.xAxis.drawAxisLineEnabled = false
        chartBarView.rightAxis.enabled = false
        chartBarView.drawBordersEnabled = false
        chartBarView.rightAxis.axisMinimum = 0
        chartBarView.minOffset = 0.0
        chartBarView.extraBottomOffset = -10
        chartBarView.legend.enabled = false
        chartBarView.data = chartData
        if liaTable == 2 {
            TAViewHeight.constant = 40
            self.view.layer.layoutIfNeeded()
        }
        self.liaTableView.reloadData()
        liaTableView.isHidden = false
        chartBarView.isHidden = false
        
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.blurView.isHidden = true
        }
        switch segmentSelectedValue{
        case 0:
            TAViewHeight.constant = 0
            LListViewHeight.constant = 0
            self.view.layoutIfNeeded()
        case 1:
            TAViewHeight.constant = 0
            LListViewHeight.constant = 250
            self.view.layoutIfNeeded()
        case 2:
            LListViewHeight.constant = 0
            self.view.layoutIfNeeded()
        default:
            print("default")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liaString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "liaListCell", for: indexPath as IndexPath) as!  liaListTableViewCell
        cell.liaL.text = liaString[indexPath.row]
        cell.liaClr.backgroundColor = barGraColors[indexPath.row]
        return cell

    }
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentSelection(_ sender: UISegmentedControl)
    {
        
        
        switch sender.selectedSegmentIndex
        {
            case 0:
                dateSettings.text = ""
                DisplayData = []
                chartBarView.isHidden = true
                chartPieView.isHidden = false
                liaTableView.isHidden = true
                segmentSelectedValue = sender.selectedSegmentIndex
//                Assets()
                
            case 1:
                liaTable        = 1
                dateSettings.text = ""
                DisplayData = []
                
                chartPieView.isHidden = true
                chartBarView.isHidden = true
                liaTableView.isHidden = true
                segmentSelectedValue = sender.selectedSegmentIndex
                //Liabilities()
                
            case 2:
                liaTable        = 2
                dateSettings.text = ""
                DisplayData = []
                
                chartPieView.isHidden = true
                chartBarView.isHidden = true
                liaTableView.isHidden = true
                segmentSelectedValue = sender.selectedSegmentIndex
               
                //TransactionAnalysis()
                

            default:
                break;
        }
    }
    
    
//    func TransactionAnalysis(){
//
//            DispatchQueue.main.async { [weak self] in
//                self?.activityIndicator.startAnimating()
//                self?.blurView.isHidden = false
//            }
//        // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//
//                self?.activityIndicator.stopAnimating()
//                self?.blurView.isHidden = true
//            }
//            return
//        }
//        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/DashBoardDataPaymentAndReceiptDetails")!
////        let encryptedReqMode   = instanceOfEncryptionPost.encryptUseDES("6", key: "Agentscr")
////        let encryptedCusID     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
////        let encryptedTokenNo   = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
////        let encryptedChartType = instanceOfEncryptionPost.encryptUseDES("3", key: "Agentscr")
//
//        let jsonDict           = [ "ReqMode":"6",
//                                   "Token":"\(TokenNo)",
//                                   "FK_Customer":"\(custoID)",
//                                   "ChartType":"3",
//                                   "BankKey" : BankKey,
//                                   "BankHeader" : BankHeader]
//        let jsonData           = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
//        var request            = URLRequest(url: url)
//        request.httpMethod     = "post"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody    = jsonData
//        let session = URLSession(configuration: .default,
//                                 delegate: self,
//                                 delegateQueue: nil)
//        let task = session.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                }
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//                    //FIXME: - TRANS-ANALYSIS-REPORT
//                    if sttsCode==0 {
//                        let detailInfo = responseJSON?.value(forKey: "DashBoardDataPaymentAndReceiptDetailsIfo")! as! NSDictionary
//                        DispatchQueue.main.async { [weak self] in
//                            self?.dateSettings.text = "Date From : \(detailInfo.value(forKey: "StartDate")! as! String) To  \(detailInfo.value(forKey: "EndDate")! as! String)"
//                            self?.DisplayData = detailInfo.value(forKey: "DashBoardDataPaymentDetails")! as! [NSDictionary]
//                            self!.transAnaString = []
//                            self!.transAnaValue = []
//                            self!.barGraColors = []
//                            for DashBoardLabilityDetail in self!.DisplayData {
//                                self!.transAnaString.append(DashBoardLabilityDetail.value(forKey: "TransType") as! String)
//                                self!.transAnaValue.append((DashBoardLabilityDetail.value(forKey: "Amount") as! Double))
//                                if DashBoardLabilityDetail.value(forKey: "TransType") as! String == "P" {
//                                    self!.barGraColors.append(self!.colorsList[0])
//                                }
//                                else{
//                                    self!.barGraColors.append(self!.colorsList[1])
//                                }
//
//                            }
//                            self!.customizeBarChart(dataPoints: self!.transAnaString, values: self!.transAnaValue)
//                        }
//                    }
//                    else {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
//                        }
//                        let DashBoardDataPaymentAndReceiptDetailsIfo  = responseJSON?.value(forKey: "DashBoardDataPaymentAndReceiptDetailsIfo") as Any
//                        if DashBoardDataPaymentAndReceiptDetailsIfo as? NSDictionary != nil {
//                                let DashBoardDataPaymentAndReceiptDetailsIfo  = responseJSON?.value(forKey: "DashBoardDataPaymentAndReceiptDetailsIfo") as! NSDictionary
//                            let ResponseMessage =  DashBoardDataPaymentAndReceiptDetailsIfo.value(forKey: "ResponseMessage") as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
//                            }
//                        }
//                        else {
//                            let EXMessage = responseJSON?.value(forKey: "EXMessage")! as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
//                            }
//                        }
//                    }
//                }
//                catch{
//                    DispatchQueue.main.async { [weak self] in
//                        self?.activityIndicator.stopAnimating()
//                        self?.blurView.isHidden = true
//                    }
//                }
//            }
//            else{
//                DispatchQueue.main.async { [weak self] in
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
//                }
//                print(httpResponse.statusCode)
//            }
//        }
//        task.resume()
//    }
//
//    func Liabilities(){
//
//        DispatchQueue.main.async { [weak self] in
//            self?.activityIndicator.startAnimating()
//            self?.blurView.isHidden = false
//        }
//
//        // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//                self?.activityIndicator.stopAnimating()
//                self?.blurView.isHidden = true
//            }
//            return
//        }
//        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/DashBoardLaibilityDataDetails")!
////        let encryptedReqMode   = instanceOfEncryptionPost.encryptUseDES("6", key: "Agentscr")
////        let encryptedCusID     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
////        let encryptedTokenNo   = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
////        let encryptedChartType = instanceOfEncryptionPost.encryptUseDES("2", key: "Agentscr")
//
//        let jsonDict           = [ "ReqMode":"6",
//                                   "Token":"\(TokenNo)",
//                                   "FK_Customer":"\(custoID)",
//                                   "ChartType":"2",
//                                   "BankKey" : BankKey,
//                                   "BankHeader" : BankHeader]
//        let jsonData           = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
//        var request            = URLRequest(url: url)
//        request.httpMethod     = "post"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody    = jsonData
//        let session = URLSession(configuration: .default,
//                                 delegate: self,
//                                 delegateQueue: nil)
//        let task = session.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                }
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//
//                    if sttsCode==0 {
//                        let detailInfo = responseJSON?.value(forKey: "DashBoardDataLaibilityDetailsIfo")! as! NSDictionary
//                        DispatchQueue.main.async { [weak self] in
//                            self?.dateSettings.text = "Date From : \(detailInfo.value(forKey: "StartDate")! as! String) To  \(detailInfo.value(forKey: "EndDate")! as! String)"
//
//                            self?.DisplayData = detailInfo.value(forKey: "DashBoardLabilityDetails")! as! [NSDictionary]
//
//
//                            self!.liaString = []
//                            self!.liaValue = []
//
//                            self!.barGraColors = []
//                            for DashBoardLabilityDetail in self!.DisplayData {
//                                self!.liaString.append(DashBoardLabilityDetail.value(forKey: "Account") as! String)
//                                self!.liaValue.append((DashBoardLabilityDetail.value(forKey: "Balance") as! Double))
//
//                            }
//
//                            self!.barGraColors = self!.colorsOfCharts(numbersOfColor: self!.DisplayData.count)
//                            self!.customizeBarChart(dataPoints: self!.liaString, values: self!.liaValue)
//
//                        }
//                    }
//                    else {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
//                        }
//                        let DashBoardDataLaibilityDetailsIfo  = responseJSON?.value(forKey: "DashBoardDataLaibilityDetailsIfo") as Any
//                        if DashBoardDataLaibilityDetailsIfo as? NSDictionary != nil {
//                                let DashBoardDataLaibilityDetailsIfo  = responseJSON?.value(forKey: "DashBoardDataLaibilityDetailsIfo") as! NSDictionary
//                            let ResponseMessage =  DashBoardDataLaibilityDetailsIfo.value(forKey: "ResponseMessage") as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
//                            }
//                        }
//                        else {
//                            let EXMessage = responseJSON?.value(forKey: "EXMessage")! as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
//                            }
//                        }
//                    }
//                }
//                catch{
//
//                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
//                        }
//                }
//            }
//            else{
//                DispatchQueue.main.async { [weak self] in
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
//                }
//                print(httpResponse.statusCode)
//            }
//        }
//        task.resume()
//    }
//
    func displaySettingsDate(start:String,end:String){
        self.dateSettings.text = "Date From : \(start) To  \(end)"
    }
    
    //FIXME: - GET_CHART_ASSET_LIABILITY_TRANS-ANALYSIS_API()
    func getChartDetails(_ selected_Index: Int,urlPath: String)  {
        
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let arguments = ["ReqMode":"6",
                         "Token":TokenNo,
                         "FK_Customer":"\(custoID)",
                         "ChartType":"\(selected_Index + 1)",
                         "BankKey" : BankKey,
                         "BankHeader" : BankHeader]
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            
            switch getResult{
            case.success(let datas):
                print(datas)
                
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    var passMessage = ""
                    
                    let exMessage = datas.value(forKey: self.EXMessage) as? String ?? ""
                    
                    
                    
                        
                        switch selected_Index{
                        //FIXME: - ASSET-REPORT
                        case 0:
                            let DashBoardDataAssetsDetailsIfo = datas.value(forKey: "DashBoardDataAssetsDetailsIfo") as? NSDictionary ?? [:]
                            let responseMessage = DashBoardDataAssetsDetailsIfo.value(forKey: self.ResponseMessage) as? String ?? ""
                            
                            if statusCode == 0{
                            
                            DispatchQueue.main.async {
                                let info = DashBoardDataAssetsDetailsIfo
                                let startDate = info.value(forKey: "StartDate") as? String ?? ""
                                let endDate = info.value(forKey: "EndDate") as? String ?? ""
                                self.displaySettingsDate(start: startDate, end: endDate)
                                self.DisplayData = info.value(forKey: "DashBoardAssestDetails") as? [NSDictionary] ?? []
                                self.assetsString = []
                                self.assetsString = self.DisplayData.map{ $0.value(forKey: "Account") as? String ?? "" }
                                self.assetsValue = []
                                self.assetsValue = self.DisplayData.map{ $0.value(forKey: "Balance") as? Double ?? 0.00 }
                                self.customizePieChart(dataPoints: self.assetsString, values: self.assetsValue)
                                if self.DisplayData.count == 0{
                                    passMessage = responseMessage
                                    self.present(messages.msg(passMessage), animated: true,completion: nil)
                                }else{
                                    if exMessage  != ""{
                                        self.present(messages.msg(exMessage), animated: true,completion: nil)
                                    }
                                }
                             }
                            }else{
                                
                                passMessage = responseMessage
                                
                             let errorString =    exMessage == "" ? passMessage : exMessage
                                
                                DispatchQueue.main.async {
                                    if errorString == "Invalid Token"{
                                      print("==============INVALID TOKEN============")
                                        SessionManager.shared.logOut {
                                            print("====logout 1===")
                                            //self.present(messages.msg(exMessage), animated: true,completion: nil)
                                           // self.present(messages.msg(sessionExpiredMsg), animated: true) {
                                               
                                                SessionManager.shared.sessionExpiredCall()
                                                return
                                            //}
                                        }
                                        
                                    }
                                    self.present(messages.msg(errorString), animated: true,completion: nil)
                                    
                                }
                                
                            }
                            
                        //FIXME: - LIABILITY-REPORT
                        case 1:
                            
                            let DashBoardDataLaibilityDetailsIfo = datas.value(forKey: "DashBoardDataLaibilityDetailsIfo")! as? NSDictionary ?? [:]
                            let responseMessage = DashBoardDataLaibilityDetailsIfo.value(forKey: self.ResponseMessage) as? String ?? ""
                            
                            
                           if statusCode == 0{
                               
                               
                            DispatchQueue.main.async {
                                let info = DashBoardDataLaibilityDetailsIfo
                                let startDate = info.value(forKey: "StartDate") as? String ?? ""
                                let endDate = info.value(forKey: "EndDate") as? String ?? ""
                                self.displaySettingsDate(start: startDate, end: endDate)
                                self.DisplayData = info.value(forKey: "DashBoardLabilityDetails") as? [NSDictionary] ?? []
                                
                                self.liaString = []
                                self.barGraColors = []
                                self.liaString = self.DisplayData.map{ $0.value(forKey: "Account") as? String ?? "" }
                                self.liaValue = []
                                self.liaValue = self.DisplayData.map{ $0.value(forKey: "Balance") as? Double ?? 0.00 }
                                
                                
                                
                                
                                self.barGraColors = self.colorsOfCharts(numbersOfColor: self.DisplayData.count)
                                
                                self.customizeBarChart(dataPoints: self.liaString, values: self.liaValue)
                                
                                if self.DisplayData.count == 0{
                                    passMessage = responseMessage
                                    self.present(messages.msg(passMessage), animated: true,completion: nil)
                                }else{
                                    if exMessage  != ""{
                                        self.present(messages.msg(exMessage), animated: true,completion: nil)
                                    }
                                }

                                
                            }
                        }else{
                            
                            passMessage = responseMessage
                            
                         let errorString =    exMessage == "" ? passMessage : exMessage
                            
                            DispatchQueue.main.async {
                                if errorString == "Invalid Token"{
                                  print("==============INVALID TOKEN============")
                                    SessionManager.shared.logOut {
                                        print("====logout 2===")
                                        SessionManager.shared.sessionExpiredCall()
                                        return
                                    }
                                   
                                }
                                self.present(messages.msg(errorString), animated: true,completion: nil)
                            }
                            
                        }
                        //FIXME: - TRANS-REPORT
                        case 2:
                            
                            let DashBoardDataPaymentAndReceiptDetailsIfo = datas.value(forKey: "DashBoardDataPaymentAndReceiptDetailsIfo") as? NSDictionary ?? [:]
                            let responseMessage = DashBoardDataPaymentAndReceiptDetailsIfo.value(forKey: self.ResponseMessage) as? String ?? ""
                            
                            if statusCode == 0{
                                
                            DispatchQueue.main.async {
                                
                                let info = DashBoardDataPaymentAndReceiptDetailsIfo
                                let startDate = info.value(forKey: "StartDate") as? String ?? ""
                                let endDate = info.value(forKey: "EndDate") as? String ?? ""
                                self.displaySettingsDate(start: startDate, end: endDate)
                                self.DisplayData = info.value(forKey: "DashBoardDataPaymentDetails") as? [NSDictionary] ?? []
                                
                                self.transAnaString = []
                                self.transAnaString = self.DisplayData.map{ $0.value(forKey: "TransType") as? String ?? ""
                                }
                                
                                self.transAnaValue = []
                                self.transAnaValue = self.DisplayData.map{ $0.value(forKey: "Amount") as? Double ?? 0.00 }
                                
                                self.barGraColors = []
                                for colorItem in self.DisplayData{
                                    let transtype = colorItem.value(forKey: "TransType") as? String ?? ""
                                    let color = transtype == "P" ? self.colorsList[0] : self.colorsList[1]
                                    self.barGraColors.append(color)
                                    
                                }
                                
                                self.customizeBarChart(dataPoints: self.transAnaString, values: self.transAnaValue)
                                
                                if self.DisplayData.count == 0{
                                    passMessage = responseMessage
                                    self.present(messages.msg(passMessage), animated: true,completion: nil)
                                }else{
                                    if exMessage  != ""{
                                        self.present(messages.msg(exMessage), animated: true,completion: nil)
                                    }
                                }
                                
                            }
                }else{
                    
                    passMessage = responseMessage
                    
                 let errorString =    exMessage == "" ? passMessage : exMessage
                    
                    DispatchQueue.main.async {
                        if errorString == "Invalid Token"{
                          print("==============INVALID TOKEN============")
                            SessionManager.shared.logOut {
                                print("====logout 3===")
                                SessionManager.shared.sessionExpiredCall()
                                return
                            }
                            
                        }
                        self.present(messages.msg(exMessage), animated: true,completion: nil)
                    }
                    
                }
                            
                        default:
                            print("dashboard response case")
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
    
//    func Assets(){
//        // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//                self?.blurView.isHidden = true
//                self?.activityIndicator.stopAnimating()
//            }
//            return
//        }
//        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/DashBoardAssetsDataDetails")!
////        let encryptedReqMode   = instanceOfEncryptionPost.encryptUseDES("6", key: "Agentscr")
////        let encryptedCusID     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
////        let encryptedTokenNo   = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
////        let encryptedChartType = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
//
//        let jsonDict           = [ "ReqMode":"6",
//                                    "Token":TokenNo,
//                                    "FK_Customer":"\(custoID)",
//                                    "ChartType":"1",
//                                    "BankKey" : BankKey,
//                                    "BankHeader" : BankHeader]
//        let jsonData           = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
//        var request            = URLRequest(url: url)
//        request.httpMethod     = "post"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody    = jsonData
//        let session = URLSession(configuration: .default,
//                                 delegate: self,
//                                 delegateQueue: nil)
//        let task = session.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                DispatchQueue.main.async { [weak self] in
//                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                }
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//                    if sttsCode==0 {
//                        let detailInfo = responseJSON?.value(forKey: "DashBoardDataAssetsDetailsIfo")! as! NSDictionary
//                        DispatchQueue.main.async { [weak self] in
//                            self?.dateSettings.text = "Date From : \(detailInfo.value(forKey: "StartDate")! as! String) To  \(detailInfo.value(forKey: "EndDate")! as! String)"
//                            self?.DisplayData = detailInfo.value(forKey: "DashBoardAssestDetails")! as! [NSDictionary]
//                            for DashBoardLabilityDetail in self!.DisplayData {
//                                self!.assetsString.append(DashBoardLabilityDetail.value(forKey: "Account") as! String)
//                                self!.assetsValue.append((DashBoardLabilityDetail.value(forKey: "Balance") as! Double))
//                            }
//                            self!.customizePieChart(dataPoints: self!.assetsString, values: self!.assetsValue)
//                        }
//                    }
//                    else {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
//                        }
//                        let DashBoardDataAssetsDetailsIfo  = responseJSON?.value(forKey: "DashBoardDataAssetsDetailsIfo") as Any
//                        if DashBoardDataAssetsDetailsIfo as? NSDictionary != nil {
//                                let DashBoardDataAssetsDetailsIfo  = responseJSON?.value(forKey: "DashBoardDataAssetsDetailsIfo") as! NSDictionary
//                            let ResponseMessage =  DashBoardDataAssetsDetailsIfo.value(forKey: "ResponseMessage") as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
//                            }
//                        }
//                        else {
//                            let EXMessage = responseJSON?.value(forKey: "EXMessage")! as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
//                            }
//                        }
//                    }
//                }
//                catch{
//                    DispatchQueue.main.async { [weak self] in
//                        self?.activityIndicator.stopAnimating()
//                        self?.blurView.isHidden = true
//                    }
//                }
//            }
//            else{
//                DispatchQueue.main.async { [weak self] in
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
//                }
//                print(httpResponse.statusCode)
//            }
//        }
//        task.resume()
//    }
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
      var colors: [UIColor] = []
      for i in 0..<numbersOfColor {
        colors.append(colorsList[i])
      }
      return colors
    }
}
