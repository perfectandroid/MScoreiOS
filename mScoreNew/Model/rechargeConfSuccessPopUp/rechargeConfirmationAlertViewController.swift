//
//  RechargeAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import EventKit
class rechargeConfirmationAlertViewController: UIViewController {
    
    
    @IBOutlet weak var fromAccL: UILabel!
    @IBOutlet weak var fromAccBranchL: UILabel!
    @IBOutlet weak var rechHdrL: UILabel!
    @IBOutlet weak var rechNumbL: UILabel!
    @IBOutlet weak var rechNumDetailsL: UILabel!
    @IBOutlet weak var rechAmountHdrL: UILabel!
    @IBOutlet weak var rechAmountL: UILabel!
    @IBOutlet weak var rechAmountDetailsL: UILabel!
    @IBOutlet weak var cancelBt: UIButton!{
        didSet{
            cancelBt.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var okBt: UIButton!

    
    var delegate : rechargeConfSuccessAlertDelegate?

    var fromAccLtxt             = String()
    var fromAccBranchLtxt       = String()
    var rechHdrLtxt             = String()
    var rechNumbLtxt            = String()
    var rechNumDetailsLtxt      = String()
    var rechAmountHdrLtxt       = String()
    var rechAmountLtxt          = String()
    var rechAmountDetailsLtxt   = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromAccL.text = fromAccLtxt
        fromAccBranchL.text = fromAccBranchLtxt
        rechHdrL.text = rechHdrLtxt
        rechNumbL.text = rechNumbLtxt
        rechNumDetailsL.text = rechNumDetailsLtxt
        rechAmountHdrL.text = rechAmountHdrLtxt
        rechAmountL.text = rechAmountLtxt
        rechAmountDetailsL.text = rechAmountDetailsLtxt

    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func vdClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.okButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }  
}

