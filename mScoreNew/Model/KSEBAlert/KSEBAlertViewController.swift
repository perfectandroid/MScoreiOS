//
//  RechargeAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class KSEBAlertViewController: UIViewController {

    @IBOutlet weak var ksebView: UIView!
    
    var delegate : KSEBAlertDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView(ksebView)

        // Do any additional setup after loading the view.
    }
    
   
    @IBAction func ksebClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.KSEBButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelBtnTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
}
