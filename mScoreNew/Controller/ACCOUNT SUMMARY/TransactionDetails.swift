//
//  TransactionDetails.swift
//  mScoreNew
//
//  Created by Perfect on 21/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit

class TransactionDetails: UIViewController
{
    @IBOutlet weak var chequeNum : UILabel!
    @IBOutlet weak var chequeDate: UILabel!
    @IBOutlet weak var transType : UILabel!
    @IBOutlet weak var amount    : UILabel!
    @IBOutlet weak var narration : UILabel!
    
    var transChequeNum    = String()
    var transChequeDate   = String()
    var transTypeDet      = String()
    var transAmount       = String()
    var transNarrationDet = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        chequeNum.text  = transChequeNum
    
        if transTypeDet == "D" {
            transType.text  = "Debit"
        }
        else{
            transType.text  = "Credit"
        }
        chequeDate.text = transChequeDate
        amount.text     = transAmount
        narration.text  = transNarrationDet
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }

    

}
