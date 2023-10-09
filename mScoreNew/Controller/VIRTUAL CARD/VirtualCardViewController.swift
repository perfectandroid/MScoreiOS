//
//  VirtualCardViewController.swift
//  mScoreNew
//
//  Created by Perfect on 17/09/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import Foundation
class VirtualCardViewController: NetworkManagerVC {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bankIcon: UIImageView!{
        didSet{
            bankIcon.layer.cornerRadius = bankIcon.frame.size.width/3
            bankIcon.clipsToBounds = true
            SetImage(ImageCode: AppIconImageCode, ImageView: bankIcon, Delegate: self)
        }
    }
    @IBOutlet weak var bankName: UILabel!{
        didSet{
            bankName.text = appName
        }
    }
    @IBOutlet weak var cusPhoto: UIImageView!{
        didSet{
            cusPhoto.contentMode = .scaleToFill
        }
    }
    @IBOutlet weak var cusName: UILabel!
    @IBOutlet weak var cusID: UILabel!
    @IBOutlet weak var generID: UILabel!
    @IBOutlet weak var cusAddress: UILabel!
    @IBOutlet weak var cusPhone: UILabel!
    @IBOutlet weak var barCodeImg: UIImageView!
    @IBOutlet weak var qrCodeImg: UIImageView!
    @IBOutlet weak var purposeHeader: UILabel!{
        didSet{
            purposeHeader.underline()
        }
    }
    @IBOutlet weak var purposePoints: UITextView!{
        didSet{
            purposePoints.isEditable = false
            purposePoints.text = "\u{2605} Streamlines transactions \n\u{2605} Enable a single point of contact for credit and debit \n\u{2605} Strengthen your loan portfolio \n\u{2605} Eliminate the long queues"
        }
    }
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var custoNum        = String()
    var custoName       = String()
    var custoAddress    = String()
    var custoPhoneNum   = String()
    var tokenNum        = String()
    var BarcodeFormat   = String()
    var CusImage = ""
    var custoID         = Int()
    var fetchedCusDetails       :[Customerdetails]  = []
    var fetchedCusPhoto         :[CustomerPhoto]    = []
    var instanceOfEncryptionPost    : EncryptionPost    = EncryptionPost()
    let group = DispatchGroup()
    private let parserViewModel : ParserViewModel = ParserViewModel()
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do{
            fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                custoNum      = (fetchedCusDetail.value(forKey: "customerNum") as? String)!
                custoID       = (fetchedCusDetail.value(forKey: "customerId") as? Int)!
                custoName     = (fetchedCusDetail.value(forKey: "name") as? String)!
                custoAddress  = (fetchedCusDetail.value(forKey: "address1") as? String)!
                custoPhoneNum = (fetchedCusDetail.value(forKey: "mobileNum") as? String)!
                tokenNum      = (fetchedCusDetail.value(forKey: "tokenNum") as? String)!
            }
        }
        catch
        {
        }
       
        cusID.text       = ": "+custoNum
        cusName.text     = ": "+custoName
        cusAddress.text  = ": "+custoAddress
        cusPhone.text    = ": "+custoPhoneNum

        let date                = Date()
        let format              = DateFormatter()
            format.dateFormat   = "MM-dd"
        let formattedDate       = format.string(from: date)
        let words               = formattedDate.split(separator: "-")
        generID.text            = words[1] + custoNum + words[0]
        frontView.isHidden      = false
        backView.isHidden       = true
        blurView.isHidden       = true
        activityIndicator.stopAnimating()
        
        do{
            fetchedCusPhoto = try coredatafunction.fetchObjectofImage()
            if fetchedCusPhoto.count == 0{
                DispatchQueue.main.async { [weak self] in
                    self!.blurView.isHidden       = false
                    self!.activityIndicator.startAnimating()
                    self!.setImageOfClientAPI()
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
                                self?.cusPhoto.image = UIImage(data: data as Data)
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
          setGenerateIDAPI()
        //setGeneratedID()
//        barCodeImg.isHidden = true
    }
    
    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
   
    @IBAction func segmentSelection(_ sender: UISegmentedControl)
    {
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
            
            self.parserViewModel.mainThreadCall {
                self.frontView.isHidden = false
                self.backView.isHidden  = true
            }
                
            case 1:
            self.parserViewModel.mainThreadCall {
                self.frontView.isHidden = true
                self.backView.isHidden  = false
            }
            default:
                break;
        }
    }
    
    @IBAction func barCodeView(_ sender: UIButton) {
        let alert = UIAlertController(title: "BarCode", message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        let image = UIImageView(image: UIImage(barcode: BarcodeFormat)) // yields UIImage?
//        var image = UIImageView(image: generateBarcode(from: BarcodeFormat, size: qrCodeImg.frame.size))
//        let image = UIImageView(frame: CGRect(x: 10, y: 10, width: alert.view.bounds.width, height: 40))
//            image.image = UIImage(barcode: BarcodeFormat)
            alert.view.addSubview(image)
            image.translatesAutoresizingMaskIntoConstraints = false
            alert.view.addConstraint(NSLayoutConstraint(item: image,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: alert.view,
                                                        attribute: .centerX,
                                                        multiplier: 1,
                                                        constant: 0))
            alert.view.addConstraint(NSLayoutConstraint(item: image,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: alert.view,
                                                        attribute: .centerY,
                                                        multiplier: 1,
                                                        constant: 0))
            alert.view.addConstraint(NSLayoutConstraint(item: image,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: alert.view,
                                                        attribute: .width,
                                                        multiplier: 1 ,
                                                        constant:0))
        alert.view.addConstraint(NSLayoutConstraint(item: image,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: alert.view.frame.height/6))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func qrCodeView(_ sender: UIButton) {
    let alert = UIAlertController(title: "QRCode", message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
    let image = UIImageView(image: createQRFromString(BarcodeFormat, size: qrCodeImg.frame.size))
        alert.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addConstraint(NSLayoutConstraint(item: image,
                                                    attribute: .centerX,
                                                    relatedBy: .equal,
                                                    toItem: alert.view,
                                                    attribute: .centerX,
                                                    multiplier: 1,
                                                    constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: alert.view,
                                                    attribute: .centerY,
                                                    multiplier: 1,
                                                    constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: 150))
        alert.view.addConstraint(NSLayoutConstraint(item: image,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: 150))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createQRFromString(_ str: String, size: CGSize) -> UIImage
    {
        let stringData = str.data(using: .utf8)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
            qrFilter.setValue(stringData, forKey: "inputMessage")
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        let minimalQRimage = qrFilter.outputImage!
        // NOTE that a QR code is always square, so minimalQRimage..width === .height
        let minimalSideLength = minimalQRimage.extent.width
        let smallestOutputExtent = (size.width < size.height) ? size.width : size.height
        let scaleFactor = smallestOutputExtent / minimalSideLength
        let scaledImage = minimalQRimage.transformed(
            by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        return UIImage(ciImage: scaledImage,
                       scale: UIScreen.main.scale,
                       orientation: .up)
    }
    
    func updateImageViewUIDetails(imageName:String) {
        
        if let formatted_Data = Data(base64Encoded: imageName){
            
            self.cusPhoto.image = UIImage(data: formatted_Data)
            
        }
        
    }
    
    //FIXME: - ====== setImageOfClientAPI() ========
    func setImageOfClientAPI() {
        
        // network reachability checking
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = "/Image/CustomerImageDets"
        let arguMents = ["FK_Customer":"\(custoID)",
                         "BankKey" : BankKey,
                         "BankHeader" : BankHeader]
        
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler( datas: datas, modelKey: "CustomerImageDets")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg,vc: self,msgShow:false) { status in
                        
                        self.CusImage = modelInfo.value(forKey: "CusImage") as? String ?? ""
                    }
                    
                    self.group.leave()
                }
            case.failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
                self.group.leave()
            }
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.group.wait()
                
                DispatchQueue.main.async {
                    self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
                        self.updateImageViewUIDetails(imageName: self.CusImage)
                }
                
            }
            
        }
        
    }
    

    func setImageOfCustomer() {
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
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/Image/CustomerImageDets")!
        let encryptedCusNum     = String(custoID)
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
                                 delegateQueue: nil)
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
                        let imgDets  = responseJSONData.value(forKey: "CustomerImageDets") as! NSDictionary
                        let base64String = imgDets.value(forKey: "CusImage")
                        if base64String != nil {
                            DispatchQueue.main.async { [weak self] in
                                self?.activityIndicator.stopAnimating()
                                self?.blurView.isHidden = true
                            }
                            let decodedData = NSData(base64Encoded: base64String! as! String, options: [])
                            if let data = decodedData {
                                DispatchQueue.main.async { [weak self] in
                                    self?.cusPhoto.image = UIImage(data: data as Data)
                                }
                            } else {
                                print("error with decodedData")
                            }
                        } else {
                            DispatchQueue.main.async { [weak self] in
                                self?.activityIndicator.stopAnimating()
                                self?.blurView.isHidden = true
                            }
                            print("error with base64String")
                        }
                    }
                    else {
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            self?.blurView.isHidden = true
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
    
    
    //FIXME: - ======== updateUIDetails() =========
    fileprivate func updateUIDetails(){
         
        self.qrCodeImg.image  = self.createQRFromString(self.BarcodeFormat, size: self.qrCodeImg.frame.size)
        self.barCodeImg.image = self.generateBarcode(from: self.BarcodeFormat,size: self.barCodeImg.frame.size)
        
    }
    
    //FIXME: - ======== setGenerateIDAPI() =========
    fileprivate func setGenerateIDAPI(){
        
        // network reachability checking
        self.displayIndicator(activityView: activityIndicator, blurview: blurView)
        if Reachability.isConnectedToNetwork() {
            self.removeIndicator(showMessagge: true, message: networkMsg,activityView: activityIndicator, blurview: blurView)
            return
        }
        
        let urlPath = "/AccountSummary/BarcodeFormatDet"
        
        let arguMents = ["ReqMode":"9",
                         "FK_Customer":"\(custoID)",
                         "Token":tokenNum,
                         "BankKey" : BankKey,
                         "BankHeader" : BankHeader]
        
        group.enter()
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "BarcodeFormatDet")
                    
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        self.BarcodeFormat = modelInfo.value(forKey: "BarcodeFormat") as? String ?? ""
                        
                    }
                    
                    self.group.leave()
                    
                }
            case.failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
                self.group.leave()
            }
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
                self.group.wait()
                
                DispatchQueue.main.async {
                    self.removeIndicator(showMessagge: false, message: "", activityView: self.activityIndicator, blurview: self.blurView)
                    
                    self.updateUIDetails()
                    do{
                        print("===== successfully updated UI =====")
                    }
                }
            }
            
        }
        
    }
    
    
