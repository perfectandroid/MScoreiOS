//
//  FundTransferStatusViewController.swift
//  mScoreNew
//
//  Created by Perfect on 16/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit
import DropDown

class FundTransferStatusViewController: NetworkManagerVC , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var blurView                 : UIView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    @IBOutlet weak var TodaysStatusBtn: UIButton!{
        didSet{
            TodaysStatusBtn.buttonUnderLineColor(underLineGreen)
            TodaysStatusBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        }
    }
    @IBOutlet weak var PreviousStatusBtn: UIButton! {
        didSet{
            PreviousStatusBtn.buttonUnderLineColor(UIColor.white)
            PreviousStatusBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
    }
    @IBOutlet weak var hdrTable: UITableView!
    @IBOutlet weak var hdrTblHt: NSLayoutConstraint!
    @IBOutlet weak var statusTable: UITableView!
    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()
    var OtherFundTransferHistoryList = [NSDictionary]()
    var OtherFundTransferHistoryDetails = NSDictionary()
    var hdrLabels = ["Status :"]
    var statusDrop  = ["ALL", "SUCCESS", "WAITING", "REFUNDED", "FAILED"]
    var weekDrop  = ["2", "4", "6", "8", "10"]
    var staDrop     = DropDown()
    lazy var statusDropDowns: [DropDown] = { return[self.staDrop] } ()
    var wkDrop     = DropDown()
    lazy var wkDropDowns: [DropDown] = { return[self.wkDrop] } ()
    var customerId                          = String()
    var TokenNo                             = String()
    var SubMode                             = String()
    var BranchCode = "1"
    var TransType = "1"
    var TrnsDate = Date().currentDate(format: "dd/MM/yyy")
    var Status = "0"
    private var parserViewModel:ParserViewModel = ParserViewModel()
    let group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusTable.isHidden = true
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async { [weak self] in
            self!.activityIndicator.startAnimating()
            self!.blurView.isHidden = false
        }
        OtherFundTransferHistory()
        //otherFundTranserHistoryApi()
    }
    
    
    //FIXME: - ==== OtherFundTransferHistory() ====()
    func OtherFundTransferHistory(){
        
        // network reachability checking
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = "/AccountSummary/OtherFundTransferHistory"
        let arguments = ["ReqMode":"22",
                         "Token"          : TokenNo,
                         "FK_Customer"    : "\(customerId)" ,
                         "BranchCode"     : BranchCode,
                         "TransType"      : TransType,
                         "TrnsDate"       : TrnsDate,
                         "SubMode"        : SubMode ,
                         "Status"         : Status,
                         "BankKey"        : BankKey,
                         "BankHeader"     : BankHeader]
        
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguments) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas,modelKey:"OtherFundTransferHistory")
                    let exmSg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exmSg, vc: self) { status in
                        
                        let historyInfoList = modelInfo.value(forKey: "OtherFundTransferHistoryList") as? [NSDictionary] ?? []
                        self.OtherFundTransferHistoryList = []
                        
                        self.OtherFundTransferHistoryList.append(contentsOf: historyInfoList.map{ $0 })
                        
                    }
                    
                    self.group.leave()
                }
                
                
               
            case.failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
                self.group.leave()
            }
           
            
            DispatchQueue.global(qos: .default).async {
                self.group.wait()
                
                DispatchQueue.main.async {
                    print("successfully get result")
                    
                    self.removeIndicator(showMessagge: false, message: "",activityView: self.activityIndicator, blurview: self.blurView)
                    
                    self.updateUIDetails(count: self.OtherFundTransferHistoryList.count)
                    
                }
            }
            
        }
        
    }
    
    
    //FIXME: - ==== updateUIDetails() ====()
    fileprivate func updateUIDetails(count:Int){
        
        if count > 0{
            
            self.statusTable.isHidden = false
            self.statusTable.reloadData()
            
        }else{
            
            self.statusTable.isHidden = true
            
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
//    func otherFundTranserHistoryApi() {
//        // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
//            DispatchQueue.main.async { [weak self] in
//                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
//                self?.activityIndicator.startAnimating()
//                self?.blurView.isHidden = true
//            }
//            return
//        }
//        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/OtherFundTransferHistory")!
//        let encryptedReqMode        = instanceOfEncryptionPost.encryptUseDES("22", key: "Agentscr")
//        let encryptedTocken         = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum         = instanceOfEncryptionPost.encryptUseDES(String(customerId), key: "Agentscr")
//        let encryptedBranchCode     = instanceOfEncryptionPost.encryptUseDES(BranchCode, key: "Agentscr")
//        let encryptedTransType      = instanceOfEncryptionPost.encryptUseDES(TransType, key: "Agentscr")
//        let encryptedTrnsDate       = instanceOfEncryptionPost.encryptUseDES(TrnsDate, key: "Agentscr")
//        let encryptedSubMode        = instanceOfEncryptionPost.encryptUseDES(SubMode, key: "Agentscr")
//        let encryptedStatus         = instanceOfEncryptionPost.encryptUseDES(Status, key: "Agentscr")
//        let jsonDict            = ["ReqMode"        : encryptedReqMode,
//                                   "Token"          : encryptedTocken,
//                                   "FK_Customer"    : encryptedCusNum ,
//                                   "BranchCode"     : encryptedBranchCode,
//                                   "TransType"      : encryptedTransType,
//                                   "TrnsDate"       : encryptedTrnsDate,
//                                   "SubMode"        : encryptedSubMode ,
//                                   "Status"         : encryptedStatus,
//                                   "BankKey"        : BankKey,
//                                   "BankHeader"     : BankHeader]
//        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
//        var request             = URLRequest(url: url)
//            request.httpMethod  = "post"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody    = jsonData
//        let session = URLSession(configuration: .default,
//                                 delegate: self,
//                                 delegateQueue: nil)
//        let task = session.dataTask(with: request) { [self] data, response, error in
//            guard let data = data, error == nil else {
//                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                self.activityIndicator.stopAnimating()
//                self.blurView.isHidden = true
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//            let httpResponse = response as! HTTPURLResponse
//            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
//                do {
//                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//                    if sttsCode==0 {
//                        let OtherFundTransferHistory  = responseJSONData.value(forKey: "OtherFundTransferHistory") as! NSDictionary
//                        OtherFundTransferHistoryList = OtherFundTransferHistory.value(forKey: "OtherFundTransferHistoryList") as! [NSDictionary]
//                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
//                            self?.statusTable.reloadData()
//                            self?.statusTable.isHidden = false
//                        }
//
//                    }
//
//                    else {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
//                            self?.statusTable.isHidden = false
//                            self?.statusTable.isHidden = true
//                        }
//                        let OtherFundTransferHistory  = responseJSONData.value(forKey: "OtherFundTransferHistory") as Any
//                        if OtherFundTransferHistory as? NSDictionary != nil {
//                                let OtherFundTransferHistory  = responseJSONData.value(forKey: "OtherFundTransferHistory") as! NSDictionary
//                            let ResponseMessage =  OtherFundTransferHistory.value(forKey: "ResponseMessage") as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(ResponseMessage), animated: true,completion: nil)
//                            }
//                        }
//                        else {
//                            let EXMessage = responseJSONData.value(forKey: "EXMessage")! as! String
//
//                            DispatchQueue.main.async { [weak self] in
//                                self?.present(messages.msg(EXMessage), animated: true,completion: nil)
//                            }
//                        }
//
//                    }
//                }
//                catch{
//                    DispatchQueue.main.async { [weak self] in
//                        self?.activityIndicator.stopAnimating()
//                        self?.blurView.isHidden = true
//                        self?.statusTable.isHidden = false
//                        self?.statusTable.isHidden = true
//                    }
//                }
//            }
//            else{
//                DispatchQueue.main.async { [weak self] in
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                    self?.statusTable.isHidden = false
//                    self?.statusTable.isHidden = true
//                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
//                }
//                print(httpResponse.statusCode)
//            }
//        }
//        task.resume()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == statusTable{
            return OtherFundTransferHistoryList.count
        }
        return hdrLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == statusTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath as IndexPath) as!  fundTransStatusTableViewCell
            let stat = (OtherFundTransferHistoryList[indexPath.row].value(forKey: "Status") as! String)
            cell.statusDateL.text = (OtherFundTransferHistoryList[indexPath.row].value(forKey: "Date") as! String)
            cell.statusTypeL.text = (OtherFundTransferHistoryList[indexPath.row].value(forKey: "Status") as! String)
            cell.statusBenNameL.text = (OtherFundTransferHistoryList[indexPath.row].value(forKey: "Beneficiary") as! String)
            cell.statusNarrationL.text = (OtherFundTransferHistoryList[indexPath.row].value(forKey: "Remark") as! String)
            if stat == "WAITING" {
                cell.statusTypeImg.image = UIImage(imageLiteralResourceName: "ic_waiting_b.png")
                cell.statusTypeL.textColor = #colorLiteral(red: 0.06274509804, green: 0.1450980392, blue: 0.6745098039, alpha: 1)
            }
            else if stat == "SUCCESS" {
                cell.statusTypeImg.image = UIImage(imageLiteralResourceName: "ic_sucess_g.png")
                cell.statusTypeL.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            }
            else if stat == "RETURNED" {
                cell.statusTypeImg.image = UIImage(imageLiteralResourceName: "ic_sucess_g.png")
                cell.statusTypeL.textColor = #colorLiteral(red: 0.9176470588, green: 0.8039215686, blue: 0, alpha: 1)
            }
            else if stat == "FAILED" {
                cell.statusTypeImg.image = UIImage(imageLiteralResourceName: "ic_fail_r.png")
                cell.statusTypeL.textColor  = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            }
            else{
                cell.statusTypeL.textColor = UIColor.black
            }
            return cell

        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "transStatusCell", for: indexPath as IndexPath) as!  TransactionStatusHdrTableViewCell
            cell.HdrLabel.text = hdrLabels[indexPath.row]
            cell.hdrButton.curvedButtonWithBorder(UIColor.gray.cgColor)
            if indexPath.row == 0 {
                cell.hdrButton.addTarget(self, action: #selector(StatusDropDown(_:)), for: .touchUpInside)
                cell.hdrButton.setTitle(statusDrop[0], for: .normal)
                StatusDropD(cell.hdrButton)
            }
            else {
                cell.hdrButton.addTarget(self, action: #selector(WeekDropDown(_:)), for: .touchUpInside)
                cell.hdrButton.setTitle(weekDrop[0], for: .normal)
                WeekDropD(cell.hdrButton)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == statusTable {
            OtherFundTransferHistoryDetails = OtherFundTransferHistoryList[indexPath.row]
            performSegue(withIdentifier: "statusDetailsSegue", sender: self)
        }
    }
    
    func StatusDropD(_ sender: UIButton) {
            staDrop.anchorView      = sender
            staDrop.bottomOffset    = CGPoint(x: 0, y:40)
            staDrop.dataSource      = statusDrop
            staDrop.backgroundColor = UIColor.white
            staDrop.selectionAction = {[weak self] (index, item) in
                DispatchQueue.main.async { [weak self] in
                    sender.setTitle(item, for: .normal)
                    self?.activityIndicator.startAnimating()
                    self?.blurView.isHidden = false
                    self?.Status = String(index)
                    self?.OtherFundTransferHistory()
                }
            }
    }
    @IBAction func StatusDropDown(_ sender: UIButton) {
        staDrop.show()
    }
    func WeekDropD(_ sender: UIButton) {
        wkDrop.anchorView      = sender
        wkDrop.bottomOffset    = CGPoint(x: 0, y:40)
        wkDrop.dataSource      = weekDrop
        wkDrop.backgroundColor = UIColor.white
        wkDrop.selectionAction = {[weak self] (index, item) in
            DispatchQueue.main.async { [weak self] in
                sender.setTitle(item, for: .normal)
                self?.activityIndicator.startAnimating()
                self?.blurView.isHidden = false
                self?.TrnsDate = item
                self?.OtherFundTransferHistory()
            }
        }
    }

    @IBAction func WeekDropDown(_ sender: UIButton) {
        wkDrop.show()
    }

    @IBAction func TodaysStatus(_ sender: UIButton) {
        hdrLabels = ["Status :"]
        TodaysStatusBtn.buttonUnderLineColor(underLineGreen)
        TodaysStatusBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        PreviousStatusBtn.buttonUnderLineColor(UIColor.white)
        PreviousStatusBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        hdrTable.reloadData()
        hdrTblHt.constant = 65
        TransType = "1"
        Status = "0"
        TrnsDate = Date().currentDate(format: "dd/MM/yyy")
        activityIndicator.startAnimating()
        blurView.isHidden = false
        OtherFundTransferHistory()
    }
    
    @IBAction func PreviousStatus(_ sender: UIButton) {
        hdrLabels = ["Status :", "Weeks  :"]
        PreviousStatusBtn.buttonUnderLineColor(underLineGreen)
        PreviousStatusBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        TodaysStatusBtn.buttonUnderLineColor(UIColor.white)
        TodaysStatusBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        hdrTable.reloadData()
        hdrTblHt.constant = 130
        TransType = "2"
        Status = "0"
        TrnsDate = "2"
        activityIndicator.startAnimating()
        blurView.isHidden = false
        OtherFundTransferHistory()
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from home screen to accInfo screen
        if segue.identifier == "statusDetailsSegue"
        {
            let vw = segue.destination as! statusDetailsViewController
            vw.OtherFundTransferHistoryDetails = OtherFundTransferHistoryDetails
        }
    }

}
