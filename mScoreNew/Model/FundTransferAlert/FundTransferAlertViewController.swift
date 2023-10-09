//
//  FundTransferAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class FundTransferAlertViewController: UIViewController {

    @IBOutlet weak var OtherBankView: UIView!
    @IBOutlet weak var OwnBankView: UIView!
    
    var delegate : FundTransferAlertDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView(OtherBankView)
        cardView(OwnBankView)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func otherBankClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.otherBankButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func ownBankClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.ownBankButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
}
