//
//  rechargeSuccessViewController.swift
//  mScoreNew
//
//  Created by Perfect on 29/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class walletTopupSuccessAlertViewController: UIViewController {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var sucHdrL: UILabel!
    @IBOutlet weak var wRechDateL: UILabel!
    @IBOutlet weak var wRechTimeL: UILabel!
    @IBOutlet weak var wRechReffeL: UILabel!
    @IBOutlet weak var fromAccL: UILabel!
    @IBOutlet weak var fromAccBranchL: UILabel!
    @IBOutlet weak var wRechAmountL: UILabel!
    @IBOutlet weak var wRechAmountDetailsL: UILabel!
    @IBOutlet weak var okBtn: UIButton!{
        didSet{
            okBtn.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var shareBt: UIButton!

    
    var delegate : ksebConfSuccessAlertDelegate?
    var sucHdrLtxt              = String()
    var wRechDateLtxt            = String()
    var wRechTimeLtxt            = String()
    var wRechReffeLtxt             = String()
    var fromAccLtxt       = String()
    var fromAccBranchLtxt             = String()
    var wRechAmountLtxt          = String()
    var wRechAmountDetailsLtxt   = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sucHdrL.text = sucHdrLtxt
        wRechDateL.text = wRechDateLtxt
        wRechTimeL.text = wRechTimeLtxt
        wRechReffeL.text = wRechReffeLtxt
        fromAccL.text = fromAccLtxt
        fromAccBranchL.text = fromAccBranchLtxt
        wRechAmountL.text = wRechAmountLtxt
        wRechAmountDetailsL.text = wRechAmountDetailsLtxt

    }
    
    @IBAction func OkClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.dismiss(animated: true, completion: nil)
            let ShareImg = self!.shareView.screenShot()
            self!.delegate?.ShareScreenShot(ShareImg,self!.shareBt)
            self!.delegate?.shareButtonTapped()
        }
    }
}
