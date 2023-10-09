//
//  RechargeAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class RechargeAlertViewController: UIViewController {

    @IBOutlet weak var prePaidView  : UIView!
    @IBOutlet weak var dthView      : UIView!
    @IBOutlet weak var landLineView : UIView!
    @IBOutlet weak var postPaidView : UIView!
    @IBOutlet weak var dataCardView : UIView!
    @IBOutlet weak var ksebView     : UIView!
    @IBOutlet weak var ksebHeight   : NSLayoutConstraint!
    
    var delegate : RechargeAlertDelegate?
    var ksebValue = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        cardView(prePaidView)
//        cardView(dthView)
//        cardView(landLineView)
//        cardView(postPaidView)
//        cardView(dataCardView)
//        cardView(ksebView)

        // Do any additional setup after loading the view.
        
        if ksebValue == false{
            ksebView.isHidden = true
            ksebHeight.constant = 0.0
        }
        else{
            ksebView.isHidden = false
            ksebHeight.constant = prePaidView.bounds.size.height
        }
    }
    
    @IBAction func prePaidClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.prePaidButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func dthClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.dthButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func landLineClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.landLineButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func postPaidClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.postPaidButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func dataCardClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.dataCardButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func ksebClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.ksebButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func rechargeHistoryClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.rechargeHistoryButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
}
