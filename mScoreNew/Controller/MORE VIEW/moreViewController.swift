//
//  moreViewController.swift
//  mScoreNew
//
//  Created by Perfect on 03/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class moreViewController: UIViewController,  URLSessionDelegate {

    @IBOutlet weak var versionCode: UILabel!{
        didSet{
            if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            {
                versionCode.text = "Version : " + text
            }
        }
    }
    @IBOutlet weak var licensedTo: UILabel!{
        didSet{
            licensedTo.text = appName
        }
    }
    @IBOutlet weak var moreView: UIView!{
        didSet{
            moreView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var AppIconImage     : UIImageView!{
        didSet{
            SetImage(ImageCode: AppIconImageCode, ImageView: AppIconImage, Delegate: self)
        }
    }
    @IBOutlet var techPartnersImg: UIImageView!{
        didSet{
            SetImage(ImageCode: CompanyLogoImageCode, ImageView: techPartnersImg, Delegate: self)
        }
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func aboutUs(_ sender: UIButton) {
        self.performSegue(withIdentifier: "aboutUsView", sender: nil)
    }
    
    @IBAction func contactUs(_ sender: UIButton) {
        self.performSegue(withIdentifier: "contactUsView", sender: nil)
    }
    
    @IBAction func features(_ sender: UIButton) {
        self.performSegue(withIdentifier: "featuresView", sender: nil)
    }
    @IBAction func rateUs(_ sender: UIButton) {
        let quitopt = UIAlertController(title: "Do you love this app?",
                                        message: "Please rate us.",
                                        preferredStyle: UIAlertController.Style.alert)
        quitopt.addAction(UIAlertAction(title: "CANCEL",
                                        style: UIAlertAction.Style.default,
                                        handler: nil))
        quitopt.addAction(UIAlertAction(title: "RATE NOW",
                                        style: UIAlertAction.Style.default,
                                        handler: { (action:UIAlertAction!) -> Void in
                                            //after user press ok, the following code will be execute
                                            if let url = URL(string: appLink), UIApplication.shared.canOpenURL(url){
                                                UIApplication.shared.open(url)
                                            }
                                            else{
                                                UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com")!)
                                            }
                                           }))
        self.present(quitopt, animated: true, completion: nil)
    }
    
    
    @IBAction func feedBack(_ sender: UIButton) {
        self.performSegue(withIdentifier: "feedBackView", sender: nil)
    }
    
    @IBAction func faq(_ sender: UIButton) {
        self.performSegue(withIdentifier: "faqView", sender: nil)
    }
}
