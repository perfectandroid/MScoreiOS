//
//  RechargeAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import EventKit
import DropDown

class VDAlertViewController: UIViewController, URLSessionDelegate {
    
    
    @IBOutlet weak var hdrLbl: UILabel!
    @IBOutlet weak var monthHt: NSLayoutConstraint!
    @IBOutlet weak var monthSeleVHt: NSLayoutConstraint!
    @IBOutlet weak var dateHt: NSLayoutConstraint!
    @IBOutlet weak var dateSeleVHt: NSLayoutConstraint!
    @IBOutlet weak var monthSelectionBtn: UIButton!
    @IBOutlet weak var fromDateSelectionBtn: UIButton!
    @IBOutlet weak var toDateSelectionBtn: UIButton!
    @IBOutlet weak var monthRadioBtn: UIButton!
    @IBOutlet weak var DateRadioBtn: UIButton!
    @IBOutlet weak var monthV: UIView!{
        didSet{
            monthV.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var fromV: UIView!{
        didSet{
            fromV.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var toV: UIView!{
        didSet{
            toV.viewBorder(UIColor(red: 60.0/255.0, green: 131.0/255.0, blue: 195.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var cancelBt: UIButton!{
        didSet{
            cancelBt.curvedButtonWithBorder(UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        }
    }
    @IBOutlet weak var vdBt: UIButton!
    let monthList = [ "January", "February", "March", "April", "May","June","July","August", "September","October","November","December"]
    var customerId                      = String()
    var TokenNo                         = String()
    var CustomerLoanAndDepositDetailsList = [NSDictionary]()
    var AccArray                        = [String]()
    var accDrop                         = DropDown()
    lazy var accDropDowns: [DropDown]   = { return[self.accDrop] } ()
    var monthDrop                       = DropDown()
    lazy var monthDropDowns: [DropDown] = { return[self.monthDrop] } ()
    
    var FromDate = String()
    var ToDate = String()
    
    var monDat = 0
    var ViewDown = 0
    
    var delegate : VDAlertDelegate?

    var DFromDate = String()
    var DToDate = String()
    
    var hdrLbltxt = String()
    var documentController: UIDocumentInteractionController = UIDocumentInteractionController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hdrLbl.text = hdrLbltxt + " Statement"
        vdBt.setTitle(hdrLbltxt, for: .normal)
        FromDate = Date().startOfMonth("yyyy-MM-dd",Date())
        ToDate = Date().endOfMonth("yyyy-MM-dd",Date())
        monthHt.constant = 80
        monthSeleVHt.constant = 30
        dateHt.constant = 50
        dateSeleVHt.constant = 0
        monthSelectionBtn.setTitle(Date().currentDate(format: "MMMM"), for: .normal)
        let twoWBDate = twoWeeksBackDate()
        DFromDate = Date().formattedDateFromString(dateString: twoWBDate, ipFormatter: "dd-MM-yyyy", opFormatter: "yyyy-MM-dd")!
        DToDate = Date().currentDate(format: "yyyy-MM-dd")
        fromDateSelectionBtn.setTitle(twoWBDate, for: .normal)
        toDateSelectionBtn.setTitle(Date().currentDate(format: "dd-MM-yyyy"), for: .normal)
        setMonthDropDown()
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("closed")
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func vdClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.refresh(self!.monDat,self!.FromDate,self!.ToDate,self!.DFromDate,self!.DToDate)
            self!.delegate?.VDButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }
    func setMonthDropDown()
    {
        monthDrop.anchorView      = monthSelectionBtn
        monthDrop.bottomOffset    = CGPoint(x: 0, y:40)
        monthDrop.dataSource      = monthList
        monthDrop.backgroundColor = UIColor.white
        monthDrop.selectionAction = {[weak self] (index, item) in
            DispatchQueue.main.async { [weak self] in
                self?.monthSelectionBtn.setTitle(item, for: .normal)
                let year = Calendar.current.component(.year, from: Date())
                var seleDate = ""

                if (String(index + 1)).count == 1{
                    seleDate = "\(year)-0\(String(index + 1))-01"
                }
                else{
                    seleDate = "\(year)-\(String(index + 1))-01"
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: seleDate)
                self?.FromDate = Date().startOfMonth("yyyy-MM-dd",date!)
                self?.ToDate = Date().endOfMonth("yyyy-MM-dd",date!)
                
            }
        }
    }
        
    
    func twoWeeksBackDate() -> String{
        let lastTwoWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let lastTwoWeekDateString = dateFormatter.string(from: lastTwoWeekDate)
        return lastTwoWeekDateString
    }
    
    @IBAction func monthV(_ sender: UIButton) {
        monDat = 0
        monthHt.constant = 80
        monthSeleVHt.constant = 30
        dateHt.constant = 50
        dateSeleVHt.constant = 0
        DateRadioBtn.setImage(UIImage(named: "ic_radioUnchecked.png"), for: .normal)
        monthRadioBtn.setImage(UIImage(named: "ic_radioChecked.png"), for: .normal)

    }
    @IBAction func monthList(_ sender: UIButton) {
        monthDrop.show()
    }
    
    @IBAction func dateV(_ sender: UIButton) {
        monDat = 1
        monthHt.constant = 50
        monthSeleVHt.constant = 0
        dateHt.constant = 130
        dateSeleVHt.constant = 80
        monthRadioBtn.setImage(UIImage(named: "ic_radioUnchecked.png"), for: .normal)
        DateRadioBtn.setImage(UIImage(named: "ic_radioChecked.png"), for: .normal)
    }
    
    @IBAction func fromDate(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        var components = DateComponents()
            components.year  = 0
            components.day   = 0
            components.month = 0
        let maxDate            = Calendar.current.date(byAdding: components, to: Date())
        let myDatePicker: UIDatePicker  = UIDatePicker()
            myDatePicker.timeZone       = .current
            myDatePicker.datePickerMode = .date
            myDatePicker.maximumDate    = maxDate
            if #available(iOS 13.4, *) {
                myDatePicker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            alertController.view.addSubview(myDatePicker)
            myDatePicker.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .centerX,
                                                        multiplier: 1,
                                                        constant: 0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .centerY,
                                                        multiplier: 1,
                                                        constant: 0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                                  attribute: .width,
                                                                  relatedBy: .equal,
                                                                  toItem: alertController.view,
                                                                  attribute: .width,
                                                                  multiplier: 1 ,
                                                                  constant:0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: alertController.view.frame.height/4))
        let selectAction = UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
                let dateFormater: DateFormatter = DateFormatter()
                    dateFormater.dateFormat = "yyyy-MM-dd"
                self.DFromDate = dateFormater.string(from: myDatePicker.date) as String
            fromDateSelectionBtn.setTitle(Date().formattedDateFromString(dateString: self.DFromDate, ipFormatter: "yyyy-MM-dd", opFormatter: "dd-MM-yyyy"), for: .normal)
            })
            let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
    }
    
    @IBAction func toDate(_ sender: UIButton) {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        var components = DateComponents()
            components.year  = 0
            components.day   = 0
            components.month = 0
        let maxDate            = Calendar.current.date(byAdding: components, to: Date())
        let myDatePicker: UIDatePicker  = UIDatePicker()
            myDatePicker.timeZone       = .current
            myDatePicker.datePickerMode = .date
            myDatePicker.maximumDate    = maxDate
            if #available(iOS 13.4, *) {
                myDatePicker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            alertController.view.addSubview(myDatePicker)
            myDatePicker.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .centerX,
                                                        multiplier: 1,
                                                        constant: 0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .centerY,
                                                        multiplier: 1,
                                                        constant: 0))
        alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: alertController.view,
                                                              attribute: .width,
                                                              multiplier: 1 ,
                                                              constant:0))
            alertController.view.addConstraint(NSLayoutConstraint(item: myDatePicker,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: alertController.view.frame.height/4))
        let selectAction = UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            let dateFormater: DateFormatter = DateFormatter()
                dateFormater.dateFormat = "yyyy-MM-dd"
            self.DToDate = dateFormater.string(from: myDatePicker.date) as String
            toDateSelectionBtn.setTitle(Date().formattedDateFromString(dateString: self.DToDate, ipFormatter: "yyyy-MM-dd", opFormatter: "dd-MM-yyyy"), for: .normal)

        })
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func ViewDownloadStatement(_ sender: UIButton) {
//        ViewDown = 0
//        StatementOfAccount()
    }

    
    
    
    
    
    
    
    
    

    
}

