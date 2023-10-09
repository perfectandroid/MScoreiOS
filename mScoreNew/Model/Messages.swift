//
//  Messages.swift
//  mScoreNew
//
//  Created by Perfect on 25/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//
import Foundation

public let networkMsg           = "The Internet connection appears to be offline. Please turn on mobile data or connect to wifi."
public let contactBankMsg       = "Please contact bank to activate mobile banking service."
public let invalidOtpMsg        = "Please enter valid OTP."
public let invalidPinMsg        = "Please enter valid Pin."

public let timeOutMsg           = "The request timed out."
public let invalidMobNumMsg     = "Please enter valid 10 digit mobile number"
public let invalidAmount        = "Please enter a valid amount"
public let noTransactionMsg     = "No transaction available"
public let amountToReachargeMsg = "Please enter amount to recharge"
public let amountLimitMsg       = "Please enter amount between ₹ 1.00 and "
public let amountLimitMsgForRech       = "Please enter amount between ₹ 10.00 and ₹ 10,000.00"
public let wrongTxt = "Something went wrong."
public let sessionExpiredMsg = "Session Expired"

public class messages
{
    class func msgBlank (_ message: String) -> UIAlertController
    {
        let alert = UIAlertController(title: "",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
//        let imgViewTitle = UIImageView(frame: CGRect(x: alert.view.center.x-(alert.view.center.x/4), y: 0, width: 25, height: 25))
//        imgViewTitle.image = UIImage(named:"logo.png")
//        alert.view.addSubview(imgViewTitle)
        return alert
    }
    
    class func alertWithAction(_ message:String,actions: @escaping () -> ())->UIAlertController
    {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction!) in
              actions()
        }))
        
        return alert
    }
    class func msg (_ message: String) -> UIAlertController
    {
        let alert = UIAlertController(title: "",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
//        let imgViewTitle = UIImageView(frame: CGRect(x: alert.view.center.x-(alert.view.center.x/4), y: 0, width: 25, height: 25))
//        imgViewTitle.image = UIImage(named:"logo.png")
//        alert.view.addSubview(imgViewTitle)
        return alert
    }
    class func successMsg (_ message: String) -> UIAlertController
    {
        let alert = UIAlertController(title: "SUCCESS",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
//        let imgViewTitle = UIImageView(frame: CGRect(x: alert.view.frame.width/2.6, y: 0, width: 25, height: 25))
//        imgViewTitle.image = UIImage(named:"logo.png")
//        alert.view.addSubview(imgViewTitle)
        return alert
    }
    class func failureMsg (_ message: String) -> UIAlertController
    {
        let alert = UIAlertController(title: "FAILED", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
//        let imgViewTitle = UIImageView(frame: CGRect(x: alert.view.frame.width/2.6, y: 0, width: 25, height: 25))
//        imgViewTitle.image = UIImage(named:"logo.png")
//        alert.view.addSubview(imgViewTitle)
        return alert
    }
    class func errorMsg () -> UIAlertController
    {
        let alert = UIAlertController(title: "ERROR", message: "An error has occurred.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
//        let imgViewTitle = UIImageView(frame: CGRect(x: alert.view.frame.width/2.6, y: 0, width: 25, height: 25))
//        imgViewTitle.image = UIImage(named:"logo.png")
//        alert.view.addSubview(imgViewTitle)
        return alert
    }
    class func errorMsgWithAppIcon(_ message: String, _ image : UIImage) -> UIAlertController {
        let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//        action.setValue(image, forKey: "image")
        alertMessage .addAction(action)
        return alertMessage
    }
    
    class func pendingMsgWithAppIcon(_ message: String, _ image : UIImage , _ VC: UIViewController) -> UIAlertController {
        let alertMessage = UIAlertController(title: "PENDING", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
            
            VC.performSegue(withIdentifier: "pendingPopupOk", sender: nil)
        })
        alertMessage .addAction(action)
        return alertMessage
    }
    
    class func msgInBottom(_ message: String, _ image : UIImage) -> UIAlertController{
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: NSLocalizedString("Share", comment: ""), style: .default, handler: { _ in
        })
//        action.setValue(image.withRenderingMode(.alwaysOriginal), forKey: "image")
        actionSheet.addAction(action)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return actionSheet
    }
}
public extension UIAlertController
{
    func showMsg()
    {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc  = UIViewController()
            vc.view.backgroundColor = .clear
            win.rootViewController  = vc
            win.windowLevel         = UIWindow.Level.alert + 1
            win.makeKeyAndVisible()
            vc.present(self, animated: true, completion: nil)
    }
}


