//
//  RechargeAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import EventKit

class ShareAlertViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var benNameLbl: UILabel!
    @IBOutlet weak var benDetailLbl: UILabel!
    @IBOutlet weak var popUpHt: NSLayoutConstraint!
    var shareListData: String!
    var delegate : ShareAlertDelegate?
    var shareList = [String]()
    var accHolderName = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // keyboard hiding in the case of touch the screen
        self.hideKeyboardWhenTappedAround()
        do{
            let fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                accHolderName = (fetchedCusDetail.value(forKey: "name") as? String)!
            }
        }
        catch{
        }
        
        benNameLbl.text = accHolderName
//        benDetailLbl.text = shareListData
        if shareList.count == 1  {
            popUpHt.constant = 230
        }
        else{
            if CGFloat((95 * shareList.count) + 135) > view.bounds.height {
                popUpHt.constant =  view.bounds.height - 40
            }
            else{
                popUpHt.constant = CGFloat((95 * shareList.count) + 135)
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharePopCell") as! sharePopTableViewCell
            cell.shareL.text = shareList[indexPath.row]
        return cell
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.share(sender)

        }
    }
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    func share(_ sender: UIButton){
        
        let firstActivityItem = "Beneficiary Name : \(accHolderName)\n"
        let secondActivityItem  = shareListData + ""
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
