//
//  ProfileViewController.swift
//  mScoreNew
//
//  Created by Perfect on 01/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class ProfileViewController: NetworkManagerVC {
    
    lazy var accounNumberLabel:UILabel = {
       
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
        label.textColor = UIColor.white
        
        label.textAlignment = .center
        return label
    }()

    @IBOutlet weak var navItem: UINavigationItem!{
        didSet{
            navItem.title = "Profile"
        }
    }

    @IBOutlet weak var profileImage: UIImageView!{
        didSet{
            profileImage?.layer.cornerRadius = (profileImage?.frame.size.width)!/4
            profileImage?.clipsToBounds = true
            profileImage?.layer.borderWidth = 3.0
            profileImage?.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var customerNumber: UILabel!
    @IBOutlet weak var custAddress: UILabel!
    @IBOutlet weak var custNumber: UILabel!
    @IBOutlet weak var custEmail: UILabel!
    @IBOutlet weak var custGender: UILabel!
    @IBOutlet weak var custCalender: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()

    // for fetch customer detail
    var fetchedCusDetails       : [Customerdetails] = []
    var fetchedCusPhoto         : [CustomerPhoto] = []
    var profImage = UIImage()
    var TokenNo    = String()
    var custoID      = Int()
    var accountLabelContstrainsts = [NSLayoutConstraint]()
    var accountNumber:String = ""

    
    fileprivate func accountNumberLabelInitialize() {
        self.view.addSubview(accounNumberLabel)
        
        accounNumberLabel.text = accountNumber == "" ? "" : "A/C Number: \(accountNumber)"
        
        self.accountLabelContstrainsts.append(self.accounNumberLabel.topAnchor.constraint(equalTo: customerNumber.bottomAnchor, constant: 2))
        self.accountLabelContstrainsts.append(self.accounNumberLabel.leadingAnchor.constraint(equalTo: self.customerNumber.leadingAnchor, constant: 0))
        self.accountLabelContstrainsts.append(self.accounNumberLabel.trailingAnchor.constraint(equalTo: self.customerNumber.trailingAnchor, constant: 0))
        
        NSLayoutConstraint.activate(self.accountLabelContstrainsts)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        activityIndicator.startAnimating()
        blurView.isHidden = false
        self.custAddress.minimumScaleFactor = 0.6
        self.profileImage.backgroundColor = UIColor.systemTeal
//        DispatchQueue.main.async { [weak self] in
//            self!.setProfile()
//        }
        
        

        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                
                customerNumber.text = "(Customer ID: " + (fetchedCusDetail.value(forKey: "customerNum") as? String)! + ")"
                customerName.text   = fetchedCusDetail.value(forKey: "name") as? String
                
                custoID     = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
                TokenNo     = (fetchedCusDetail.value(forKey: "tokenNum") as? String)!
            }
        }
        catch{
        }
        
        do{
            fetchedCusPhoto = try coredatafunction.fetchObjectofImage()
            if fetchedCusPhoto.count == 0{
                DispatchQueue.main.async { [weak self] in
                    self?.getUserImage()
                }
            }
            else {
                for fetchedCusPic in fetchedCusPhoto
                {
                    let base64String = fetchedCusPic.value(forKey: "custPhoto") as? String
                    if base64String != nil {
                        
                        let decodedData = NSData(base64Encoded: base64String! , options: [])
                        if let data = decodedData {
                            DispatchQueue.main.async { [weak self] in
                                self?.profileImage.image = UIImage(data: data as Data)
                            }
                        } else {
                            print("error with decodedData")
                        }
                    } else {
                        print("error with base64String")
                    }
                }
                
            }
        }
        catch{
        }
        
        
        self.setProfileApi()
        //self.setProfilePhoto()
        //self.getUserImage()
       
    }
    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    
