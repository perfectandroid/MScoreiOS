//
//  ImpsNeftRtgsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 10/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class ImpsNeftRtgsViewController: NetworkManagerVC,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var refresh          : UIButton!
    @IBOutlet weak var savedBenificiary : UILabel!
    @IBOutlet weak var beneficiaryTable : UITableView!
    @IBOutlet weak var blurView         : UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let refreshImage = UIImage(named: "ic_action_refresh_1")?.withRenderingMode(.alwaysTemplate)
    
    // set var for get data in the time of segue
    var TokenNo         = String()
    var customerId      = String()
    var pin             = String()
    var sectionName     = String()
    var name:String     = ""
    var acc:String      = ""
    var ifsc:String     = ""
    
    var list            = [listData]()
    var cellSelection   = Bool()
   

    var instanceOfEncryption: Encryption = Encryption()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //savedBenf()
        
        savedBeneficary()
        refresh.setImage(refreshImage, for: .normal)
        refresh.tintColor          = blueColor
        savedBenificiary.textColor = blueColor
        // udid generation
        UDID = udidGeneration.udidGen()
        
        activityIndicator.startAnimating()
        blurView.isHidden = false
        
        
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        //// whenever the view will appear this func works
        self.beneficiaryTable.reloadData()

    }
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 130
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "benificiaryCell") as! BeneficiaryTableViewCell
            cell.benficiaryName.text            = list[indexPath.item].beneName
            cell.benficiaryAccNo.text           = list[indexPath.item].beneAccNumb
            cell.benficiaryIFSC.text            = list[indexPath.item].beneIfsc
            cell.deleteBenefi.tag               = indexPath.row
            cell.deleteBenefi.addTarget(self, action: #selector(ImpsNeftRtgsViewController.deleteAction(_:)), for: .touchUpInside)
            cell.cellView.layer.shadowColor     = UIColor.black.cgColor
            cell.cellView.layer.shadowOffset    = CGSize(width: 3, height: 3)
            cell.cellView.layer.shadowOpacity   = 0.7
            cell.cellView.layer.shadowRadius    = 4.0
        activityIndicator.stopAnimating()
        blurView.isHidden = true
        return cell
    }
    //MARK: - DELETE_BENEFICIARY()
    @IBAction func deleteAction(_ sender: UIButton)
    {
        // network reachability checking
        
        self.displayIndicator()
        if Reachability.isConnectedToNetwork(){
           
            self.removeIndicator(showMessagge: true, message: networkMsg)
            return
        }

        let confirmation = UIAlertController(title: "", message: "Do You Want To Delete The Beneficiary Details?", preferredStyle: UIAlertController.Style.alert)
        confirmation.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { action in
            self.removeIndicator(showMessagge: false, message: "")
        }))
        confirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default,handler: { (action:UIAlertAction!) -> Void in
            //after user press ok, the following code will be execute
            // url searching
            
            let path =  APIBaseUrlPart1 + "/AccountSummary/NEFTRTGSDeleteReceiver"
            
            let beneName = self.list[sender.tag].beneName
            let IFSC = self.list[sender.tag].beneIfsc
            let beneAccount = self.list[sender.tag].beneAccNumb
            
            
            let parameter = [
            
                "BeneName" : "\(beneName)",
                "BeneIFSC": IFSC,
                "BankKey": BankKey,
               
                "BankHeader": BankHeader,
                "BeneAccNo":beneAccount,
                
            
            ]
            
            self.APICallHandler(urlString: path, method: .post, parameter: parameter) { response in
                
                switch response{
                case.success(let result):
                    
                    if let datas = result as? NSDictionary{
                        
                        
                        guard let statuscode = datas.value(forKey: "StatusCode") as? Int else {
                            return
                        }
                        
                         let exmsg = datas.value(forKey: "EXMessage") as? String ?? ""
                        
                        guard let NEFTRTGSDeleteReceiver = datas.value(forKey: "NEFTRTGSDeleteReceiver") as? NSDictionary else{
                            return
                        }
                        
                        if statuscode == 0{
                            
                            DispatchQueue.main.async {
                                self.present(messages.alertWithAction("\(beneName) has successfully deleled", actions: {
                                    DispatchQueue.main.async {
                                        self.savedBeneficary()
                                    }
                                    
                                }), animated: true)
                            }
                           
                            
                        }else{
                            DispatchQueue.main.async {
                                self.present(messages.msg(exmsg), animated: true, completion: nil)
                            }
                            
                        }
                    }
                    
                    print(result)
                case .failure(let errResponse):
                    
                    var msg = ""
                       
                    let response = self.apiErrorResponseResult(errResponse: errResponse)
                    msg = response.1

                    
                    DispatchQueue.main.async {
                        self.present(messages.msg(msg), animated: true, completion: nil)
                    }
                    
                }
                self.removeIndicator(showMessagge: false, message: "")
            }
            
        }))
        self.present(confirmation, animated: true, completion: nil)
            
            
