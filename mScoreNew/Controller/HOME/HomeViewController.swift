//
//  HomeViewController.swift
//  mScoreNew
//
//  Created by Perfect on 17/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class HomeViewController: NetworkManagerVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var homeHeader         : UIImageView!{
        didSet{
            homeHeader.contentMode = .scaleToFill
        }
    }
    @IBOutlet weak var customerName       : UILabel!
    @IBOutlet weak var customerNumber     : UILabel!
    @IBOutlet weak var CustomerLastLogin  : UILabel!
    @IBOutlet weak var customerImage      : UIImageView!{
        didSet{
            customerImage.contentMode = .scaleToFill
        }
    }
    @IBOutlet weak var bankName           : UINavigationItem!
    @IBOutlet weak var menuView           : UIView!
    @IBOutlet weak var menuViewLeading    : NSLayoutConstraint!
    @IBOutlet weak var blurView           : UIView!
    @IBOutlet weak var msgIsSelected      : UIButton!
    @IBOutlet weak var fabView            : UIView!
    @IBOutlet weak var fabDueDate         : UIButton!
    @IBOutlet weak var homeViewCollection : UICollectionView!
    @IBOutlet weak var homMenuCollection  : UICollectionView!
    @IBOutlet weak var accNumberLabel     : UILabel!
    @IBOutlet weak var ViewBalance        : UIButton!
    @IBOutlet weak var AccNoMaskBtn       : UIButton!
    
    @IBOutlet var techPartnersImg: UIImageView!{
        didSet{
            SetImage(ImageCode: CompanyLogoImageCode, ImageView: techPartnersImg, Delegate: self)
        }
    }
    
    @IBOutlet weak var ViewBalancehide    : UIButton! {
        didSet{
            ViewBalancehide.isHidden = true
        }
    }
    @IBOutlet weak var hdrViewSet: UIView!
    var custoID      = Int()
    var dmenus       = [String]()
    var transDmenus  = [String]()
    var dmenuvalue   = String()
    var Images       = [UIImage]()
    var rechargeMenu = String()
    var Recharge     = ["Prepaid","DTH","Landline","Postpaid","Data Card"]
    var rechargeImg  = [#imageLiteral(resourceName: "phone"),#imageLiteral(resourceName: "dish"),#imageLiteral(resourceName: "landline"),#imageLiteral(resourceName: "phone"),#imageLiteral(resourceName: "datacard")]
    private var parserViewModel:ParserViewModel = ParserViewModel()
    let group  = DispatchGroup()
    //var CustomerLoanAndDepositDetailsList = [NSDictionary]()
    var OwnAccountdetailsList       = [NSDictionary]()
    var settingsUpdateAction : (Bool,Accountdetails)->Void = { (isSelected,account)  in
       
    }
    
    // for fetch customer detail
    var fetchedCusDetails       : [Customerdetails] = []
    var fetchedCusPhoto         : [CustomerPhoto] = []

    // instance of encryption settings
    var instanceOfEncryption    : Encryption = Encryption()
//    var instanceOfEncryptionPost: EncryptionPost = EncryptionPost()
    
    // set var for pass data in the time of segue
    var TokenNo    = String()
    var customerId = String()
    var pin        = String()
    
    var refferenceNumb = String()
    var menushowing    = false
    let viewHeight     = NSLayoutConstraint()
    var refreshed      = Bool()
    var ksebValue      = false
    var rechargeValue  = false
    var homeView : [String] = []
    var homeHdrImage: [UIImage] = []
    
    var homeMenuLabels = ["My Accounts", "Account Summary", "Dash Board", "Branch Details", "Virtual Card", "Due Date Reminder", "Profile" , "EMI Calculator"]
    var homeMenuImages = [ UIImage(imageLiteralResourceName: "ic_hm_my_accnt.png"),
                           UIImage(imageLiteralResourceName: "ic_hm_accnt_summary.png"),
                           UIImage(imageLiteralResourceName: "ic_hm_dash_board.png"),
                           UIImage(imageLiteralResourceName: "ic_hm_bank_details.png"),
                           UIImage(imageLiteralResourceName: "ic_hm_virtual_card.png"),
                           UIImage(imageLiteralResourceName: "ic_hm_due_date.png"),
                           UIImage(imageLiteralResourceName: "ic_hm_profile.png"),
                           UIImage(imageLiteralResourceName: "ic_hm_emi_calc.png")]
    var AccountNumber = ""
    var maskedAccountNumber = ""
    var Balance : Double = 0.00
    
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // udid generation
        if EwireCardService == "1"{
            homeMenuLabels.append("Wallet Services")
            homeMenuImages.append(UIImage(imageLiteralResourceName: "ic_hm_wallet_services.png"))
        }
        else{
            homeMenuLabels.append("More")
            homeMenuImages.append(UIImage(imageLiteralResourceName: "ic_hm_more.png"))
        }
        UDID = udidGeneration.udidGen()
        cardView(hdrViewSet)
        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                DispatchQueue.main.async {
                    self.customerNumber.text     = "(Customer ID : " + (fetchedCusDetail.value(forKey: "customerNum") as? String)! + ")"
                    self.customerName.text       = fetchedCusDetail.value(forKey: "name") as? String
                    self.CustomerLastLogin.text  = "Last login : " +  UserDefaults.standard.string(forKey: "LastLogin")!
                }
                
                custoID     = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
                TokenNo     = (fetchedCusDetail.value(forKey: "tokenNum") as? String)!
                
            }
        }
        catch{
        }
        do{
            fetchedCusPhoto = try coredatafunction.fetchObjectofImage()
            if fetchedCusPhoto.count == 0 {
                DispatchQueue.main.async { [weak self] in
                    self?.setProfilePhoto()
                }
            }
            else {
                for fetchedCusPic in fetchedCusPhoto
                {
                    let base64String = fetchedCusPic.value(forKey: "custPhoto") as? String
                    if base64String != nil {
                        
                        DispatchQueue.global(qos: .userInteractive).async {
                            let imageData = Data(base64Encoded: base64String!)
                            
                            DispatchQueue.main.async {
                                self.customerImage.image = UIImage(data: imageData!) == nil ? UIImage(named: "User") : UIImage(data: imageData!)
                            }
                        }
//                        let decodedData = NSData(base64Encoded: base64String! , options: [])
//                        if let data = decodedData {
//                            DispatchQueue.main.async { [weak self] in
//                                self?.customerImage.image = UIImage(data: data as Data)
//                            }
//                        } else {
//                            print("error with decodedData")
//                        }
                    } else {
                        print("error with base64String")
                    }
                }
            }
        }
        catch{
        }
        DispatchQueue.main.async { [weak self] in
            self!.versionCheck()
            self?.navViewSettings()
        }
        msgIsSelected.isSelected = false
        if refferenceNumb != ""
        {
            self.present(messages.msg("Kseb bill payment is on pending.Your reference no: \(refferenceNumb)"),
                         animated: true,
                         completion: nil)
        }
        fabView.isHidden = true
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        fabView.addGestureRecognizer(gesture)

    }
    
    //FIXME: - ==== ownAccountDetails() ======
    func ownAccountDetails(){
        parserViewModel.ownAccountDetails(subMode: 1, token: TokenNo, custID: customerId) { getResult in
            
            switch getResult{
            case .success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas,modelKey:"OwnAccountdetails")
                    let exMsg = response.0 // error message
                    let modelInfo = response.1 as? NSDictionary ?? [:]    // get model response
                    
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg,vc:self) { status in
                        let ownAccountDList = modelInfo.value(forKey: "OwnAccountdetailsList") as? [NSDictionary] ?? []
                        self.OwnAccountdetailsList = ownAccountDList.compactMap{$0}
                        self.updateAccountUIDetails(ownAccountDetailsList: self.OwnAccountdetailsList)
                        
                    }
                }
            case .failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
            }
           
            
            
        }
    }
    
    //FIXME: - ==== setAccountBalance() ======
