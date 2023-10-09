//
//  BranchDetailsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 18/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BranchDetailsViewController: UIViewController, CLLocationManagerDelegate, URLSessionDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var navItem: UINavigationItem!{
        didSet{
            navItem.title = "Branch Location Details"
        }
    }

    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.delegate = self
            mapView.showsUserLocation = true
        }
    }
    @IBOutlet weak var maps: UIView!{
        didSet{
            maps.isHidden = false
        }
    }
    
    
    @IBOutlet weak var bankDetail: UIVisualEffectView!{
        didSet{
            bankDetail.isHidden = true
        }
    }
    @IBOutlet weak var branchList: UIView!{
        didSet{
            branchList.isHidden = true
        }
    }
    
    @IBOutlet weak var selectType: UISegmentedControl!
    @IBOutlet weak var bankImage: UIImageView!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var bankAddress: UILabel!
    @IBOutlet weak var bankPhoneNum: UILabel!
    @IBOutlet weak var bankWorkHr: UILabel!
    @IBOutlet weak var branchListTable: UITableView!
    
    var core = CLLocationManager()
    var instanceOfPostEncryption: EncryptionPost    = EncryptionPost()
    var annotationArray = [MKAnnotation]()
    var BranchLocationDetails = [NSDictionary]()

    override func viewDidLoad() {
        super.viewDidLoad()
        core.desiredAccuracy = kCLLocationAccuracyBest
        core.requestWhenInUseAuthorization()
        core.delegate = self
        core.requestAlwaysAuthorization()
        core.requestLocation()
        DispatchQueue.main.async {
            self.core.startUpdatingLocation()
        }
        // Do any additional setup after loading the view.
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D( latitude: 11.2588,
                                                                             longitude: 75.7804),
                                             span: MKCoordinateSpan(latitudeDelta: 10,
                                                                    longitudeDelta: 10)),
                          animated: true)
        fetchLocation()
    }
    
    deinit {
        print("memmory released-------")
    }
    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchLocation() {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            self.present(messages.msg(networkMsg), animated: true, completion: nil)
//            activityIndicator.stopAnimating()
//            blurView.isHidden = true
            return
        }
        
        // "ReqMode":instanceOfPostEncryption.encryptUseDES("1", key: "Agentscr")
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/BranchLocationDetails")!
        let jsonDict            = ["ReqMode":"1",
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
                DispatchQueue.main.async { [self] in
                    self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
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
                        let BranchLocationDetailsListInfo  = responseJSONData.value(forKey: "BranchLocationDetailsListInfo") as! NSDictionary
                        self.BranchLocationDetails  = BranchLocationDetailsListInfo.value(forKey: "BranchLocationDetails") as! [NSDictionary]
                        for singleLocation in self.BranchLocationDetails {
                            let lat  = singleLocation.value(forKey: "LocationLatitude") as! String
                            let long = singleLocation.value(forKey: "LocationLongitude") as! String
                            let bName = singleLocation.value(forKey: "BankName") as! String + "\n\n\n\( String(singleLocation.value(forKey: "ID_Branch") as! Int))"
                            if lat != "" && long != ""{
                                let ann = annottation.init(coordin: CLLocationCoordinate2D( latitude: Double(lat)!,
                                                                                            longitude: Double(long)! ),
                                                           placeTitle: bName,
                                                           subTitle: "")
                                self.annotationArray.append(ann)
                            }
                        }
                        if self.annotationArray.count != 0 {
                            DispatchQueue.main.async {
                                self.mapView.addAnnotations(self.annotationArray)
                                self.mapView.showsScale = true
                                self.mapView.showsCompass = true
                                self.mapView.showsBuildings = true
                                self.mapView.isZoomEnabled = true
                                self.mapView.isScrollEnabled = true
                                self.mapView.showAnnotations(self.annotationArray, animated: true)
                            }
//                            self.mapView.mapType = MKMapType.satellite
                        }
                        else{
                            let uiAlert = UIAlertController(title: "ALERT",
                                                            message: "No branches marked on map!",
                                                            preferredStyle: UIAlertController.Style.alert)
                            self.present(uiAlert,
                                         animated: true,
                                         completion: nil)
                            
                            uiAlert.addAction(UIAlertAction(title: "BRANCH LIST",
                                                            style: .default,
                                                            handler: { action in
                                self.selectType.selectedSegmentIndex = 1
                                self.branchList.isHidden = false
                                self.maps.isHidden = true

                            }))
                        }
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.branchListTable.reloadData()
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
                        }
                    }
                    else {
                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
                            self?.present(messages.msg("No data found"), animated: true,completion: nil)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let range = view.annotation?.title??.range(of: "\n\n\n") {
            let Id_branch = view.annotation?.title??[range.upperBound...]
            fetchLocationAddress(ID: String(Id_branch!))
        }
    }
    func fetchLocationAddress(ID:String) {
        // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            self.present(messages.msg(networkMsg), animated: true, completion: nil)
            //            activityIndicator.stopAnimating()
            //            blurView.isHidden = true
            return
        }
        
