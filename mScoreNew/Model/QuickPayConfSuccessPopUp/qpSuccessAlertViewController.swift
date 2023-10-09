//
//  rechargeSuccessViewController.swift
//  mScoreNew
//
//  Created by Perfect on 29/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class qpSuccessAlertViewController: UIViewController {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var sucHdrL: UILabel!
    @IBOutlet weak var qpDateL: UILabel!
    @IBOutlet weak var qpTimeL: UILabel!
    @IBOutlet weak var qpReffNoL: UILabel!
    @IBOutlet weak var senderNameL: UILabel!
    @IBOutlet weak var senderAccDetaL: UILabel!
    @IBOutlet weak var senderMobL: UILabel!
    @IBOutlet weak var receiverNameL: UILabel!
    @IBOutlet weak var receiverAccDetaL: UILabel!
    @IBOutlet weak var receiverMobL: UILabel!
    @IBOutlet weak var qpAmountL: UILabel!
    @IBOutlet weak var qpAmountDetailsL: UILabel!
    @IBOutlet weak var okBtn: UIButton!{
        didSet{
            okBtn.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var shareBt: UIButton!
    
    var sucHdrLtxt              = String()
    var qpDateLtxt              = String()
    var qpTimeLtxt              = String()
    var qpReffNoLtxt            = String()
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
        
        sucHdrL.text            = sucHdrLtxt
        qpDateL.text            = qpDateLtxt
        qpTimeL.text            = qpTimeLtxt
        qpReffNoL.text          = qpReffNoLtxt
        senderNameL.text        = senderNameLtxt
        senderAccDetaL.text     = senderAccDetaLtxt
        senderMobL.text         = senderMobLtxt
        receiverNameL.text      = receiverNameLtxt
        receiverAccDetaL.text   = receiverAccDetaLtxt
        receiverMobL.text       = receiverMobLtxt
        qpAmountL.text          = qpAmountLtxt
        qpAmountDetailsL.text   = qpAmountDetailsLtxt

    }
    
    @IBAction func OkClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.qpcancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.dismiss(animated: true, completion: nil)
            let ShareImg = self!.shareView.screenShot()
            self!.delegate?.qpShareScreenShot(ShareImg,self!.shareBt)
            self!.delegate?.qpshareButtonTapped()
        }
    }
}