//    func setAccountBalance() {
//
//
//
//        if Reachability.isConnectedToNetwork() {
//            parserViewModel.mainThreadCall {
//                self.present(messages.msg(networkMsg), animated: true, completion: nil)
//            }
//            return
//        }
//
//        let ReqMode    = "14"
//        let tocken     = TokenNo
//        let CusNum     = String(custoID)
//        let SubMode    = "1"
//        let LoanType   = "1"
//
//
//        let urlPath = "/AccountSummary/CustomerLoanAndDepositDetails"
//        let arguments = ["ReqMode"        : ReqMode,
//                         "Token"          : tocken,
//                         "FK_Customer"    : CusNum ,
//                         "SubMode"        : SubMode,
//                         "LoanType"       : LoanType,
//                         "BankKey"        : BankKey,
//                         "BankHeader"     : BankHeader]
//        group.enter()
//
//        parserViewModel.apiParser(urlPath: urlPath, arguments: arguments) { getResult in
//
//            switch getResult{
//            case.success(let datas):
//                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
//
//                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "CustomerLoanAndDepositDetails")
//                    let exMsg = response.0
//                    let modelInfo = response.1 as? NSDictionary ?? [:]
//
//                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
//
//
//                        let CustomerLoanAndDepositDetailsList = modelInfo.value(forKey: "CustomerLoanAndDepositDetailsList") as? [NSDictionary] ?? []
//                        self.self.CustomerLoanAndDepositDetailsList  = []
//                        self.CustomerLoanAndDepositDetailsList = CustomerLoanAndDepositDetailsList
//
//
//                    }
//
//                    self.group.leave()
//                }
//            case.failure(let catchedError):
//                self.parserViewModel.parserErrorHandler(catchedError, vc: self)
//                self.group.leave()
//            }
//
//
//            DispatchQueue.global(qos: .userInteractive).async {
//                self.group.wait()
//
//                DispatchQueue.main.async {
//                    self.updateAccountUIDetails(ownAccountDetailsList: self.CustomerLoanAndDepositDetailsList)
//                }
//            }
//
//        }
//
//    }
    
    func updateAccountUIDetails(ownAccountDetailsList:[NSDictionary]) {
        do {
            
            let acc = fullAccounts.buttonTitle().count >= 8
            
            DispatchQueue.main.async{
                print("aacccc ===== \(acc)")
                if try! coredatafunction.fetchObjectofSettings().count >  0 && acc == true{
                    
                    
                    for ownAccountDetail in ownAccountDetailsList {
                        
                        if ownAccountDetail.value(forKey: "AccountNumber") as! String == fullAccounts.buttonTitle() {
                            
                            self.AccountNumber       = fullAccounts.buttonTitle()
                            
                            DispatchQueue.main.async {
                                self.maskedAccountNumber = self.AccountNumber.masked(9,reversed: true)
                                self.accNumberLabel.text   = "A/C No: " + self.maskedAccountNumber
                                self.ViewBalance.isHidden  = false
                                self.AccNoMaskBtn.isHidden = false
                                
                            }
    //                                        let acc = fullAccounts.buttonTitle()
                            // selected acc module settings
    //                                        var module = AccountNumber.components(separatedBy: CharacterSet.decimalDigits).joined()
    //                                            module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
    //                                            module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
                            
                            self.Balance = ownAccountDetail.value(forKey: "Balance") as! Double
                            self.hideBalanceBtn(self.ViewBalance)

    //                                        let oneAcc = String(acc.dropLast(5))
    //                                        do
    //                                        {
    //                                            let fetchAcc = try coredatafunction.fetchObjectofAcc()
    //                                            for accDetail in fetchAcc
    //                                            {
    //                                                if accDetail.value(forKey: "accNum")! as? String == oneAcc
    //                                                {
    //                                                    if accDetail.value(forKey: "accTypeShort")! as? String == module
    //                                                    {
    //                                                        Balance = Double(accDetail.value(forKey: "availableBalance") as? Float32 ?? 0.00)
    //                                                        hideBalanceBtn(ViewBalance)
    //                                                    }
    //                                                }
    //                                            }
    //                                        }
    //                                        catch
    //                                        {
    //                                        }
                            
                        }
                    }
                }
                else {
                    
                    if ownAccountDetailsList.count > 0{
                    self.AccountNumber       = ownAccountDetailsList[0].value(forKey: "AccountNumber") as? String ?? ""
                    }
                    
                    DispatchQueue.main.async {
                        self.maskedAccountNumber = self.AccountNumber.masked(9,reversed: true)
                        print("waiting account number")
                        self.accNumberLabel.text   = "A/C No: " + self.maskedAccountNumber
                        self.ViewBalance.isHidden  = false
                        self.AccNoMaskBtn.isHidden = false
                        
                    }
                    if ownAccountDetailsList.count > 0{
                    self.Balance = ownAccountDetailsList.first!.value(forKey: "Balance") as! Double
                    }
                    // selected acc module settings
                    var module = self.AccountNumber.components(separatedBy: CharacterSet.decimalDigits).joined()
                        module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
                        module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
                    let oneAcc = String(self.AccountNumber.dropLast(5))
                    coredatafunction.settingsDetails(acc: oneAcc, accTypeShort: module, days: "30", hr: "12", min: "0")
              
                }
            }
           
            }
           
    }
    
    
    func setAccBalance() {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/CustomerLoanAndDepositDetails")!
        
//        let encryptedReqMode    = instanceOfEncryptionPost.encryptUseDES("14", key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(TokenNo, key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedSubMode    = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
//        let encryptedLoanType   = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr")
        let jsonDict            = ["ReqMode"     : "14",
                                   "Token"       : "\(TokenNo)",
                                   "FK_Customer" : "\(custoID)",
                                   "SubMode"     : "1",
                                   "LoanType"    : "1",
                                   "BankKey"     : BankKey,
                                   "BankHeader"  : BankHeader]
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
                DispatchQueue.main.async {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                }
               
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let sttsCode = responseJSONData.value(forKey: "StatusCode") as? Int ?? 10
                    if sttsCode == 0 {
                        let CustomerLoanAndDepositDetails       = responseJSONData.value(forKey: "CustomerLoanAndDepositDetails") as! NSDictionary
                        let CustomerLoanAndDepositDetailsList   = CustomerLoanAndDepositDetails.value(forKey: "CustomerLoanAndDepositDetailsList") as! [NSDictionary]
                        do {
                            if try coredatafunction.fetchObjectofSettings().count ==  0{
                                self.AccountNumber       = CustomerLoanAndDepositDetailsList[0].value(forKey: "AccountNumber") as! String
                                
                                DispatchQueue.main.async {
                                    self.maskedAccountNumber = self.AccountNumber.masked(9,reversed: true)
                                    print("waiting account number")
                                    self.accNumberLabel.text   = "A/C No: " + self.maskedAccountNumber
                                    self.ViewBalance.isHidden  = false
                                    self.AccNoMaskBtn.isHidden = false
                                    
                                }
                                self.Balance = CustomerLoanAndDepositDetailsList[0].value(forKey: "Balance") as! Double
                                
                                // selected acc module settings
                                var module = self.AccountNumber.components(separatedBy: CharacterSet.decimalDigits).joined()
                                    module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
                                    module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
                                let oneAcc = String(self.AccountNumber.dropLast(5))
                                coredatafunction.settingsDetails(acc: oneAcc, accTypeShort: module, days: "30", hr: "12", min: "0")
                            }
                            else {
                                
                                for CustomerLoanAndDepositDetail in CustomerLoanAndDepositDetailsList {
                                    
                                    if CustomerLoanAndDepositDetail.value(forKey: "AccountNumber") as! String == fullAccounts.buttonTitle() {
                                        
                                        self.AccountNumber       = fullAccounts.buttonTitle()
                                        
                                        DispatchQueue.main.async {
                                            self.maskedAccountNumber = self.AccountNumber.masked(9,reversed: true)
                                            self.accNumberLabel.text   = "A/C No: " + self.maskedAccountNumber
                                            self.ViewBalance.isHidden  = false
                                            self.AccNoMaskBtn.isHidden = false
                                            
                                        }
//                                        let acc = fullAccounts.buttonTitle()
                                        // selected acc module settings
//                                        var module = AccountNumber.components(separatedBy: CharacterSet.decimalDigits).joined()
//                                            module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
//                                            module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
                                        
                                        self.Balance = CustomerLoanAndDepositDetail.value(forKey: "Balance") as! Double
                                        self.hideBalanceBtn(self.ViewBalance)

//                                        let oneAcc = String(acc.dropLast(5))
//                                        do
//                                        {
//                                            let fetchAcc = try coredatafunction.fetchObjectofAcc()
//                                            for accDetail in fetchAcc
//                                            {
//                                                if accDetail.value(forKey: "accNum")! as? String == oneAcc
//                                                {
//                                                    if accDetail.value(forKey: "accTypeShort")! as? String == module
//                                                    {
//                                                        Balance = Double(accDetail.value(forKey: "availableBalance") as? Float32 ?? 0.00)
//                                                        hideBalanceBtn(ViewBalance)
//                                                    }
//                                                }
//                                            }
//                                        }
//                                        catch
//                                        {
//                                        }
                                        
                                    }
                                }
                            }
                        }
                        catch{
                            
                        }
                        
                        
                        
                        
                    }
                    else {
                        DispatchQueue.main.async {
                            self.accNumberLabel.text   = ""
                            self.ViewBalance.isHidden  = true
                            self.AccNoMaskBtn.isHidden = true
                            self.view.layoutIfNeeded()
                        }
                    }
                }
                catch{
                }
            }
            
            else{
                DispatchQueue.main.async {
                    self.accNumberLabel.text   = ""
                    self.ViewBalance.isHidden  = true
                    self.AccNoMaskBtn.isHidden = true
                    self.view.layoutIfNeeded()
                }
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    @IBAction func hideBalanceBtn(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.ViewBalance.setTitle("View Balance" , for: .normal)
            self.ViewBalancehide.isHidden = true
        }
        
    }
    
    @IBAction func AccMaskBtn(_ sender: UIButton) {
        if accNumberLabel.text == "A/C No: " + AccountNumber {
            accNumberLabel.text = "A/C No: " + maskedAccountNumber
            sender.setImage(UIImage(named: "eye_fill.png"), for: .normal)
        }
        else {
            accNumberLabel.text = "A/C No: " + AccountNumber
            sender.setImage(UIImage(named: "eye_slash_fill.png"), for: .normal)
        }
    }
    
    @IBAction func ViewBalanceBtn(_ sender: UIButton) {
        if ViewBalance.titleLabel?.text == "View Balance" {
            ViewBalance.setTitle(String(Balance.currencyIN), for: .normal)
            ViewBalancehide.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.homMenuCollection {
            return homeMenuLabels.count
        }
        return homeView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.homMenuCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMenuViewCell", for: indexPath as IndexPath) as! HomeViewCVC
                cell.HomeViewLabel.text = homeMenuLabels[indexPath.row]
                cell.HomeViewIcon.image = homeMenuImages[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeViewCell", for: indexPath as IndexPath) as! HomeViewCVC
            cell.HomeViewLabel.text = homeView[indexPath.row]
            cell.HomeViewIcon.image = homeHdrImage[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.homMenuCollection {
            let yourWidth = collectionView.bounds.width/3.17
            let yourHeight = collectionView.bounds.height/3.17

            return CGSize(width: yourWidth, height: yourHeight)
        }
        let yourWidth = collectionView.bounds.width/(CGFloat(homeView.count) + 0.5)
        let yourHeight = collectionView.bounds.height
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.homMenuCollection {
            switch indexPath.row {
                case 0:
                    self.performSegue(withIdentifier: "MyAccountsSegue", sender: nil)
                    return
                case 1:
                    let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "accSummaryAlert") as! AccDetailsAlertViewController
                        customAlert.providesPresentationContextTransitionStyle = true
                        customAlert.definesPresentationContext = true
                        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        customAlert.delegate = self
                    self.present(customAlert, animated: true, completion: nil)
                    return
                case 2:
                    self.performSegue(withIdentifier: "DashBoardSegue", sender: nil)
                    return
                case 3:
                    self.performSegue(withIdentifier: "bankDetails", sender: nil)
                    return
                case 4:
                    self.performSegue(withIdentifier: "VirtualCard", sender: nil)
                    return
                case 5:
                    self.performSegue(withIdentifier: "dueDateList", sender: nil)
                    return
                case 6:
                    self.performSegue(withIdentifier: "userProfileSegue", sender: nil)
                    return
                case 7:
                    self.performSegue(withIdentifier: "EmiCalcSegue", sender: nil)
                    return
                case 8:
                    if EwireCardService == "1" {
                        self.performSegue(withIdentifier: "EwireCardServiceSegue", sender: nil)
                        return
                    }
                    else {
                        self.performSegue(withIdentifier: "MoreSegue", sender: nil)
                        return
                    }
                default:
                    return
                }
            
        }
        else {
            
            if dmenus.count != 0 {
                switch indexPath.row {
                    case 0:
                            self.performSegue(withIdentifier: "MoneyTransferSegue", sender: self)
                        return
                    case 1:
                        if rechargeValue  == true{
                            let customFundAlert = self.storyboard?.instantiateViewController(withIdentifier: "RechargeAlert") as! RechargeAlertViewController
                                customFundAlert.ksebValue = ksebValue
                                customFundAlert.providesPresentationContextTransitionStyle = true
                                customFundAlert.definesPresentationContext = true
                                customFundAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                                customFundAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                customFundAlert.delegate = self
                            self.present(customFundAlert, animated: true, completion: nil)
                        }
                        else{
                            let customFundAlert = self.storyboard?.instantiateViewController(withIdentifier: "KsebAlert") as! KSEBAlertViewController
                                customFundAlert.providesPresentationContextTransitionStyle = true
                                customFundAlert.definesPresentationContext = true
                                customFundAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                                customFundAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                customFundAlert.delegate = self
                            self.present(customFundAlert, animated: true, completion: nil)
                        }
                        return
                    case 2:
                        fabView.isHidden = false
                        return
                    case 3:
                        self.performSegue(withIdentifier: "quickBalanceSegue", sender: nil)
                        return
                    default:
                        return
                }
            }
            else{
                switch indexPath.row {
                    case 0:
                            self.performSegue(withIdentifier: "MoneyTransferSegue", sender: self)
                        return
                    case 1:
                        fabView.isHidden = false
                        return
                    case 2:
                        self.performSegue(withIdentifier: "quickBalanceSegue", sender: nil)
                        return
                    default:
                        return
                    }
                }
            
        }
    }

    @objc func checkAction(sender : UITapGestureRecognizer) {
        // Do what you want
        fabView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchCusDetails()
        self.ownAccountDetails()
        menuViewLeading.constant = -250
        blurView.isHidden        = true
        let leftSwipe  = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
            leftSwipe.direction  = .left
            rightSwipe.direction = .right
            view.addGestureRecognizer(leftSwipe)
            view.addGestureRecognizer(rightSwipe)
        ksebValue      = false
        rechargeValue  = false
        setIcons()
//        do {
//            if try coredatafunction.fetchObjectofSettings().count ==  0{
               //setAccBalance()
               
//            }
//            else {
//                AccountNumber       = fullAccounts.buttonTitle()
//                maskedAccountNumber = AccountNumber.masked(9,reversed: true)
//                DispatchQueue.main.async { [weak self] in
//                    self?.accNumberLabel.text   = "A/C No: " + self!.maskedAccountNumber
//                    self?.ViewBalance.isHidden  = false
//                    self?.AccNoMaskBtn.isHidden = false
//                }
//                let acc = fullAccounts.buttonTitle()
//                // selected acc module settings
//                var module = acc.components(separatedBy: CharacterSet.decimalDigits).joined()
//                    module = module.replacingOccurrences(of: " (", with: "", options: NSString.CompareOptions.literal, range: nil)
//                    module = module.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
//
//                let oneAcc = String(acc.dropLast(5))
//                do
//                {
//                    let fetchAcc = try coredatafunction.fetchObjectofAcc()
//                    for accDetail in fetchAcc
//                    {
//                        if accDetail.value(forKey: "accNum")! as? String == oneAcc
//                        {
//                            if accDetail.value(forKey: "accTypeShort")! as? String == module
//                            {
//                                Balance = Double(accDetail.value(forKey: "availableBalance") as? Float32 ?? 0.00)
//                                hideBalanceBtn(ViewBalance)
//                            }
//                        }
//                    }
//                }
//                catch
//                {
//                }
//            }
//        }
//        catch{
//
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.setAccBalance()
        
    }
    
    
    
    func fetchCusDetails()
    {
        do
        {
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                TokenNo    = fetchedCusDetail.value(forKey: "tokenNum") as! String
                customerId = String(fetchedCusDetail.value(forKey: "customerId") as! Int)
                pin        = fetchedCusDetail.value(forKey: "pin") as! String
            }
        }
        catch
        {
        }
    }
    var right = 0
    var left  = 0
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer)
    {
        if (sender.direction == .right)
        {
            if right == 0
            {
                showMenu()
            }
        }
        if (sender.direction == .left)
        {
            if left == 0
            {
                hideMenu()
            }
        }
    }
    
    func hideMenu()
    {
        blurView.isHidden           = true
        menuViewLeading.constant    = -250
        UIView.animate(withDuration : 0.5,
                       animations   : {self.view.layoutIfNeeded()})
        right                       = 0
        left                        = 1
        menushowing = !menushowing
    }
    
    func showMenu()
    {
        blurView.isHidden           = false
        menuViewLeading.constant    = 0
        UIView.animate(withDuration : 0.5,
                       animations   : {self.view.layoutIfNeeded()})
        right                       = 1
        left                        = 0
        menushowing = !menushowing
    }
    func navViewSettings(){
        // Create a navView to add to the navigation bar
        let navView = UIView()
        
        // Create the label
        let label               = UILabel()
            label.text          = appName
            label.sizeToFit()
            label.center        = navView.center
            label.font          = UIFont.boldSystemFont(ofSize: 16.0)
            label.textAlignment = NSTextAlignment.center
        
        // Create the image view
        let image       = UIImageView()
            image.image = #imageLiteral(resourceName: "AppIcon")

        ////    MANNARKKAD bank
        // To maintain the image's aspect ratio:
        let imageAspect = (image.image!.size.width/image.image!.size.height) * 1.0
        // Setting the image frame so that it's immediately before the text:
            image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect,
                                 y: label.frame.origin.y,
                                 width: label.frame.size.height*imageAspect,
                                 height: label.frame.size.height)
        
        ////       ccscb
        //        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*2.3,
        //                              y: label.frame.origin.y-label.frame.size.height*0.6,
        //                              width: label.frame.size.height*2,
        //                              height: label.frame.size.height*2)
        
        image.contentMode = UIView.ContentMode.scaleAspectFit
        
        // Add both the label and image view to the navView
        navView.addSubview(label)
        navView.addSubview(image)
        
        // Set the navigation bar's navigation item's titleView to the navView
        bankName.titleView = navView
        
        // Set the navView's frame to fit within the titleView
        navView.sizeToFit()

    }
    
    func setProfilePhoto() {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/Image/CustomerImageDets")!
        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
        let jsonDict            = ["FK_Customer":encryptedCusNum,
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
                DispatchQueue.main.async {
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            let httpResponse = response as! HTTPURLResponse
            if (responseJSON as? [String: Any]) != nil && httpResponse.statusCode == 200 {
                do {
                    let responseJSONData = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let sttsCode = responseJSONData.value(forKey: "StatusCode") as? Int ?? 10
                    if sttsCode==0 {
                        let imgDets  = responseJSONData.value(forKey: "CustomerImageDets") as! NSDictionary
                        let base64String = imgDets.value(forKey: "CusImage") as? String

                        if base64String != nil {
                            coredatafunction.imageData(custPhoto: base64String!)
                            DispatchQueue.global(qos: .userInteractive).async {
                                let imageData = Data(base64Encoded: base64String!)
                                
                                DispatchQueue.main.async {
                                    self.customerImage.image = UIImage(data: imageData!) == nil ? UIImage(named: "User") : UIImage(data: imageData!)
                                }
                            }
                        } else {
                            print("error with base64String")
                        }
                    }
                }
                catch{
                }
            }
        }
        task.resume()
    }
    
    @IBAction func fabButton(_ sender: UIButton) {
        fabView.isHidden = false
    }
   
    @IBAction func duedateFabButton(_ sender: UIButton) {
        fabView.isHidden = true
        self.performSegue(withIdentifier: "dueDateList", sender: nil)
    }
    
    @IBAction func offersFabButton(_ sender: UIButton) {
        fabView.isHidden = true
        msgIsSelected.isSelected = false
        self.performSegue(withIdentifier: "displayMessagesAndOffers", sender: nil)
    }
    
    @IBAction func msgFabButton(_ sender: UIButton) {
        fabView.isHidden = true
        msgIsSelected.isSelected = true
        self.performSegue(withIdentifier: "displayMessagesAndOffers", sender: nil)
    }
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from home screen to accInfo screen
        if segue.identifier == "EwireCardServiceSegue"
        {
//            let vw = segue.destination as! PassBook
            let vw = segue.destination as! WalletServicesViewController

            vw.customerId = customerId
            vw.TokenNo    = TokenNo
        }
        if segue.identifier == "rechHistorySegue"
        {
//            let vw = segue.destination as! PassBook
            let vw = segue.destination as! RechargeHistoryViewController

            vw.customerId = customerId
            vw.TokenNo    = TokenNo
        }
        
        
        if segue.identifier == "userProfileSegue"{
            let vc = segue.destination as! ProfileViewController
            vc.accountNumber = AccountNumber
        }
        
        if segue.identifier == "passbook"
        {
//            let vw = segue.destination as! PassBook
            let vw = segue.destination as! PassBookViewController

            vw.pin        = pin
            vw.customerId = customerId
            vw.TokenNo    = TokenNo
        }
        if segue.identifier == "statementSegue"
        {
//            let vw = segue.destination as! PassBook
            let vw = segue.destination as! StatementVDViewController

            vw.customerId = customerId
            vw.TokenNo    = TokenNo
        }
        if segue.identifier == "shareAccount"
        {
            let vw = segue.destination as! ShareAccountsViewController

            vw.customerId = customerId
            vw.TokenNo    = TokenNo
        }
        if segue.identifier == "quickBalanceSegue"
        {
//            let vw = segue.destination as! PassBook
            let vw = segue.destination as! quickBalViewController

            vw.pin        = pin
            vw.customerId = customerId
            vw.TokenNo    = TokenNo
        }
        // from home screen to accInfo screen
        if segue.identifier == "MyAccountsSegue"
        {
            let vw = segue.destination as! MyAccViewController
            vw.accountInfo = fetchedCusDetails
        }
            // from home screen to search screen
//        else if segue.identifier == "Search"
//        {
//            let vw = segue.destination as! StatementViewController
//            vw.cusInfo    = fetchedCusDetails
//            vw.pin        = pin
//            vw.customerId = customerId
//            vw.TokenNo    = TokenNo
//        }
            // from home screen to recharge screen
        else if segue.identifier == "Recharge"
        {
            let rech = segue.destination as! ReachargeViewController
            rech.rechargeType = rechargeMenu
            rech.pin          = pin
            rech.TokenNo      = TokenNo
            rech.customerId   = customerId
            if rechargeMenu == "Prepaid"
            {
                rech.fullOp = prepaidRechargeValues
            }
            else if rechargeMenu ==  "Postpaid"
            {
                rech.fullOp = postpaidRechargeValues
            }
            else if rechargeMenu == "DTH"
            {
                rech.fullOp = dthRechargeValues
            }
            else if rechargeMenu == "Landline"
            {
                rech.fullOp = landlineRechargeValues
            }
            else if rechargeMenu == "Data Card"
            {
                rech.fullOp = datacardRechargeValues
            }
        }
            // from home screen to kseb screen
        else if segue.identifier == "KSEB"
        {
            let kseb = segue.destination as! KSEBViewController
            kseb.pin        = pin
            kseb.TokenNo    = TokenNo
            kseb.customerId = customerId
        }
            // from home screen to changePin screen
        else if segue.identifier == "changePin"
        {
            let pinChange = segue.destination as! ChangePinViewController
            pinChange.pin        = pin
            pinChange.TokenNo    = TokenNo
            pinChange.customerId = customerId
        }
            // from home screen to bill status screen
        else if segue.identifier == "BillStatus"
        {
            let pinChange = segue.destination as! KsebBillStatusViewController
            pinChange.pin        = pin
            pinChange.TokenNo    = TokenNo
            pinChange.customerId = customerId
        }
            // from home screen to money transfer screen screen
        else if segue.identifier == "MoneyTransferSegue"
        {
            let MoneyTransfer = segue.destination as! MoneyTransferViewController
            MoneyTransfer.dmenus     = transDmenus
            MoneyTransfer.pin        = pin
            MoneyTransfer.TokenNo    = TokenNo
            MoneyTransfer.customerId = customerId
            if transDmenus.count == 0{
                MoneyTransfer.ownAccMoneyTransfer = true
            }
            else{
                MoneyTransfer.ownAccMoneyTransfer = false
            }
            
        }
            // from home screen to ownbank screen
            
        else if segue.identifier == "OwnBank"
        {
            let pinChange = segue.destination as! OwnBankOtherAccountViewController
            pinChange.pin        = pin
            pinChange.TokenNo    = TokenNo
            pinChange.customerId = customerId
        }
            // from home screen to settings screen
        else if segue.identifier == "Settings"
        {
            let settingDateTime = segue.destination as! SettingsViewController
            settingDateTime.pin        = pin
            settingDateTime.TokenNo    = TokenNo
            settingDateTime.customerId = customerId
        }
            // from home screen to settings screen
        else if segue.identifier == "displayMessagesAndOffers"
        {
            let msgOffr = segue.destination as! messagesViewController
            if msgIsSelected.isSelected == true
            {
                msgOffr.msgOrOffer = 0
            }
            else
            {
                msgOffr.msgOrOffer = 1
            }
        }
        self.view.isUserInteractionEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func homeScreen(_ otp:UIStoryboardSegue)
    {
    }
    func versionCheck()
    {
        if !Reachability.isConnectedToNetwork()
        {
            
            let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let encryptedVersion = instanceOfEncryptionPost.encryptUseDES(text, key: "Agentscr") as String
            let encrypedOsType = instanceOfEncryptionPost.encryptUseDES("1", key: "Agentscr") as String
            //// url settings
            let url = URL(string: BankIP + APIBaseUrlPart + "/Checkstatus?versionNo=\(encryptedVersion)&OStype=\(encrypedOsType)&BankKey=\(BankKey)")!
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let task = session.dataTask(with: url) { data,response,error in
                if let error = error
                {
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.present(errorMessages.error(error as NSError), animated: true, completion: nil)
                        self?.blurView.isHidden = true
                    }
                    return
                }
                let dataInString = String(data: data!, encoding: String.Encoding.utf8)
                if dataInString == "10"
                {
                    DispatchQueue.main.async { [weak self] in
                        let alert = UIAlertController(title: "New Version Available",
                                                      message: "New Version Of This Application Is Available.\n Click OK To Upgrade Now.",
                                                      preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK",
                                                      style: UIAlertAction.Style.default,
                                                      handler: { (action:UIAlertAction!) -> Void in
                            //after user press ok, the following code will be execute
                            if let url = URL(string: appLink), UIApplication.shared.canOpenURL(url) {
                               // Attempt to open the URL.
                               UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                                  if success {
                                      print("Launching \(url) was successful")
                               }})
                            }

                            UIApplication.shared.canOpenURL(NSURL(string: appLink)! as URL)
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
                                self!.performSegue(withIdentifier: "QuitToLogin", sender: nil)
                            })                                                        
                        }))
                        self!.present(alert,animated: true,completion: nil)
                    }
                }
                else
                {
                }
            }
            task.resume()
        }
    }
    
    func setIcons()
    {
        transDmenus = []
        dmenus      = []
        Images      = []
        do
        {
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                dmenuvalue = fetchedCusDetail.value(forKey: "dMenu") as! String
            }
            let dmenuLowercase = dmenuvalue.lowercased()
            let dmenuDic = convertToDictionary(text: dmenuLowercase)!
            for (key, value) in dmenuDic
            {
                if "\(value)" == "1"
                {
                    switch "\(key)"
                    {
                    case "recharge":
                        dmenus.append(contentsOf: Recharge)
                        rechargeValue  = true
                        Images.append(contentsOf: rechargeImg)
                    case "kseb":
                        dmenus.append("KSEB")
                        ksebValue      = true
                        Images.append(#imageLiteral(resourceName: "kseb"))
                    case "ownimps":
                        transDmenus.append("IMPS")
                    case "neft":
                        transDmenus.append("NEFT")
                    case "rtgs":
                        transDmenus.append("RTGS")
                    case "imps":
                        transDmenus.append("QUICK PAY")
                    default:
                        print("no dmenu")
                    }
                }
            }
            if dmenus.count == 0 {
                homeView = ["Money Transfer","Notification / Messages","Quick Balance"]
                homeHdrImage = [UIImage(imageLiteralResourceName: "ic_hdr_money_transfer.png"), UIImage(imageLiteralResourceName: "ic_hdr_notification.png"), UIImage(imageLiteralResourceName: "ic_hdr_quick_balance.png")]
            }
            else {
                homeView = ["Money Transfer","Recharge / Pay Bill","Notification / Messages","Quick Balance"]
                homeHdrImage = [UIImage(imageLiteralResourceName: "ic_hdr_money_transfer.png"), UIImage(imageLiteralResourceName: "ic_hdr_recharge.png"),  UIImage(imageLiteralResourceName: "ic_hdr_notification.png"), UIImage(imageLiteralResourceName: "ic_hdr_quick_balance.png")]
            }
        }
        catch
        {
        }
        // recharge pay billcase
//        if dmenus.count == 0
//        {
//            homeProfLabel.text = "Profile"
//            homeProfImg.image = UIImage(named:"usersprofile")
//        }
//        else{
//            homeProfLabel.text = "Recharge/Pay Bill"
//            homeProfImg.image = UIImage(named:"home_recharge")
//
//        }
    }
    
    // function for convert string to dictionary format
    func convertToDictionary(text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8)
        {
            do
            {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }
            catch
            {
                self.present(messages.msg(error.localizedDescription), animated: true, completion: nil)
            }
        }
        return nil
    }
    
    @IBAction func menu(_ sender: UIBarButtonItem)
    {
        if (menushowing)
        {
            hideMenu()
        }
        else
        {
            showMenu()
        }
    }
    
    @IBAction func menuPinChange(_ sender: UIButton)
    {
        hideMenu()
        self.performSegue(withIdentifier: "changePin", sender: nil)
    }
    
    @IBAction func menuProfile(_ sender: UIButton){
        hideMenu()
        self.performSegue(withIdentifier: "userProfileSegue", sender: nil)
    }

    @IBAction func menuSettings(_ sender: UIButton)
    {
        hideMenu()
        self.performSegue(withIdentifier: "Settings", sender: nil)
    }
    
    //    let h = UISwipeGestureRecognizer()
    @IBAction func menuMessages(_ sender: UIButton)
    {
        msgIsSelected.isSelected = true
        hideMenu()
        
        self.performSegue(withIdentifier: "displayMessagesAndOffers", sender: nil)
    }
    
    @IBAction func menuOffers(_ sender: UIButton)
    {
        msgIsSelected.isSelected = false
        hideMenu()
        self.performSegue(withIdentifier: "displayMessagesAndOffers", sender: nil)
        
    }
    
    @IBAction func menuKsebBillStatus(_ sender: UIButton)
    {
        hideMenu()
        self.performSegue(withIdentifier: "BillStatus", sender: nil)
    }
    
    @IBAction func menuMore(_ sender: UIButton)
    {
        hideMenu()
        self.performSegue(withIdentifier: "MoreSegue", sender: nil)
        
    }
    @IBAction func menuQuit(_ sender: UIButton)
    {
        hideMenu()
        let quitopt = UIAlertController(title: "",
                                        message: "Do You Want To Quit App?",
                                        preferredStyle: UIAlertController.Style.alert)
        quitopt.addAction(UIAlertAction(title: "No",
                                        style: UIAlertAction.Style.default,
                                        handler: nil))
        quitopt.addAction(UIAlertAction(title: "Yes",
                                        style: UIAlertAction.Style.default,
                                        handler: { (action:UIAlertAction!) -> Void in
                                            //after user press ok, the following code will be execute
                                            self.performSegue(withIdentifier: "QuitToLogin",
                                                              sender: nil)
                                            UIControl().sendAction(#selector(NSXPCConnection.suspend),
                                                                   to: UIApplication.shared, for: nil)}))
        self.present(quitopt, animated: true, completion: nil)
    }
    
    
    @IBAction func menuDueDate(_ sender: UIButton) {
        hideMenu()
        self.performSegue(withIdentifier: "dueDateList", sender: nil)

    }
    
    
    
    
    
}

































