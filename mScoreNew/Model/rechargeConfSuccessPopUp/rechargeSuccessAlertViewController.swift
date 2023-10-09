//
//  rechargeSuccessViewController.swift
//  mScoreNew
//
//  Created by Perfect on 29/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit

class rechargeSuccessAlertViewController: UIViewController {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var sucHdrL: UILabel!
    @IBOutlet weak var rechDateL: UILabel!
    @IBOutlet weak var rechTimeL: UILabel!
    @IBOutlet weak var rechReffNoL: UILabel!
    @IBOutlet weak var fromAccL: UILabel!
    @IBOutlet weak var fromAccBranchL: UILabel!
    @IBOutlet weak var rechHdrL: UILabel!
    @IBOutlet weak var rechNumbL: UILabel!
    @IBOutlet weak var rechNumDetailsL: UILabel!
    @IBOutlet weak var rechAmountHdrL: UILabel!
    @IBOutlet weak var rechAmountL: UILabel!
    @IBOutlet weak var rechAmountDetailsL: UILabel!
    @IBOutlet weak var okBtn: UIButton!{
        didSet{
            okBtn.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var shareBt: UIButton!
    var delegate : rechargeConfSuccessAlertDelegate?
    var sucHdrLtxt              = String()
    var rechDateLtxt            = String()
    var rechTimeLtxt            = String()
    var rechReffNoLtxt          = String()
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
        
        sucHdrL.text            = sucHdrLtxt
        rechDateL.text          = rechDateLtxt
        rechTimeL.text          = rechTimeLtxt
        rechReffNoL.text        = rechReffNoLtxt
        fromAccL.text           = fromAccLtxt
        fromAccBranchL.text     = fromAccBranchLtxt
        rechHdrL.text           = rechHdrLtxt
        rechNumbL.text          = rechNumbLtxt
        rechNumDetailsL.text    = rechNumDetailsLtxt
        rechAmountHdrL.text     = rechAmountHdrLtxt
        rechAmountL.text        = rechAmountLtxt
        rechAmountDetailsL.text = rechAmountDetailsLtxt

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
