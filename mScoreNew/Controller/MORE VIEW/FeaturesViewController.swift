//
//  FeaturesViewController.swift
//  mScoreNew
//
//  Created by Perfect on 02/12/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class FeaturesViewController: UIViewController {
    @IBOutlet weak var navItem: UINavigationItem!{
        didSet{
            navItem.title = "Features"
        }
    }
    
    
    @IBOutlet weak var features: UITextView!{
        didSet{
            features.isEditable = false
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("New Features: ")
                .normal("\n\n\u{1F534} You wWill Get All The Details Of Closed And Active Accounts Of Both Loan And Deposit. \n\n\u{1F534} Mini Statement With Last Ten Transaction Of Active Deposits & Loans In List & Analysis Format. \n\n\u{1F534} Option To Share Account Details With Others. \n\n\u{1F534} Facility To View The Account Statement For User Specified Date Range. \n\n\u{1F534} Facility To View The Offers Of Various Providers During Mobile Prepaid Recharge. \n\n\u{1F534} Repeat Recharge Options. \n\n\u{1F534} Facility To View The Transaction Status Of Electronic Fund Transfer. \n\n\u{1F534} Detailed Recharge History. \n\n\u{1F534} Option To Remit Own Fund Account Details By Showing As On Due Details. \n\n\n")
                .bold("Main Features: ")
                .normal("\n\n\u{1F534} Virtual card. \n\n\u{1F534} Branch Details with Location. \n\n\u{1F534} Due notifications. \n\n\u{1F534} Due Date Reminder. \n\n\u{1F534} Standing Notifications. \n\n\u{1F534} Account Summary. \n\n\u{1F534} Notice Posting Details. \n\n\u{1F534} Help Desk.\n\n\u{1F534} Supports multiple accounts of the same customer. \n\n\u{1F534} Supports Savings Bank and Current Account. \n\n\u{1F534} Statement Viewing facility with filtering. \n\n\u{1F534} Search option based on the Date, Amount, Transaction Type. \n\n\u{1F534} Sort transactions on Date, Amount. \n\n\u{1F534} Private & Public messages. \n\n\u{1F534} Fully secured with encryption. \n\n\u{1F534} Smart synchronization. \n\n\u{1F534} Rating & Feedback. \n\n\u{1F534} Passbook Summary Details. \n\n\u{1F534} Complete Account Summary. \n\n\u{1F534} Customer Alert (Reminders)\n\n\n")
                .bold("Advantages for Customers: ")
                .normal("\n\n\u{1F534} Access Bank statment from anywhere. \n\n\u{1F534} No need to visit the bank for updating passbook. \n\n\u{1F534} Passbook is updated automatically. \n\n\u{1F534} Saves Time & Money for Customers. \n\n\u{1F534} Get personalized offers from Bank. \n\n\u{1F534} Customers can Reacharge any prepaid Mobile/ DTH. \n\n\u{1F534} Send money to any account, any time, anywhere. \n\n\u{1F534} Send messages to Customer regarding new offers and events\n\n\n")
                .bold("Advantages for Bank: ")
                .normal("\n\n\u{1F534} No Paper, Passbook and printing is not required. \n\n\u{1F534} No dedicated staffs required to perform Passbook printing. \n\n\u{1F534} Saves Time & Money for Bank. \n\n\u{1F534} Next Generation Banking for Next Generation Customers. \n\n\u{1F534} Paperless Banking.\n\n\n")
                .bold("Security: ")
                .normal("\n\n\u{1F534} Secured Transmission using TLS 1.2 protocol over the transport layer. \n\n\u{1F534} End to End Data Encryption using application-level functions. \n\n\u{1F534} Random token generation and verification for each transaction. \n\n\u{1F534} Encrypted Database. \n\n\u{1F534} PIN-based primary authentication. \n\n\u{1F534} OTP based dual authentication. \n\n\u{1F534} Security Policy implementated in firewall.\n\n\n")
            
            features.attributedText = formattedString

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
}


extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "AvenirNext-Bold", size: 16)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
//        let normal = NSAttributedString(string: text)
//        append(normal)
        let attrsNormal: [NSAttributedString.Key: Any] = [.font: UIFont(name: "AvenirNext-Medium", size: 15)!]
        let normal = NSMutableAttributedString(string:text, attributes: attrsNormal)
        append(normal)
        return self
    }
}
