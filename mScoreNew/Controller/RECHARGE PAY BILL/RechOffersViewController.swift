//
//  RechOffersViewController.swift
//  mScoreNew
//
//  Created by Perfect on 26/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit
import Combine

protocol custIDDelegate:AnyObject{
    func getCustId(id:String)
}

class RechOffersViewController: NetworkManagerVC, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var offTypeSegment: UISegmentedControl!{
        didSet{
            offTypeSegment.isHidden = true
        }
    }
    @IBOutlet weak var offersTbl: UITableView!{
        didSet{
            offersTbl.estimatedRowHeight = 85
            offersTbl.rowHeight = UITableView.automaticDimension
        }
    }
    @IBOutlet weak var offershdrCollection: UICollectionView!

    var operIds             = String()
    var operatext           = String()
    var TokenNo             = String()
    var pin                 = String()
    var rechargeType        = String()
    var fullOp              = [String]()
    var segments            = [String]()
    var instanceOfEncryption: EncryptionPost = EncryptionPost()
    var operatextDic        = NSDictionary()
    var offerList           = [NSDictionary]()
    var amount              = String()
    var selectedIndexPath   = Int()
    var custID : String?
    
    weak var delegate : custIDDelegate?
    
    private var parserViewModel : ParserViewModel = ParserViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headerLabel.text = operatext
        //RechargeOffers()
       
        RechargeOfferApi()
    }
    
    
    
    fileprivate func RechargeOfferApi(){
        // network reachability checking
       
        if Reachability.isConnectedToNetwork() {
            parserViewModel.mainThreadCall {
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        
        let urlPath = "/Recharge/RechargeOffers"
        let arguMents = ["Operator":operIds,
                         "BankKey" : BankKey,
                         "BankHeader" : BankHeader]
        
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let response = self.parserViewModel.resultHandler(datas: datas, modelKey: "RechargeOffersDets")
                    let exMsg = response.0
                    let modelInfo = response.1 as? NSDictionary ?? [:]
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg, vc: self) { status in
                        let OffersDetails = modelInfo.value(forKey: "OffersDetails") as? String ?? ""
                        let fullOffersDetails = "[{ " + OffersDetails.replacingOccurrences(of: "\r\n", with: "", options: .literal, range: nil) + " }]"
                        let fullOffersDetailsList = fullOffersDetails.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
                        
                        let data = fullOffersDetailsList.data(using: .utf8)
                        
                        self.segments = []
                        self.offerList = []
                        
                        do{
                            
                            let resultParsed = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [NSDictionary] ?? []
                            self.operatext = resultParsed[0].allKeys[0] as? String ?? ""
                            self.operatextDic = resultParsed[0].value(forKey: self.operatext) as?  NSDictionary ?? [:]
                            print(self.operatextDic)
                            
                            
                            self.parserViewModel.mainThreadCall {
                                for (key, value) in self.operatextDic {
                                    if key as! String != "key" {
                                        self.segments.append(key as! String)
                                        if (key as! String) == self.segments[0] {
                                            self.offerList = value as! [NSDictionary]
                                            self.offersTbl.reloadData()
                                        }
                                    }
                                }
//                                self.selectedIndexPath = 0
//                                self.offershdrCollection.reloadData()
                            }
//                            self.operatextDic.enumerated().forEach { (key,item) in
//
//                                let dicKey = key as? String ?? ""
//
//                                if dicKey != "key"{
//                                    self.segments.append(dicKey)
//
//                                    if dicKey == self.segments.first{
//                                        self.offerList = item as? [NSDictionary] ?? []
//                                        self.parserViewModel.mainThreadCall {
//                                            self.offersTbl.reloadData()
//                                        }
//
//                                    }
//                                }
//                            }
                            self.selectedIndexPath = 0
                        self.parserViewModel.mainThreadCall {
                            self.offershdrCollection.reloadData()
                        }
                            
                        }catch{
                            print(error)
                        }
                    }
                }
            case.failure(let errorCatched):
                self.parserViewModel.parserErrorHandler(errorCatched, vc: self)
            }
            
        }
    }
    
    
    func RechargeOffers() {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async { [weak self] in
                self?.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/Recharge/RechargeOffers")!
        let jsonDict            = ["Operator":operIds,
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
                DispatchQueue.main.async { [weak self] in
                    self!.present(errorMessages.error(error! as NSError), animated: true, completion: nil)

//                    self?.activityIndicator.stopAnimating()
//                    self?.blurView.isHidden = true
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
                        let RechargeOffersDets  = responseJSONData.value(forKey: "RechargeOffersDets") as! NSDictionary
                        let OffersDetails = RechargeOffersDets.value(forKey: "OffersDetails") as! String
                        let fullOffersDetails = "[{ " + OffersDetails.replacingOccurrences(of: "\r\n", with: "", options: .literal, range: nil) + " }]"
                        let fullOffersDetailsList = fullOffersDetails.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
                        segments = []
                        offerList = []
                        let data = fullOffersDetailsList.data(using: .utf8)!
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [NSDictionary]
                            {
                                operatext = jsonArray[0].allKeys[0] as! String
                                operatextDic  = jsonArray[0].value(forKey: operatext) as! NSDictionary
                                
                                DispatchQueue.main.async { [weak self] in
                                    
                                    for (key, value) in operatextDic {
                                        if key as! String != "key" {
                                            segments.append(key as! String)
                                            if (key as! String) == segments[0] {
                                                offerList = value as! [NSDictionary]
                                                offersTbl.reloadData()
                                            }
                                        }
                                    }
                                    self!.selectedIndexPath = 0
                                    self!.offershdrCollection.reloadData()
//                                    self!.offTypeSegment.replaceSegments(segments: segments)
//                                    self!.offTypeSegment.selectedSegmentIndex = 0
//                                    self!.offTypeSegment.isHidden = false
                                    
                                }
                            } else {
                                print("bad json")
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                    else {
                        let RechargeOffersDets  = responseJSONData.value(forKey: "RechargeOffersDets") as Any
                        if RechargeOffersDets as? NSDictionary != nil {
                                let RechargeOffersDet  = responseJSONData.value(forKey: "RechargeOffersDets") as! NSDictionary
                            let ResponseMessage =  RechargeOffersDet.value(forKey: "ResponseMessage") as! String

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
                }
            }
            else{
                DispatchQueue.main.async { [weak self] in
                    self?.present(messages.msg(String(httpResponse.statusCode)), animated: true,completion: nil)
                }
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = offersTbl.dequeueReusableCell(withIdentifier: "offerListCell") as! OfferListTableViewCell
            cell.amount.setTitle(("  ₹ " + (offerList[indexPath.row].value(forKey: "amount") as! String) + "  "), for: .normal)
            cell.validityLbl.text = "Validity : \(offerList[indexPath.row].value(forKey: "validity") as! String)"
            cell.offerDescriptionL.text = (offerList[indexPath.row].value(forKey: "description") as! String)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        amount = offerList[indexPath.row].value(forKey: "amount") as! String
       
        performSegue(withIdentifier: "offervalueSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "offervalueSegue" {
            let RVC = segue.destination as! ReachargeViewController
            RVC.offerAmount = amount
            RVC.rechargeType = rechargeType
            RVC.TokenNo      = TokenNo
            RVC.pin          = pin
            RVC.fullOp       = fullOp
            RVC.customerId = custID!
        }
    }
    
    @IBAction func offersTypeSelection(_ sender: UISegmentedControl) {
        offerList = []
        for (key, value) in operatextDic {
            if (key as! String) == sender.titleForSegment(at: sender.selectedSegmentIndex) {
                offerList = value as! [NSDictionary]
                offersTbl.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "offerHdrCell", for: indexPath as IndexPath) as! offersHdrCollectionViewCell
        
        cell.offerLabel.text = segments[indexPath.row].replacingOccurrences(of: "_", with: " ").uppercased()
        cell.offerLabel.adjustsFontSizeToFitWidth = true
        
        if indexPath.row == selectedIndexPath {
            cell.offerLabel.bottomBorderL(UIColor.blue)
        }
        else{
            cell.offerLabel.bottomBorderL(UIColor.white)

        }
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
           
            cell.offerLabel.minimumScaleFactor = 0.4
            collectionView.layoutIfNeeded()
            
        }, completion: nil)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        let cellSize = CGSize(width: ((Int(collectionView.bounds.width)-15)/3), height: 40)
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "offerHdrCell", for: indexPath as IndexPath) as! offersHdrCollectionViewCell
        selectedIndexPath = indexPath.row
        offershdrCollection.reloadData()
        offerList = []
        for (key, value) in operatextDic {
            if (key as! String == segments[indexPath.row]) {
                offerList = value as! [NSDictionary]
                offersTbl.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
    
    
    @IBAction func Back(_ sender: UIBarButtonItem)
    {
        
        
        navigationController?.popViewController(animated: true)
    }
}


