//
//  DueDateViewController.swift
//  mScoreNew
//
//  Created by Perfect on 01/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class DueDateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDelegate {
    
    @IBOutlet weak var blurView: UIView!{
        didSet{
            blurView.isHidden = true
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{
        didSet{
            activityIndicator.stopAnimating()
        }
    }
    @IBOutlet weak var dueDateListView: UIView!
    {
        didSet{
            dueDateListView.isHidden = true
        }
    }
    @IBOutlet weak var dueDateListTable: UITableView!
    @IBOutlet weak var dueDateListDate: UILabel!{
        didSet{
//            let addedDate = Date()
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd-MM-yyyy"
//            let startDate = formatter.string(from: addedDate)
//            let startDt = formatter.date(from: startDate)
//
//            let endDt = startDt!.addingTimeInterval(60*60*24*14)
//            let endDate = formatter.string(from: endDt)
//
//            dueDateListDate.text = "Due Date List [\(startDate) to \(endDate)]"
            dueDateListDate.text = "Due Date List For Upcoming Two Weeks"

        }
    }
    
    @IBOutlet weak var note: UILabel!{
        didSet{
            note.text = "Over due loans are shown in red color\n* Due amount shown in this list is as today. \n** You can set reminder on calender for due date information of deposits & loans."
        }
    }
    
    
    var AccountDueDateDetails   : [NSDictionary] = []
    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()
    // for fetch customer detail
    var fetchedCusDetails       : [Customerdetails] = []
    var custoID = Int()
    var TokenNo = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                custoID     = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
                TokenNo     = (fetchedCusDetail.value(forKey: "tokenNum") as? String)!
            }
        }
        catch{
        }
        dueDateList(type: "1")
    }
    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func dueDateListSelection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            dueDateListView.isHidden = true
            dueDateList(type: "1")
            dueDateListDate.text = "Due Date List For Upcoming Two Weeks"
        case 1:
            dueDateListView.isHidden = true
            dueDateList(type: "2")
            dueDateListDate.text = "Demand List For Upcoming Two Weeks"
        default:
            dueDateListView.isHidden = true
            dueDateList(type: "1")
            dueDateListDate.text = "Due Date List For Upcoming Two Weeks"
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountDueDateDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "standingInstraCell") as! StandingInstraTableViewCell
            cell.sourceDet.text = String(indexPath.item+1)
            cell.destinationDet.text = (AccountDueDateDetails[indexPath.item].value(forKey: "AccountNo") as! String + "\n(\(AccountDueDateDetails[indexPath.item].value(forKey: "AccountType") as! String))")
        
        
        let amount = AccountDueDateDetails[indexPath.item].value(forKey: "Amount") as! Double
        cell.date.text = points(amount)

