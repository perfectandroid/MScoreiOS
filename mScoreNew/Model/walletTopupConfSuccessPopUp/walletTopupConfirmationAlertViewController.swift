//
//  RechargeAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import EventKit

class walletTopupConfirmationAlertViewController: UIViewController {
    
    @IBOutlet weak var fromAccL: UILabel!
    @IBOutlet weak var fromAccBranchL: UILabel!
    @IBOutlet weak var conAmountL: UILabel!
    @IBOutlet weak var conAmountDetailsL: UILabel!
    @IBOutlet weak var cancelBt: UIButton!{
        didSet{
            cancelBt.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var okBt: UIButton!
    
    var delegate : ksebConfSuccessAlertDelegate?

    var fromAccLtxt             = String()
    var fromAccBranchLtxt       = String()
    var conNameLtxt             = String()
    var conMobLtxt              = String()
    var conDetailLtxt           = String()
    var conAmountLtxt           = String()
    var conAmountDetailsLtxt    = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromAccL.text           = fromAccLtxt
        fromAccBranchL.text     = fromAccBranchLtxt
        conAmountL.text         = conAmountLtxt
        conAmountDetailsL.text  = conAmountDetailsLtxt
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func okClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.okButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }  
}