//        "ReqMode":instanceOfPostEncryption.encryptUseDES("1", key: "Agentscr"),
//        "ID_Branch":instanceOfPostEncryption.encryptUseDES(ID, key: "Agentscr")
        
        
        let url                 = URL(string: BankIP + APIBaseUrlPart1 + "/AccountSummary/BankBranchDetails")!
        let jsonDict            = ["ReqMode":"1",
                                    "ID_Branch":ID,
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
                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                DispatchQueue.main.async { [weak self] in
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
                        let BankBranchDetailsListInfo  = responseJSONData.value(forKey: "BankBranchDetailsListInfo") as! NSDictionary
            
                        DispatchQueue.main.async { [weak self] in
                            
                            self?.bankName.text = (BankBranchDetailsListInfo.value(forKey: "BankName") as? String ?? "")
                            
                            self?.bankAddress.text = "\(BankBranchDetailsListInfo.value(forKey: "BranchName") as? String ?? ""), \n\(BankBranchDetailsListInfo.value(forKey: "Address") as? String ?? "" )' \n\(BankBranchDetailsListInfo.value(forKey: "Place") as? String ?? "" ), \n\(BankBranchDetailsListInfo.value(forKey: "District") as? String ?? "" ), \nPhone:\(BankBranchDetailsListInfo.value(forKey: "LandPhoneNumber") as? String ?? "" ), \(BankBranchDetailsListInfo.value(forKey: "BranchMobileNumber") as? String ?? "" )"
                            self?.bankPhoneNum.text = "Contact Person:\n" + "\(BankBranchDetailsListInfo.value(forKey: "InchargeContactPerson") as? String ?? "")" + "(Manager) \nPhone no: \(BankBranchDetailsListInfo.value(forKey: "ContactPersonMobile") as? String ?? "")"
                            self?.bankWorkHr.text = "Working Hours:"+" \( BankBranchDetailsListInfo.value(forKey: "OpeningTime") as? String ?? "")"+" -"+" \( BankBranchDetailsListInfo.value(forKey: "ClosingTime") as? String ?? "")"
                            
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
                            self?.bankDetail.isHidden = false

                        }
                    }
                    else {
                        DispatchQueue.main.async { [weak self] in
//                            self?.activityIndicator.stopAnimating()
//                            self?.blurView.isHidden = true
                            self?.present(messages.msg("No data found"), animated: true,completion: nil)
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
    
    @IBAction func close(_ sender: UIButton) {
        bankDetail.isHidden = true
    }
    @IBAction func branchLocationSelection(_ sender: UISegmentedControl) {
        if selectType.selectedSegmentIndex == 0{
            branchList.isHidden = true
            maps.isHidden = false
        }
        else{
            branchList.isHidden = false
            maps.isHidden = true
          
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
////        print(self.view.frame.size.height/3)
//        return 230
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return BranchLocationDetails.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = branchListTable.dequeueReusableCell(withIdentifier: "BranchListCell") as! BranchListTableViewCell
        cell.bankName.text    = BranchLocationDetails[indexPath.item].value(forKey: "BankName") as? String
        cell.bankAddress.text = BranchLocationDetails[indexPath.item].value(forKey: "BranchName") as! String + ",\n\(BranchLocationDetails[indexPath.item].value(forKey: "Address") as! String), \n\(BranchLocationDetails[indexPath.item].value(forKey: "Place") as! String), \n\(BranchLocationDetails[indexPath.item].value(forKey: "District") as! String),\nPhone:  \(BranchLocationDetails[indexPath.item].value(forKey: "LandPhoneNumber") as! String),\(BranchLocationDetails[indexPath.item].value(forKey: "BranchMobileNumber") as! String)"
        cell.bankNum.text         = "Contact Person:\n" + "\(BranchLocationDetails[indexPath.item].value(forKey: "InchargeContactPerson") as! String)" + "(Manager) \nPhone no: \(BranchLocationDetails[indexPath.item].value(forKey: "ContactPersonMobile") as! String)"

        cell.bankWorkingHr.text        = "Working Hours:"+" \( BranchLocationDetails[indexPath.item].value(forKey: "OpeningTime") as! String)"+" -"+" \( BranchLocationDetails[indexPath.item].value(forKey: "ClosingTime") as! String)"
    
        
        let lati = BranchLocationDetails[indexPath.item].value(forKey: "LocationLatitude") as! String
        let longi = BranchLocationDetails[indexPath.item].value(forKey: "LocationLongitude") as! String
        if lati != "" && longi != "" {
            cell.nextImg.image = UIImage(named: "ic_direction")
        }
        else{
            cell.nextImg.image = nil

        }
        return cell
    }
    var lat = Double()
    var lon = Double()
    var bName = String()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let lati = BranchLocationDetails[indexPath.item].value(forKey: "LocationLatitude") as! String
        let longi = BranchLocationDetails[indexPath.item].value(forKey: "LocationLongitude") as! String
        if lati != "" && longi != ""{
            lat = Double(lati)!
            lon = Double(longi)!
            bName = (BranchLocationDetails[indexPath.item].value(forKey: "BankName") as? String)!
            performSegue(withIdentifier: "routeMap", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // from phone number screen to otp screen
        if segue.identifier == "routeMap"
        {
            let vw = segue.destination as! RouteMapViewController
            vw.destLat = lat
            vw.desLong = lon
            vw.bankName = bName
        }
    }

}
