//
//  loanScheduleViewController.swift
//  mScoreNew
//
//  Created by Perfect on 13/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class loanScheduleViewController: UIViewController, URLSessionDelegate, UITableViewDataSource, UITableViewDelegate{

    
    @IBOutlet weak var loanScheduleView: UIView!
    @IBOutlet weak var loanScheduleTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blurView: UIView!
    
    var custoID                             = Int()
    var TokenNo                             = String()
    var CustomerLoanAndDepositDetail        = NSDictionary()
    var DepositLoanSele                     = Int()
    var actvClsSele                         = Int()
    var LoanSlabDetailsList                 = [NSDictionary]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loanScheduleView.isHidden = true
        // Do any additional setup after loading the view.
        LoanSlabDetails()
    }
    
    
    func LoanSlabDetails() {
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/LoanSlabDetails")!
        
//        let encryptedReqMode     = instanceOfEncryptionPost.encryptUseDES("11", key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedSubModule    = instanceOfEncryptionPost.encryptUseDES((CustomerLoanAndDepositDetail.value(forKey: "SubModule") as! String), key: "Agentscr")
//        let encryptedLoanNumber     = instanceOfEncryptionPost.encryptUseDES(String(CustomerLoanAndDepositDetail.value(forKey: "AccountNumber") as! String), key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
        
        let accountNo = CustomerLoanAndDepositDetail.value(forKey: "AccountNumber") as? String ?? ""
        
        let subModules = CustomerLoanAndDepositDetail.value(forKey: "SubModule") as? String ?? ""
        
        let jsonDict             = ["ReqMode" : "11",
                                   "FK_Customer" : "\(custoID)",
                                   "SubModule" : "\(subModules)",
                                   "LoanNumber" : accountNo,
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
                        let LoanSlabDetails  = responseJSONData.value(forKey: "LoanSlabDetails") as! NSDictionary
                        LoanSlabDetailsList = LoanSlabDetails.value(forKey: "LoanSlabDetailsList") as! [NSDictionary]

                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self!.loanScheduleTable.reloadData()
                            self?.loanScheduleView.isHidden = false
                        }
                    }
                
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.loanScheduleView.isHidden = true
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                        let LoanSlabDetails  = responseJSONData.value(forKey: "LoanSlabDetails") as Any
                        if LoanSlabDetails as? NSDictionary != nil {
                            let LoanSlabDetails  = responseJSONData.value(forKey: "LoanSlabDetails") as! NSDictionary
                            let ResponseMessage =  LoanSlabDetails.value(forKey: "ResponseMessage") as! String

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
                        self?.loanScheduleView.isHidden = true

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
        return LoanSlabDetailsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loanScheduleCell", for: indexPath as IndexPath) as!  loanScheduleTableViewCell
            cell.slNoL.text         = String(indexPath.row + 1)
            cell.periodL.text       = String(LoanSlabDetailsList[indexPath.row].value(forKey: "Period") as! Int)
        cell.demandL.text       = Date().formattedDateFromString(dateString: LoanSlabDetailsList[indexPath.row].value(forKey: "Demand") as! String,ipFormatter: "dd/MM/yyyy", opFormatter: "dd-MM-yyyy")
            cell.principalL.text    = (LoanSlabDetailsList[indexPath.row].value(forKey: "Principal") as! Double).currencyIN
            cell.interestL.text     = (LoanSlabDetailsList[indexPath.row].value(forKey: "Interest") as! Double).currencyIN
            cell.totalL.text        = (LoanSlabDetailsList[indexPath.row].value(forKey: "Total") as! Double).currencyIN
        return cell
    }
    
//    func formattedDateFromString(dateString: String) -> String?
//    {
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "dd/MM/yyyy"
//        if let date = inputFormatter.date(from: dateString)
//        {
//            let outputFormatter = DateFormatter()
//            outputFormatter.dateFormat = "dd-MM-yyyy"
//            return outputFormatter.string(from: date)
//        }
//        return nil
//    }
    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

}