//    func fetchImageFromLocalStorage(){
//        do{
//            fetchedCusPhoto = try coredatafunction.fetchObjectofImage()
//            if fetchedCusPhoto.count == 0{
//                DispatchQueue.main.async { [weak self] in
//                    self?.setProfilePhoto()
//
//                }
//            }
//            else {
//                for fetchedCusPic in fetchedCusPhoto
//                {
//                    let base64String = fetchedCusPic.value(forKey: "custPhoto") as? String
//                    if base64String != nil {
//
//                        let decodedData = NSData(base64Encoded: base64String! , options: [])
//                        if let data = decodedData {
//                            DispatchQueue.main.async {
//                                self.profileImage.image = UIImage(data: data as Data)
//                            }
//                        } else {
//                            print("error with decodedData")
//                        }
//                    } else {
//                        print("error with base64String")
//                    }
//                }
//
//            }
//        }
//        catch{
//        }
//    }
    
    
    func getUserImage() {
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = APIBaseUrlPart1 + "/Image/CustomerImageDets"
        
        let arguments = ["FK_Customer":"\(custoID)", "BankKey" : BankKey,
                         "BankHeader" : BankHeader]
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    //self.responseParse(type: , datas: <#T##NSDictionary#>, key: <#T##String#>)
                    
                    let exMessage = self.responseParse(type:String.self, datas: datas, key: "EXMessage") ?? ""
                    
                    if let CustomerImageDets = self.responseParse(type: NSDictionary.self, datas: datas, key: "CustomerImageDets"){
                        
                        
                        let responseMessage = self.responseParse(type: String.self, datas: CustomerImageDets, key: self.ResponseMessage) ?? ""
                         
                        if statusCode == 0{
                            
                            let CusImage =  self.responseParse(type: String.self, datas: CustomerImageDets, key: "CusImage") ?? ""
                            if CusImage != ""{
                                DispatchQueue.main.async {
                                    coredatafunction.imageData(custPhoto: CusImage)
                                }
                            }
                            
                        DispatchQueue.main.async {
                            
                            
                            
                            if  let imageData = Data(base64Encoded: CusImage){
                            
                                
                                self.profileImage.image = UIImage(data: imageData)
                                
                             }else{
                                 
                                self.profileImage.image = UIImage(named: "account")
                                 
                             }}
                            
                        }else if statusCode == -1{
                            
                            if responseMessage != ""{
                                if responseMessage == "Invalid Token"{
                                    
                                    print("==============INVALID TOKEN============")
                                    
                                }else{
                                    
                                    DispatchQueue.main.async {
                                        self.present(messages.msg(responseMessage), animated: true, completion: nil)
                                    }}}
                            
                        }else{
                            
                            if responseMessage != ""{
                                
                                DispatchQueue.main.async {
                                   // self.present(messages.msg(responseMessage), animated: true, completion: nil)
                                 }}}
                        
                    }else{
                        
                        if exMessage != ""{
                            
                            DispatchQueue.main.async {
                                self.present(messages.msg(exMessage), animated: true, completion: nil)
                             }}
                        
                        
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
    
    
    
//    func setProfilePhoto() {
//
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
//        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/Image/CustomerImageDets")!
////        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
//
//        let encryptedCusNum     = String(custoID)
//        let jsonDict            = ["FK_Customer":encryptedCusNum,
//                                   "BankKey" : BankKey,
//                                   "BankHeader" : BankHeader]
//
//        var request             = URLRequest(url: url)
//        request.httpMethod  = "post"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        do{
//            request.httpBody    = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
//
//        }catch let error{
//            print(error.localizedDescription)
//        }
//        let session = URLSession(configuration: .default,
//                                 delegate: self,
//                                 delegateQueue: OperationQueue.main)
//        let task = session.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//
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
//                    DispatchQueue.main.async { [weak self] in
//                        self?.activityIndicator.stopAnimating()
//                        self?.blurView.isHidden = true
//                    }
//                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
//                    if sttsCode==0 {
//                        let imgDets  = responseJSONData.value(forKey: "CustomerImageDets") as! NSDictionary
//                        let base64String = imgDets.value(forKey: "CusImage") as? String ?? ""
//                        if base64String != "" {
//                            coredatafunction.imageData(custPhoto: base64String)
//
//                            DispatchQueue.global(qos: .userInitiated).async {
//
//                                let decodedData = NSData(base64Encoded: base64String)
//                                if let datas = decodedData {
//
//                                    DispatchQueue.main.async {
//
//
//
//                                        self.profileImage.image = UIImage(data: datas as Data)
//
//
//
//
//
//                                    }
//
//
//
//
//                                } else {
//                                    print("error with decodedData")
//                                }
//
//                            }
//
//
//
//                        } else {
//
//                             self.fetchImageFromLocalStorage()
//
//                            print("error with base64String")
//                        }
//                    }
//                    else {
//                        self.fetchImageFromLocalStorage()
//                    }
//                }
//                catch{
//                    DispatchQueue.main.async{
//                        self.blurView.isHidden = true
//                        self.activityIndicator.stopAnimating()
//                    }
//                }
//            }
//            else{
//                DispatchQueue.main.async { [weak self] in
//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
//                }
//                print(httpResponse.statusCode)
//            }
//        }
//            task.resume()
//
//    }
    
    func setUIComponents(info:NSDictionary)  {
        DispatchQueue.main.async {
            self.custAddress.text = "ADDRESS : \(info.value(forKey: "Address") ?? "NA")"
            
            self.custNumber.text = "CONTACT NO : \(info.value(forKey: "PhoneNumber") ?? "NA")"

            self.custEmail.text = "EMAIL : \(info.value(forKey: "Email") ?? "NA")"

            self.custGender.text = "GENDER : \(info.value(forKey: "Gender") ?? "NA")"
            
            self.custCalender.text = "DATE OF BIRTH : \(info.value(forKey: "DateOfBirth") ?? "" )"
            self.accountNumberLabelInitialize()
            self.view.layoutIfNeeded()
        }
    }
    
    func setProfileApi(){
        
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = APIBaseUrlPart1 + "/AccountSummary/CustomerProfileDetails"
        
        let arguments = ["FK_Customer":"\(custoID)",
                         "ReqMode":"7",
                          "Token":TokenNo,
                          "BankKey" : BankKey,
                          "BankHeader" : BankHeader]
        
        APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResult in
            switch getResult{
            case.success(let datas):
                
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    
                    let exMessage = self.responseParse(type:String.self, datas: datas, key: "EXMessage") ?? ""
                    
                    let CustomerProfileInfo  = datas.value(forKey: "CustomerProfileDetailsInfo") as? NSDictionary ?? [:]
                        
                        let ResponseMessage =  CustomerProfileInfo.value(forKey: "ResponseMessage")  as? String ?? ""
                        
                        if statusCode == 0{
                            
                       if  let CustomerProfileDetailsInfo  = datas.value(forKey: "CustomerProfileDetailsInfo") as? NSDictionary {
                            
                            self.setUIComponents(info:CustomerProfileDetailsInfo)
                            
                        }else{
                            
                            if exMessage != ""{
                                
                                DispatchQueue.main.async {
                                    self.present(messages.msg(exMessage), animated: true, completion: nil)
                                 }}
                            
                            
                        }
                            
                        }else if statusCode == -1{
                            
                            if ResponseMessage != ""{
                                if ResponseMessage == "Invalid Token"{
                                    
                                    print("==============INVALID TOKEN============")
                                    SessionManager.shared.logOut {
                                        print("====logout 1===")
                                    
                                           
                                            SessionManager.shared.sessionExpiredCall()
                                            return
                                    
                                    }
                                    
                                }else{
                                    
                                    DispatchQueue.main.async {
                                        self.present(messages.msg(ResponseMessage), animated: true, completion: nil)
                                    }}}
                            
                        }else{
                            
                            let msge = ResponseMessage != "" ? ResponseMessage : exMessage
                            
                            DispatchQueue.main.async {
                                self.present(messages.msg(msge), animated: true, completion: nil)
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

    func setProfile() {
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/CustomerProfileDetails")!
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
//        "ReqMode":instanceOfEncryptionPost.encryptUseDES("7", key: "Agentscr"),
//         "Token":instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr"),
        
        let encryptedCusNum     = "\(custoID)"
        
        
        let jsonDict            = ["FK_Customer":encryptedCusNum,
                                   "ReqMode":"7",
                                    "Token":TokenNo,
                                    "BankKey" : BankKey,
                                    "BankHeader" : BankHeader]
        

       
        var request             = URLRequest(url: url)
            request.httpMethod  = "post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            request.httpBody    = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            
        }catch let error{
            print(error.localizedDescription)
        }
        
        
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)
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
                    DispatchQueue.main.async { [weak self] in
                        self?.activityIndicator.stopAnimating()
                        self?.blurView.isHidden = true
                    }
                    let sttsCode = responseJSONData.value(forKey: "StatusCode")! as! Int
                    if sttsCode==0 {
                        let CustomerProfileDetailsInfo  =  responseJSONData.value(forKey: "CustomerProfileDetailsInfo") as! NSDictionary
                        DispatchQueue.main.async { [weak self] in
                            self!.custAddress.text = "ADDRESS : \(CustomerProfileDetailsInfo.value(forKey: "Address")!)"
                            
                            self!.custNumber.text = "CONTACT NO : \(CustomerProfileDetailsInfo.value(forKey: "PhoneNumber")!)"

                            self!.custEmail.text = "EMAIL : \(CustomerProfileDetailsInfo.value(forKey: "Email")!)"

                            self!.custGender.text = "GENDER : \(CustomerProfileDetailsInfo.value(forKey: "Gender")!)"
                            
                            self!.custCalender.text = "DATE OF BIRTH : \(CustomerProfileDetailsInfo.value(forKey: "DateOfBirth")! )"
                            self?.view.layoutIfNeeded()
                        }
                    }
                    else {
                        let CustomerProfileDetailsInfo  = responseJSONData.value(forKey: "CustomerProfileDetailsInfo") as Any
                        if CustomerProfileDetailsInfo as? NSDictionary != nil {
                                let CustomerProfileDetailsInf  = responseJSONData.value(forKey: "CustomerProfileDetailsInfo") as! NSDictionary
                            let ResponseMessage =  CustomerProfileDetailsInf.value(forKey: "ResponseMessage") as! String

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

}
