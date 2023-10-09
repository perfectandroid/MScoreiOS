//
//  IntimationViewController.swift
//  mScoreNew
//
//  Created by Perfect on 17/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class NoticePostingDetailViewController : UIViewController, URLSessionDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var blurView             : UIView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
    @IBOutlet weak var noticeTable          : UITableView! {
        didSet {
            noticeTable.isHidden = true
        }
    }
    @IBOutlet weak var noticeView: UIView!{
        didSet{
            noticeView.isHidden = true
            cardView(noticeView)
        }
    }
    
    var TokenNo         = String()
    var custoID         = Int()
    var fetchedCusDetails   : [Customerdetails] = []
    var instanceOfEncryption: EncryptionPost    = EncryptionPost()
    var NoticePostingDetailsList = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
        }
        catch{
        }
        for fetchedCusDetail in fetchedCusDetails
        {
            custoID     = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
            TokenNo     = (fetchedCusDetail.value(forKey: "tokenNum") as? String)!
        }
        blurView.isHidden = false
        activityIndicator.startAnimating()
        NoticeCall()
    }
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    func NoticeCall() {
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/NoticePostingDetails")!
//        let encryptedCusID      = instanceOfEncryption.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedToken      = instanceOfEncryption.encryptUseDES(TokenNo, key: "Agentscr")
        
        //instanceOfEncryption.encryptUseDES("5", key: "Agentscr")
        
        let encryptedCusID      = String(custoID)
        let encryptedToken      = TokenNo
        let jsonDict            = ["ReqMode": "5",
                                   "Token":encryptedToken,
                                   "FK_Customer":encryptedCusID,
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
                        let NoticePostingInfo  = responseJSONData.value(forKey: "NoticePostingInfo") as! NSDictionary
                        self.NoticePostingDetailsList  = NoticePostingInfo.value(forKey: "NoticePostingDetailsList") as! [NSDictionary]
                     
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.noticeView.isHidden = false
                            self?.noticeTable.reloadData()
                            self?.noticeTable.isHidden = false
                        }
                    }
                        
                    else {
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.noticeView.isHidden = true
                            self?.noticeTable.isHidden = true
                        }
                        let NoticePostingInfo  = responseJSONData.value(forKey: "NoticePostingInfo") as Any
                        if NoticePostingInfo as? NSDictionary != nil {
                            let NoticePostingInf  = responseJSONData.value(forKey: "NoticePostingInfo") as! NSDictionary
                            let ResponseMessage =  NoticePostingInf.value(forKey: "ResponseMessage") as! String

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
                        self?.noticeView.isHidden = true
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.view.frame.size.height/4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return NoticePostingDetailsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = noticeTable.dequeueReusableCell(withIdentifier: "NoticeCell") as! NoticeTableViewCell
            cell.noticeTypeName.text    = NoticePostingDetailsList[indexPath.item].value(forKey: "NoticeTypeName") as? String
            cell.accType.text           = NoticePostingDetailsList[indexPath.item].value(forKey: "AccountType") as? String
            cell.accNumber.text         = NoticePostingDetailsList[indexPath.item].value(forKey: "AccountNo") as? String
            cell.noticeDate.text        = NoticePostingDetailsList[indexPath.item].value(forKey: "NoticeDate") as? String
            cell.dueAmount.text         = Double((NoticePostingDetailsList[indexPath.item].value(forKey: "DueAmount") as? String)!)?.currencyIN
        return cell
    }
    
}
