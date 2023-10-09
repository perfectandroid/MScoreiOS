//
//  EMICalcViewController.swift
//  mScoreKakkur
//
//  Created by Perfect on 07/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit
import Darwin


class EMICalcViewController: UIViewController {
    
    
    @IBOutlet weak var setAmountView: UIView!{
        didSet {
            setAmountView.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var setInterestRateView: UIView!{
        didSet {
            setInterestRateView.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var setYearsView: UIView!{
        didSet {
            setYearsView.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    
    @IBOutlet weak var PrincipleAmount: CustomUITextField!
    @IBOutlet weak var InterestRate: CustomUITextField!
    @IBOutlet weak var Years: CustomUITextField!
    @IBOutlet weak var emiResultView: UIView!{
        didSet{
            emiResultView.isHidden =  true

        }
    }
    @IBOutlet weak var emiL: UILabel!
    @IBOutlet weak var interestTotalL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        cardView(emiResultView)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func EMICalculator(_ sender: UIButton) {
//        E = (P.r.(1+r)n) / ((1+r)n – 1)
//        Here,
//        P = loan amount i.e principal amount
//        R = Interest rate per month
//        T = Loan time period in year
//        NSDecimalNumber monthlyPayment = LoanAmount * interestRateDecimal / (1 - (pow(1/(1 + interestRateDecimal), months)));

        if PrincipleAmount.text?.count == 0 {
            self.present(messages.msgBlank("Enter Principle Amount"), animated: true, completion: nil)
            return
        }
        if InterestRate.text?.count == 0 {
            self.present(messages.msgBlank("Enter Interest Rate"), animated: true, completion: nil)
            return
        }
        if InterestRate.text?.count == 0 {
            self.present(messages.msgBlank("Enter Years"), animated: true, completion: nil)
            return
        }
        let p = Float64(PrincipleAmount.text!)
        
        switch InterestRate.text!.filter({$0 == "."}).count{
        case 0:
            print("zero dots available")
        case 1:
            print("one dots availabel")
            
        default:
            print("more than one dots")
            self.present(messages.msgBlank("Enter Valid Interest Rate"), animated: true, completion: nil)
            return
            
        }
        let ri = Float64(InterestRate.text!)
        let r = ((ri!/12)/100)
        let t = Float64(Years.text!)
        let n = Float64(t! * 12)
        let div = Float64(pow((1+r) , n ))
        let e1 = (p! * r * div)
        let e2 = (div - 1)
        let e = e1/e2
        let ta = e * n
        let ti = ta - p!
        emiResultView.isHidden =  false

        emiL.text = "EMI : " + Double(e).currencyIN
        interestTotalL.text = "INTEREST TOTAL : " + Double(ti).currencyIN
    }
    
    @IBAction func RESET(_ sender: UIButton) {
        emiResultView.isHidden =  true
        emiL.text = ""
        interestTotalL.text = ""
        PrincipleAmount.text = ""
        InterestRate.text = ""
        Years.text = ""
    }
    
    
}
