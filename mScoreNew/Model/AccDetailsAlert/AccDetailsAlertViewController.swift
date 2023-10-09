//
//  AccDetailsAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 22/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit

class AccDetailsAlertViewController: UIViewController {

    @IBOutlet weak var passBookView: UIView!
    @IBOutlet weak var accSummaryView: UIView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var standingInstructionView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    var delegate: AccDetailAlertDelegate?
    
    override func viewDidLoad() {
//        cardView(passBookView)
//        cardView(accSummaryView)
//        cardView(noticeView)
//        cardView(standingInstructionView)
//        cardView(searchView)

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func passBookClick(_ sender: UIButton) {
        delegate?.passBookButtonTapped()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func accSummaryClick(_ sender: UIButton) {
        delegate?.accSummaryButtonTapped()
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func noticeClick(_ sender: UIButton) {
        delegate?.noticeButtonTapped()
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func standInstructionClick(_ sender: UIButton) {
        delegate?.standingInstructionButtonTapped()
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func searchClick(_ sender: UIButton) {
        delegate?.searchButtonTapped()
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func cancelClick(_ sender: UIButton) {
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)

    }
    
}
