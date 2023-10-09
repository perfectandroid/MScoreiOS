//
//  AboutUsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 30/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController, URLSessionDelegate {

    
    @IBOutlet weak var navItem: UINavigationItem!{
        didSet{
            navItem.title = "About Us"
        }
    }
    
    @IBOutlet weak var AppIconImage     : UIImageView!{
        didSet{
            SetImage(ImageCode: AppIconImageCode, ImageView: AppIconImage, Delegate: self)
        }
    }
    @IBOutlet weak var aboutUsIntro: UILabel!{
        didSet{
            aboutUsIntro.text = "\t\tMscore is the mobile app to perform all the common banking facilities for Co-operative Banks. This Mobile Application from Perfect Software Solutions (CLT) Pvt Ltd is very well designed benefiting both Banks & Customers equally. Mscore is an up-to-date app which strictly follows all the guidelines which makes Banking much Simpler & Superior."
        }
    }
    
    @IBOutlet var techPartnersImg: UIImageView!{
        didSet{
            SetImage(ImageCode: CompanyLogoImageCode, ImageView: techPartnersImg, Delegate: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    
//    func SetImage(ImageCode : String, ImageView: UIImageView){
//            // network reachability checking
//        if Reachability.isConnectedToNetwork()
//        {
////            self.noInternetMsg()
//            return
//        }
//        let url                 = URL(string: BankIP + ImageCode)!
//        var request             = URLRequest(url: url)
//            request.httpMethod  = "get"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let session = URLSession(configuration: .default,
//                                delegate: self,
//                                delegateQueue: nil)
//        let task = session.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                print("error")
//                return
//            }
//            if let res = response as? HTTPURLResponse {
//                let imaged = data
//                if res.statusCode == 200{
//                    DispatchQueue.main.async {
//                        let image = UIImage(data: imaged)
//                        if image != nil{
//                            ImageView.image = image
//                        }
//                        else{
////                            ImageView.image =  UIImage(named: "items")
//                        }
//                    }
//                }
//                else {
////                    ImageView.image =  UIImage(named: "items")
//                }
//                    
//             } else {
//                 print("Couldn't get response code for some reason")
////                ImageView.image =  UIImage(named: "items")
//             }
//            
//        }
//        task.resume()
//    }
}