extension HomeViewController: AccDetailAlertDelegate {
    func cancelButtonTapped() {
    }
    func passBookButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "passbook", sender: self)
        })
    }
    func noticeButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "NoticeDetails", sender: nil)
        })
    }
    func standingInstructionButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "StandingInstruction", sender: nil)
        })
    }
    func searchButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "statementSegue", sender: self)
    //        self.performSegue(withIdentifier: "Search", sender: self)
        })
    }
    func accSummaryButtonTapped(){
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "shareAccount", sender: self)
        })
    }
}
extension HomeViewController: FundTransferAlertDelegate{
    func cancelTapped() {
        
    }
    
    func otherBankButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "OtherBank", sender: self)
        })
    }
    func ownBankButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "OwnBank", sender: self)
        })
    }
}


extension HomeViewController: RechargeAlertDelegate {
    func prePaidButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "Recharge", sender: self)
        })
        self.rechargeMenu = "Prepaid"
    }
    
    func dthButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "Recharge", sender: self)
        })
        self.rechargeMenu = "DTH"
    }
    
    func landLineButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "Recharge", sender: self)
        })
        self.rechargeMenu = "Landline"
    }
    
    func postPaidButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "Recharge", sender: self)
        })
        self.rechargeMenu = "Postpaid"
    }
    
    func dataCardButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "Recharge", sender: self)
        })
        self.rechargeMenu = "Data Card"
    }
    
    func ksebButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "KSEB", sender: self)
        })
        self.rechargeMenu = "KSEB"
    }
    
    func rechargeHistoryButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "rechHistorySegue", sender: self)
        })
    }
    
}
extension HomeViewController: KSEBAlertDelegate{
    func cancelBtnTapped() {
    
    }
    
    func KSEBButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.4, execute: {
            self.performSegue(withIdentifier: "KSEB", sender: self)
        })
        self.rechargeMenu = "KSEB"
    }
}

