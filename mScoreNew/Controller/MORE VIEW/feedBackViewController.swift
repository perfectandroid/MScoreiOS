//
//  feedBackViewController.swift
//  mScoreNew
//
//  Created by Perfect on 01/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import MessageUI

class feedBackViewController: UIViewController,MFMailComposeViewControllerDelegate,UITextViewDelegate {

    @IBOutlet var floatRatingView: FloatRatingView!{
        didSet{
            // Reset float rating view's background color
            floatRatingView.backgroundColor = UIColor.clear
            
            /** Note: With the exception of contentMode, type and delegate,
             all properties can be set directly in Interface Builder **/
            floatRatingView.delegate        = self
            floatRatingView.contentMode     = UIView.ContentMode.scaleAspectFit
            floatRatingView.type            = .floatRatings
        }
    }
    @IBOutlet weak var feedText: UITextView!{
        didSet{
            feedText.delegate = self
        }
    }
    @IBOutlet weak var navItem: UINavigationItem!{
        didSet{
            navItem.title = "Feedback"
        }
    }
    
    
    var starRating = String()
    var catagoryText = "Suggetions"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Labels init
        starRating = String(format: "%.2f", self.floatRatingView.rating)
        // keyboard hiding in the case of touch the screen.
        self.hideKeyboardWhenTappedAround()

    }

    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendFeedBack(_ sender: UIButton) {
        sendEmail()
    }
    
    @IBAction func ratingTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            catagoryText = "Suggetions"
        case 1:
            catagoryText = "Complaints"
        case 2:
            catagoryText = "Others"
        default:
            catagoryText = "Suggetions"
        }
    }
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["pssappfeedback@gmail.com"])
            mail.setSubject("Mscore IOS : Feedback & Rating")
            mail.setMessageBody("Bank : \(appName)\nCustomer Rating is: \(starRating)\nFeedback: (\(catagoryText))\n\n\(feedText.text!) ", isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        animateViewMoving(up: true, moveValue: 100)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}

extension feedBackViewController: FloatRatingViewDelegate {
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        
        self.starRating = String(format: "%.2f", self.floatRatingView.rating)
    }
    

}