//    func setGeneratedID() {
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
//        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/BarcodeFormatDet")!
//        let encryptedReqMode    = instanceOfEncryptionPost.encryptUseDES("9", key: "Agentscr")
//        let encryptedCusNum     = instanceOfEncryptionPost.encryptUseDES(String(custoID), key: "Agentscr")
//        let encryptedTocken     = instanceOfEncryptionPost.encryptUseDES(tokenNum, key: "Agentscr")
//
//        let jsonDict            = ["ReqMode":encryptedReqMode,
//                                "FK_Customer":encryptedCusNum,
//                                "Token":encryptedTocken,
//                                "BankKey" : BankKey,
//                                "BankHeader" : BankHeader]
//        let jsonData            = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
//        var request             = URLRequest(url: url)
//            request.httpMethod  = "post"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody    = jsonData
//        let session = URLSession(configuration: .default,
//                                 delegate: self,
//                                 delegateQueue: nil)
//        let task = session.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
//                DispatchQueue.main.async { [weak self] in
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
//                    if sttsCode==0 {
//                        DispatchQueue.main.async { [weak self] in
//                            let BarcodeFormatDet  = responseJSONData.value(forKey: "BarcodeFormatDet") as! NSDictionary
//                            self!.BarcodeFormat = BarcodeFormatDet.value(forKey: "BarcodeFormat") as! String
//
//                            self!.qrCodeImg.image  = self?.createQRFromString(self!.BarcodeFormat, size: self!.qrCodeImg.frame.size)
//                            self!.barCodeImg.image = self!.generateBarcode(from: self!.BarcodeFormat,size: self!.barCodeImg.frame.size)
//                        }
//
//                    }
//                    else {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
//                        }
//                    }
//                }
//                catch{
//                    DispatchQueue.main.async { [self] in
//                        self.blurView.isHidden = true
//                        self.activityIndicator.stopAnimating()
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
    
    
    
    
    func generateBarcode(from string: String,size: CGSize) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

      if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
        filter.setValue(7.00, forKey: "inputQuietSpace")
        filter.setValue(data, forKey: "inputMessage")

        let transform = CGAffineTransform(scaleX: barCodeImg.frame.height, y: barCodeImg.frame.height)

        if let output = filter.outputImage?.transformed(by: transform) {
//            let minimalSideLength = output.extent.width
//            let smallestOutputExtent = (size.width < size.height) ? size.width : size.height
//            let scaleFactor = smallestOutputExtent / minimalSideLength
//            let scaledImage = output.transformed(
//                by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
//            return UIImage(ciImage: scaledImage,
//                           scale: UIScreen.main.scale,
//                           orientation: .up)
          return UIImage(ciImage: output)
        }
      }

      return nil
    }
}
