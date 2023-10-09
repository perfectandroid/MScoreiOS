//
//  statusDetailsViewController.swift
//  mScoreNew
//
//  Created by Perfect on 16/10/21.
//  Copyright © 2021 PSS. All rights reserved.
//

import UIKit
import Foundation

class statusDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var narrationL: UILabel!{
        didSet{
            narrationL.backgroundColor = .clear
            narrationL.layer.cornerRadius = 5
            narrationL.layer.borderWidth = 1
            narrationL.layer.borderColor = blueColor.cgColor
        }
    }
    @IBOutlet weak var statusDetailsView: UIView!
    @IBOutlet weak var statusDetailsTable: UITableView!

    var OtherFundTransferHistoryDetails = NSDictionary()
    let hdr = ["Date" , "Account No.", "Branch",  "UTRNO" , "Bank Reference No.","Beneficiary Name" , "Beneficiary A/C","Beneficiary Bank", "Beneficiary Branch",  "Amount" , "Status"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        narrationL.text = (OtherFundTransferHistoryDetails.value(forKey: "Remark") as! String)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.bounds.height / 11.1)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusDetailsCell") as! StatusDetailsTableViewCell
        cell.statDetailsHdr.text = hdr[indexPath.row]
        switch indexPath.row {
            case 0:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "Date") as! String)
            case 1:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "AccountNo") as! String)
            case 2:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "Branch") as! String)
            case 3:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "UTRNO") as! String)
            case 4:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "BankRefNo") as! String)
            case 5:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "Beneficiary") as! String)
            case 6:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "BeneficiaryNumber") as! String)
            case 7:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "BeneficiaryBank") as! String)
            case 8:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "BeneficiaryBankBranch") as! String)
            case 9:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "Amount") as! Double).currencyIN
                cell.statDetailsValue.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                cell.statDetailsRsInWords.text = (OtherFundTransferHistoryDetails.value(forKey: "Amount") as! Double).InWords
            case 10:
                cell.statDetailsValue.text = (OtherFundTransferHistoryDetails.value(forKey: "Status") as! String)

            default:
                cell.statDetailsHdr.text = ""
        }
        return cell
    }
    
    @IBAction func ShareClick(_ sender: UIButton) {
        let ShareImg = statusDetailsView.screenShot()
        if ShareImg.size.width != 0 {
            let firstActivityItem = ""
            let secondActivityItem  = ShareImg
            let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem,secondActivityItem], applicationActivities: nil)
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = (sender)
            
            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.unknown
            // UIPopoverArrowDirection.allZeros
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150,
                                                                                      y: 150,
                                                                                      width: 0,
                                                                                      height: 0)
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.postToWeibo,
                                                            UIActivity.ActivityType.print,
                                                            UIActivity.ActivityType.assignToContact,
                                                            UIActivity.ActivityType.saveToCameraRoll,
                                                            UIActivity.ActivityType.addToReadingList,
                                                            UIActivity.ActivityType.postToFlickr,
                                                            UIActivity.ActivityType.postToVimeo,
                                                            UIActivity.ActivityType.postToTencentWeibo]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
}

