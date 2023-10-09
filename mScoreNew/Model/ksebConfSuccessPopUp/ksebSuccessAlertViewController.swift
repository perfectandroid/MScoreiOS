//
//  rechargeSuccessViewController.swift
//  mScoreNew
//
//  Created by Perfect on 29/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class ksebSuccessAlertViewController: UIViewController {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var sucHdrL: UILabel!
    @IBOutlet weak var kRechDateL: UILabel!
    @IBOutlet weak var kRechTimeL: UILabel!
    @IBOutlet weak var kRechReffeL: UILabel!
    @IBOutlet weak var fromAccL: UILabel!
    @IBOutlet weak var fromAccBranchL: UILabel!
    @IBOutlet weak var kRechNamL: UILabel!
    @IBOutlet weak var kRechmobL: UILabel!
    @IBOutlet weak var kRechDetaL: UILabel!
    @IBOutlet weak var kRechAmountL: UILabel!
    @IBOutlet weak var kRechAmountDetailsL: UILabel!
    @IBOutlet weak var okBtn: UIButton!{
        didSet{
            okBtn.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var shareBt: UIButton!

    
    var delegate : ksebConfSuccessAlertDelegate?
    var sucHdrLtxt              = String()
    var kRechDateLtxt            = String()
    var kRechTimeLtxt            = String()
    var kRechReffeLtxt             = String()
    var fromAccLtxt       = String()
    var fromAccBranchLtxt             = String()
    var kRechNamLtxt            = String()
    var kRechmobLtxt      = String()
    var kRechDetaLtxt       = String()
    var kRechAmountLtxt          = String()
    var kRechAmountDetailsLtxt   = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sucHdrL.text = sucHdrLtxt
        kRechDateL.text = kRechDateLtxt
        kRechTimeL.text = kRechTimeLtxt
        kRechReffeL.text = kRechReffeLtxt
        fromAccL.text = fromAccLtxt
        fromAccBranchL.text = fromAccBranchLtxt
        kRechNamL.text = kRechNamLtxt
        kRechmobL.text = kRechmobLtxt
        kRechDetaL.text = kRechDetaLtxt
        kRechAmountL.text = kRechAmountLtxt
        kRechAmountDetailsL.text = kRechAmountDetailsLtxt

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
