//
//  RechargeHistoryViewController.swift
//  mScoreNew
//
//  Created by Perfect on 27/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class RechargeHistoryViewController: NetworkManagerVC ,UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var historyTbl       : UITableView!
    @IBOutlet weak var blurView         : UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var customerId  = String()
    var pin         = String()
    var TokenNo     = String()
    var instanceOfEncryptionPost: EncryptionPost    = EncryptionPost()
    var RechargeHistoryList                         = [NSDictionary]()
    private var parserViewModel : ParserViewModel = ParserViewModel()
    let group = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //RechargeHistory()
        RechargeHistoryApi()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if RechargeHistoryList.count == 0 {
             tableEmptyAlertView(show: true, table: tableView, text: "No data found")
        }else{
            tableEmptyAlertView(show: false,table: tableView)
        }
        return RechargeHistoryList.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyListCell") as! rechHistoryListTableViewCell
        let stat = (RechargeHistoryList[indexPath.row].value(forKey: "StatusType") as! String)
        cell.statusLbl.text = stat
        cell.numberLbl.text = (RechargeHistoryList[indexPath.row].value(forKey: "MobileNo") as! String)
        cell.amount.setTitle("  \((RechargeHistoryList[indexPath.row].value(forKey: "RechargeRs") as! Double).currencyIN)  ", for: .normal)
        cell.doneOnLbl.text = "Done On " + (RechargeHistoryList[indexPath.row].value(forKey: "RechargeDate") as! String)
        if stat == "Pending" {
            cell.statusLbl.textColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        }
        else if stat == "Success" {
            cell.statusLbl.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        }
        else if stat == "Reversed" {
            cell.statusLbl.textColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        }
        else if stat == "Failed" {
            cell.statusLbl.textColor  = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        else{
            cell.statusLbl.textColor = UIColor.black
        }
        
        switch (RechargeHistoryList[indexPath.row].value(forKey: "OperatorName") as! String) {
            case "Airtel":
                cell.oprtrImg.image = UIImage(named: "airtel")
            case "Jio":
                cell.oprtrImg.image = UIImage(named: "jio")
            case "BSNL":
                cell.oprtrImg.image = UIImage(named: "bsnl")
            case "Dish TV":
                cell.oprtrImg.image = UIImage(named: "dishtv")
            case "Big TV":
                cell.oprtrImg.image = UIImage(named: "bigtv")
            case "Tata Sky":
                cell.oprtrImg.image = UIImage(named: "tata_sky")
            case "Sun":
                cell.oprtrImg.image = UIImage(named: "sun_direct")
            case "NetConnect":
                cell.oprtrImg.image = UIImage(named: "reliance")
            case "Tata Photon +":
                cell.oprtrImg.image = UIImage(named: "docomo")
            case "Mbrowse":
                cell.oprtrImg.image = UIImage(named: "mts")
            default:
                print("error")
        }
        return cell
    }
    
    //FIXME: ========= RechargeHistoryApi() ==========
    func RechargeHistoryApi(){
        // network reachability checking
        
        
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = "/AccountSummary/RechargeHistory"
        let arguMents = ["ReqMode"        : "21",
                        "Token"          : TokenNo,
                        "FK_Customer"    : customerId,
                        "BranchCode"     : "0",
                        "BankKey"        : BankKey,
                        "BankHeader"     : BankHeader]
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                  let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "RechargeHistory")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg,vc:self) { status in
                        
                        let list = modelInfo.value(forKey: "RechargeHistoryList") as? [NSDictionary] ?? []
                        self.RechargeHistoryList = []
                        self.RechargeHistoryList = list.compactMap{$0}
                        
                        
                        
                    }
                    
                    self.group.leave()
                }
            case.failure(let errorCatched): self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
                self.group.leave()
            }
            
            
           
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.group.wait()
                self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
                self.parserViewModel.mainThreadCall {
                    self.historyTbl.reloadData()
                }
            }
            
        }
        
    }
    
    func RechargeHistory() {
        // network reachability checking
        DispatchQueue.main.async { [self] in
            self.blurView.isHidden = false
            self.activityIndicator.startAnimating()
        }
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [self] in
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
                self.blurView.isHidden = true
                self.activityIndicator.stopAnimating()
            }
            return
        }
        let url                     = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/RechargeHistory")!
        let encryptedReqMode        = instanceOfEncryptionPost.encryptUseDES("21", key: "Agentscr")
        let encryptedTocken         = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
        let encryptedCusNum         = instanceOfEncryptionPost.encryptUseDES(customerId, key: "Agentscr")
        let encryptedBranchCode     = instanceOfEncryptionPost.encryptUseDES("0", key: "Agentscr")
        let jsonDict            = ["ReqMode"        : encryptedReqMode,
                                   "Token"          : encryptedTocken,
                                   "FK_Customer"    : encryptedCusNum,
                                   "BranchCode"     : encryptedBranchCode,
                                   "BankKey"        : BankKey,
                                   "BankHeader"     : BankHeader]
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
                        let RechargeHistory  = responseJSONData.value(forKey: "RechargeHistory") as! NSDictionary
                        
                        RechargeHistoryList = RechargeHistory.value(forKey: "RechargeHistoryList") as! [NSDictionary]
                        DispatchQueue.main.async { [weak self] in
                            self!.historyTbl.reloadData()
                        }
                    }
                    else {
                        let RechargeHistory  = responseJSONData.value(forKey: "RechargeHistory") as Any
                        if RechargeHistory as? NSDictionary != nil {
                                let RechargeHistor  = responseJSONData.value(forKey: "RechargeHistory") as! NSDictionary
                            let ResponseMessage =  RechargeHistor.value(forKey: "ResponseMessage") as! String

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
}