//            cell.date.text = "₹ \(amount)"
            cell.amount.text =  (AccountDueDateDetails[indexPath.item].value(forKey: "DueDate") as! String)
        if AccountDueDateDetails[indexPath.item].value(forKey: "Type") as! String == "Y"{
            cell.sourceDet.textColor = UIColor.red
            cell.destinationDet.textColor = UIColor.red
            cell.date.textColor = UIColor.red
            cell.amount.textColor = UIColor.red
        }
        else{
            cell.sourceDet.textColor = UIColor.black
            cell.destinationDet.textColor = UIColor.black
            cell.date.textColor = UIColor.black
            cell.amount.textColor = UIColor.black
        }
        
        
        
        
        cell.reminder.tag = indexPath.row
        cell.reminder.addTarget(self, action: #selector(reminderButtonPressed(_:)), for: .touchUpInside)
        if indexPath.item % 2 == 0 {
            cell.sourceDet.backgroundColor = UIColor.white
            cell.destinationDet.backgroundColor = UIColor.white
            cell.date.backgroundColor = UIColor.white
            cell.amount.backgroundColor = UIColor.white
            cell.reminder.backgroundColor = UIColor.white
        } else {
            cell.sourceDet.backgroundColor = oddCell
            cell.destinationDet.backgroundColor = oddCell
            cell.date.backgroundColor = oddCell
            cell.amount.backgroundColor = oddCell
            cell.reminder.backgroundColor = oddCell
        }
        dueDateListView.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func dueDateList(type: String) {
        
        blurView.isHidden = false
        activityIndicator.startAnimating()
        
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
                self?.activityIndicator.stopAnimating()
                self?.blurView.isHidden = true
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/AccountDueDateDetails")!
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedToken      = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedType  = instanceOfEncryptionPost.encryptUseDES(type, key: "Agentscr")
//        instanceOfEncryptionPost.encryptUseDES("8", key: "Agentscr")
        
        let custID = "\(custoID)"
        let token = "\(TokenNo)"
        let type = "\(type)"
        let rmode = "8"
        let jsonDict            = ["ReqMode"    : rmode,
                                   "Token"      :token,
                                   "FK_Customer":custID,
                                   "AccountType":type,
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
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                
                DispatchQueue.main.async { [weak self] in
                    self?.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
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
                        let AccountDueDateDetailsIfo   = responseJSONData.value(forKey: "AccountDueDateDetailsIfo") as! NSDictionary
                        self.AccountDueDateDetails   = AccountDueDateDetailsIfo.value(forKey: "AccountDueDateDetails") as! [NSDictionary]
                       
                        DispatchQueue.main.async { [weak self] in
                            self!.dueDateListTable.reloadData()
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                        }
                    }
                        
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
                            self?.present(messages.msg("No data found"), animated: true,completion: nil)
                        }
                        
                    }
                    
                }
                catch{
                    DispatchQueue.main.async{
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
    
    @IBAction func reminderButtonPressed(_ sender: UIButton) {
        
        let buttonRow = sender.tag
        
        let accType = AccountDueDateDetails[buttonRow].value(forKey: "AccountType") as! String
        let branch = AccountDueDateDetails[buttonRow].value(forKey: "AccountBranchName") as! String
        
        let customReminderAlert = self.storyboard?.instantiateViewController(withIdentifier: "reminderAlert") as! ReminderAlertViewController
        customReminderAlert.providesPresentationContextTransitionStyle = true
        customReminderAlert.definesPresentationContext = true
        customReminderAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customReminderAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customReminderAlert.delegate = self
        if AccountDueDateDetails[buttonRow].value(forKey: "Type") as! String == "Y"{
            customReminderAlert.remiPreviousDates = 1
        }
        else{
            customReminderAlert.remiPreviousDates = 0
        }
        customReminderAlert.date = (AccountDueDateDetails[buttonRow].value(forKey: "DueDate") as! String)
        customReminderAlert.remiMessage = "Your \(accType.lowercased()) account in \(appName)(\(branch.lowercased())) will due on \(AccountDueDateDetails[buttonRow].value(forKey: "DueDate") as! String). Please do the needful actions."
        self.present(customReminderAlert, animated: true, completion: nil)

    }
//    func addPoints(inputNumber: NSMutableString) -> String {
//        var count: Int = inputNumber.length
//        while count >= 4 {
//            count = count - 3
//            inputNumber.insert(",", at: count) // you also can use ","
//        }
//        print(inputNumber)
//        return String(inputNumber)
//    }
    
    func points(_ myDouble: Double) -> String{
        let myDouble = myDouble
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        
        // We'll force unwrap with the !, if you've got defined data you may need more error checking
        
        let priceString = currencyFormatter.string(from: NSNumber(value: myDouble))!
        print(priceString) // Displays $9,999.99 in the US locale

        return priceString
    }
}

extension DueDateViewController: ReminderAlertDelegate{
    
    func dateButtonTapped() {
        print("date")
    }
    
    func timeButtonTapped() {
        print("time")
    }
    
    func noteButtonTapped() {
        print("note")
    }
    
    func submitButtonTapped() {
        print("submit")
    }
    
    func cancelButtonTapped() {
        print("cancel")
    }

    
}
