//
//  StandingInstructionViewController.swift
//  mScoreNew
//
//  Created by Perfect on 14/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class StandingInstructionViewController: UIViewController,URLSessionDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var standingInstraTable: UITableView!
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    
    var TokenNo         = String()
    var custoID         = Int()
    var fetchedCusDetails :[Customerdetails] = []
    var instanceOfEncryption: EncryptionPost = EncryptionPost()
    var standInstraDetailData = [standingInstraInfoList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.standingInstraTable.isHidden = true
        // Do any additional setup after loading the view.
        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                custoID       = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
                TokenNo     = (fetchedCusDetail.value(forKey: "tokenNum") as? String)!
            }
        }
        catch
        {
        }
       
        activityIndicator.startAnimating()
        blurView.isHidden = false
        StandingInstructionDetailsCall()
    }
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    func StandingInstructionDetailsCall() {
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/StandingInstructionDetails")!
//        let encryptedCusID      = instanceOfEncryption.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedToken      = instanceOfEncryption.encryptUseDES(TokenNo, key: "Agentscr")
        //instanceOfEncryption.encryptUseDES("4", key: "Agentscr")
        
        
        let encryptedCusID      = String(custoID)
        let encryptedToken      = TokenNo
        let jsonDict            = ["ReqMode":"4",
                                   "Token":encryptedToken,
                                   "FK_Customer":encryptedCusID,
                                   "BankKey" : BankKey,
                                   "BankHeader" : BankHeader]
        
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options:[])
            request.httpBody    = jsonData
        request.timeoutInterval = 80
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)
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
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let StandingInstructionInfo  = responseJSONData.value(forKey: "StandingInstructionInfo") as! NSDictionary
                        let StandingInstructionDetailsList  = StandingInstructionInfo.value(forKey: "StandingInstructionDetailsList") as! [NSDictionary]
                        var i = 0
                        for StandingInstructionDetails in StandingInstructionDetailsList {
                           i += 1
                            self.standInstraDetailData.append(standingInstraInfoList(standingInstraInfoListData: [standingInstraInfo(
                                slNo: String(i),
                                source: StandingInstructionDetails.value(forKey: "SourceAccountNo")! as! String ,
                                destination: StandingInstructionDetails.value(forKey: "DestCustomer")! as! String + " \n(\( StandingInstructionDetails.value(forKey: "DestAccountNo")! as! String ))",
                                date: StandingInstructionDetails.value(forKey: "Date")! as! String,
                                amount: StandingInstructionDetails.value(forKey: "Amount")! as! Double)]))
                        }

                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.standingInstraTable.isHidden = false
                            self?.standingInstraTable.reloadData()
                        }
                    }
                    
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.standingInstraTable.isHidden = true
                            self?.present(messages.msg("No data found"), animated: true,completion: nil)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return standInstraDetailData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell = standingInstraTable.dequeueReusableCell(withIdentifier: "standingInstraCell") as! StandingInstraTableViewCell
        
       
        cell.sourceDet.text = self.standInstraDetailData[indexPath.item].standingInstraInfoListData[0].source
        cell.destinationDet.text = self.standInstraDetailData[indexPath.item].standingInstraInfoListData[0].destination
        cell.date.text = self.standInstraDetailData[indexPath.item].standingInstraInfoListData[0].date
        cell.amount.text = self.standInstraDetailData[indexPath.item].standingInstraInfoListData[0].amount.currencyIN
//        if indexPath.item % 2 == 0 {
//            cell.sourceDet.backgroundColor = UIColor.white
//            cell.destinationDet.backgroundColor = UIColor.white
//            cell.date.backgroundColor = UIColor.white
//            cell.amount.backgroundColor = UIColor.white
//        } else {
//            cell.sourceDet.backgroundColor = oddCell
//            cell.destinationDet.backgroundColor = oddCell
//            cell.date.backgroundColor = oddCell
//            cell.amount.backgroundColor = oddCell
//        }

        return cell
    }


}
