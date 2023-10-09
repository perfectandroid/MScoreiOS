//
//  RechargeAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import EventKit
class qpConfirmationAlertViewController: UIViewController {
    
    
    @IBOutlet weak var senderNameL: UILabel!
    @IBOutlet weak var senderAccDetaL: UILabel!
    @IBOutlet weak var senderMobL: UILabel!
    @IBOutlet weak var receiverNameL: UILabel!
    @IBOutlet weak var receiverAccDetaL: UILabel!
    @IBOutlet weak var receiverMobL: UILabel!
    @IBOutlet weak var qpAmountL: UILabel!
    @IBOutlet weak var qpAmountDetailsL: UILabel!
    @IBOutlet weak var cancelBt: UIButton!{
        didSet{
            cancelBt.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var okBt: UIButton!
    var senderNameLtxt          = String()
    var senderAccDetaLtxt       = String()
    var senderMobLtxt           = String()
    var receiverNameLtxt        = String()
    var receiverAccDetaLtxt     = String()
    var receiverMobLtxt         = String()
    var qpAmountLtxt            = String()
    var qpAmountDetailsLtxt     = String()
    var delegate : qpConfSuccessAlertDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderNameL.text        = senderNameLtxt
        senderAccDetaL.text     = senderAccDetaLtxt
        senderMobL.text         = senderMobLtxt
        receiverNameL.text      = receiverNameLtxt
        receiverAccDetaL.text   = receiverAccDetaLtxt
        receiverMobL.text       = receiverMobLtxt
        qpAmountL.text          = qpAmountLtxt
        qpAmountDetailsL.text   = qpAmountDetailsLtxt
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.qpcancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func okClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.qpokButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }  
}