//            let urlstring =  BankIP + APIBaseUrlPart + "/NEFTRTGSDeleteReceiver?BeneName=\(self.list[sender.tag].beneName)&BeneIFSC=\(self.list[sender.tag].beneIfsc)&BeneAccNo=\(self.list[sender.tag].beneAccNumb)&imei=\(UDID)&token=\(self.TokenNo)&BankKey=\(BankKey)"
//
//            guard let url = URL(string: urlstring) else {
//                self.present(messages.errorMsg(), animated: true, completion: nil)
//                return
//            }
////            let url = URL(string: urlstring)
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            let task = session.dataTask(with: url) { data,response,error in
//                if error != nil
//                {
//                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                    self.activityIndicator.stopAnimating()
//                    self.blurView.isHidden = true
//                    return
//                }
//                let dataInString = String(data: data!, encoding: String.Encoding.utf8)
//                if Int(dataInString!)! > 0
//                {
//                    DispatchQueue.main.async {
//                        self.activityIndicator.stopAnimating()
//
//                        self.blurView.isHidden = true
//                    }
//
//                    self.present(messages.successMsg("Beneficiary deleted Successfully"), animated: true, completion: nil)
//                    return
//
//                }
//                else
//                {
//                    DispatchQueue.main.async {
//                        self.activityIndicator.stopAnimating()
//
//                        self.blurView.isHidden = true
//                    }
//                    self.present(messages.failureMsg("Failed to delete Benificiary"), animated: true, completion: nil)
//                    return
//                }
//
//            }
//            task.resume()
//        }))
//        self.present(confirmation, animated: true, completion: nil)
    }
    
    //TODO: - refreshButton()
    @IBAction func refresh(_ sender: UIButton)
    {
        DispatchQueue.main.async {
            self.list = []
            self.activityIndicator.startAnimating()
            self.blurView.isHidden = true
            self.beneficiaryTable.reloadData()
        }
        savedBeneficary()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let currentCell = tableView.cellForRow(at: indexPath) as! BeneficiaryTableViewCell
            name            = currentCell.benficiaryName.text!
            acc             = currentCell.benficiaryAccNo.text!
            ifsc            = currentCell.benficiaryIFSC.text!
            cellSelection   = true
        performSegue(withIdentifier: "PaymentOfImpsRtgsNeft", sender: self)
    }
    
    @IBAction func proceedWithNewBenificiary(_ sender: UIButton)
    {
        cellSelection = false
        performSegue(withIdentifier: "PaymentOfImpsRtgsNeft", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from home screen to search screen
        if segue.identifier == "PaymentOfImpsRtgsNeft"
        {
            let vw = segue.destination as! PaymentOfNeftImpsRtgsViewController
                vw.pin          = pin
                vw.customerId   = customerId
                vw.TokenNo      = TokenNo
                vw.sectionName  = sectionName
            if cellSelection == true
            {
                vw.name         = name
                vw.acc          = acc
                vw.ifsc         = ifsc
            }
        }
    }
    
    
    //FIXME: - SAVE_BENEFICAIRY_API()
    func savedBeneficary(){
        
        self.displayIndicator()
        if Reachability.isConnectedToNetwork(){
           
            self.removeIndicator(showMessagge: true, message: networkMsg)
            return
        }
        
        
        
        let path =  APIBaseUrlPart1 + "/AccountSummary/NEFTRTGSGetReceiver"
        
        let parameter = [
            
            "FK_Customer" : "\(customerId)",
            "token": TokenNo,
            "BankKey": BankKey,
            "imei": "",
            "BankHeader": BankHeader
            
            
        
        
        ]
        
        APICallHandler(urlString: path, method: .post, parameter: parameter) { Result in
            
            switch Result{
            case .success(let result):
                
                guard let datas = result as? NSDictionary else {
                    return
                }
                
                
                guard let statuscode = datas.value(forKey: "StatusCode") as? Int else {
                    return
                }
                
                 let exmsg = datas.value(forKey: "EXMessage") as? String ?? ""
                
                
                
                let NEFTRTGSGetReceiverList = datas.value(forKey: "NEFTRTGSGetReceiverList") as? NSDictionary ?? [:]
                
                let acLists = NEFTRTGSGetReceiverList.value(forKey: "NEFTRTGSGetReceiverListDetails") as? [NSDictionary] ?? []
                
                if statuscode == 0{
                    
                    self.list = []
                    if acLists.count > 0{
                   
                    for acList in acLists
                    {
                        let benNM       = acList.value(forKey: "BeneName") as! String
                        let benIFSC     = acList.value(forKey: "BeneIFSC") as! String
                        let benACCNUM   = acList.value(forKey: "BeneAccNo") as! String
            
                        self.list.append(listData(beneName: benNM, beneIfsc: benIFSC, beneAccNumb: benACCNUM))
                    }
                    
                }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        
                            self.beneficiaryTable.reloadData()
                        
                    }
                    
                }else{
                    
                    let ResponseMessage =  NEFTRTGSGetReceiverList.value(forKey: "ResponseMessage") as? String ?? ""
                    
                    let message = ResponseMessage == "" ? "No data found" : ResponseMessage
                    DispatchQueue.main.async {
                    self.present(messages.msg(message), animated: true, completion: nil)
                    }
                }
                
                
                
                
                
            case .failure(let errResponse):
                
                var msg = ""
                
                let response = self.apiErrorResponseResult(errResponse: errResponse)
                msg = response.1
                
                    
        
                
                DispatchQueue.main.async {
                    self.present(messages.msg(msg), animated: true, completion: nil)
                }            }
            
            self.removeIndicator(showMessagge: false, message: "")
        }
        
        
    }
    
    func displayIndicator() {
        
        
        
        DispatchQueue.main.async {
            
            self.activityIndicator.startAnimating()
            self.blurView.isHidden = false
        }
      
        
    }
    
    func removeIndicator(showMessagge:Bool,message:String){
        
        DispatchQueue.main.async{
            if showMessagge == true{
            self.present(messages.msg(message), animated: true, completion: nil)
            }
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    
   /* func savedBenf()
    {
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
        
//        let encryptedPin = instanceOfEncryption.encryptUseDES(pin, key: "Agentscr") as String
//        let encryptedCusID = instanceOfEncryption.encryptUseDES(customerId, key: "Agentscr") as String
        let encryptedPin = pin
        let encryptedCusID = customerId
        
        let urls = BankIP + APIBaseUrlPart + "/NEFTRTGSGetReceiver?ID_Customer=\(encryptedCusID)&Pin=\(encryptedPin)&imei=\(UDID)&token=\(TokenNo)&BankKey=\(BankKey)"
        guard let url = URL(string:urls) else {
            self.present(messages.errorMsg(), animated: true, completion: nil)
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) { data,response,error in
            if error != nil
            {
                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                
                self.activityIndicator.stopAnimating()
                self.blurView.isHidden = true
                return
            }
            if let datas = data
            {
                let dataInString = String(data: data!, encoding: String.Encoding.utf8)
                if dataInString == "null"
                {
                        print("error")
                }
                else
                {
                    DispatchQueue.main.async {
                        self.list = []
                    }
                    do
                    {
                        let data1 = try JSONSerialization.jsonObject(with: datas, options: []) as! NSDictionary
                        let acLists = data1.value(forKey: "reciverlist") as! [NSDictionary]
                        for acList in acLists
                        {
                            let benNM       = acList.value(forKey: "BeneName") as! String
                            let benIFSC     = acList.value(forKey: "BeneIFSC") as! String
                            let benACCNUM   = acList.value(forKey: "BeneAccNo") as! String
                            
                            self.list.append(listData(beneName: benNM, beneIfsc: benIFSC, beneAccNumb: benACCNUM))
                        }
                    }
                    catch
                    {
                        DispatchQueue.main.async{
                            self.blurView.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    DispatchQueue.main.async {
                        self.blurView.isHidden = true
                        self.activityIndicator.stopAnimating()
                        self.beneficiaryTable.reloadData()
                    }
                }
            }
        }
        task.resume()
    }*/
}
