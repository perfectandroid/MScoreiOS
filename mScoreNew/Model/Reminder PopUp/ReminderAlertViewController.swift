//
//  RechargeAlertViewController.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import EventKit

class ReminderAlertViewController: UIViewController {

    @IBOutlet weak var setDate: UILabel!{
        didSet{
            setDate.text = date
        }
    }
    @IBOutlet weak var setTime: UILabel!{
        didSet{
            setTime.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        }
    }
    @IBOutlet weak var reminderNote: UITextView!{
        didSet{
            reminderNote.text = remiMessage
        }
    }
    @IBOutlet weak var buttonDateSettings: UIButton!{
        didSet{
            buttonDateSettings.backgroundColor = .clear
            buttonDateSettings.layer.cornerRadius = 5
            buttonDateSettings.layer.borderWidth = 1
            buttonDateSettings.layer.borderColor = UIColor.gray.cgColor
        }
    }
    @IBOutlet weak var buttonTimeSettings: UIButton!{
        didSet{
            buttonTimeSettings.backgroundColor = .clear
            buttonTimeSettings.layer.cornerRadius = 5
            buttonTimeSettings.layer.borderWidth = 1
            buttonTimeSettings.layer.borderColor = UIColor.gray.cgColor
        }
    }
    @IBOutlet weak var textViewSettings: UIView!{
        didSet{
            textViewSettings.layer.borderWidth = 1
            textViewSettings.layer.borderColor = UIColor.gray.cgColor
            textViewSettings.layer.cornerRadius = 5
        }
    }
    
    var delegate : ReminderAlertDelegate?
    var toolBar = UIToolbar()
    var datePicker = UIDatePicker.init()
    var timeToolBar = UIToolbar()
    var timePicker = UIDatePicker.init()
    var datePickerShown = false
    var timePickerShown = false
    
    var date = String()
    var remiMessage = String()
    var remiPreviousDates = Int()
    
    var maxDate = Date()
    var minDate = Date()
    
    let dateFormatter = DateFormatter()
    let calender = Calendar.current
    var before3Days = Date()
    var setDateForm = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // keyboard hiding in the case of touch the screen
        self.hideKeyboardWhenTappedAround()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        if remiPreviousDates == 1 {
            setDate.text = dateFormatter.string(from: Date())
        }
        else{
            maxDate = dateFormatter.date(from: date)!
            before3Days = calender.date(byAdding: Calendar.Component.day, value: -3, to: maxDate)!
            
            let bfr3DaysString = dateFormatter.string(from: before3Days).prefix(10)
            
            if before3Days < Date(){
                setDate.text = dateFormatter.string(from: Date())
                setDateForm = Date()
            }
            else{
                setDate.text = String(bfr3DaysString)
                setDateForm = before3Days
            }
        }
    }
    
    @IBAction func dateClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.dateButtonTapped()
            if self!.datePickerShown == false {
                self!.timeToolBar.removeFromSuperview()
                self!.timePicker.removeFromSuperview()
                self!.datePicker.minimumDate = self!.minDate
                if self!.remiPreviousDates == 0 {
                    self!.datePicker.maximumDate = self!.maxDate
                }
                self!.datePicker.date = self!.setDateForm
                self!.datePicker.backgroundColor = UIColor.white
                self!.datePicker.autoresizingMask = .flexibleWidth
                self!.datePicker.datePickerMode = .date
//                self!.datePicker.addTarget(self, action: #selector(self!.dateChanged(_:)), for: .valueChanged)
                self!.datePicker.frame = CGRect(x: 0.0,
                                                y: UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height/2.5,
                                                width: UIScreen.main.bounds.size.width,
                                                height: UIScreen.main.bounds.size.height/2.5)
                self!.view.addSubview(self!.datePicker)
                
                self!.toolBar = UIToolbar(frame: CGRect(x: 0,
                                                        y: UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height/2.5,
                                                        width: UIScreen.main.bounds.size.width,
                                                        height: UIScreen.main.bounds.size.height/5))
                self!.toolBar.barStyle = .default
                self!.toolBar.items = [UIBarButtonItem(title: "CANCEL",
                                                       style: .done,
                                                       target: self,
                                                       action: #selector(self!.dateCancelButtonClicked)),
                                       UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                       target: nil,
                                                       action: nil),
                                       UIBarButtonItem(title: "OK",
                                                       style: .done,
                                                       target: self,
                                                       action: #selector(self!.onDateDoneButtonClick))]
                self!.toolBar.tintColor = UIColor.black
                self!.toolBar.sizeToFit()
                self!.view.addSubview(self!.toolBar)
                self!.datePickerShown = true
            }
        }
    }
    
    @IBAction func timeClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.timeButtonTapped()
            if self!.timePickerShown == false {
                self!.toolBar.removeFromSuperview()
                self!.datePicker.removeFromSuperview()
                if self!.setDate.text == self!.dateFormatter.string(from: Date()) {
                    self!.timePicker.minimumDate = Date()
                }
                self!.timePicker.backgroundColor = UIColor.white
                self!.timePicker.autoresizingMask = .flexibleWidth
                self!.timePicker.datePickerMode = .time
//                self!.timePicker.addTarget(self, action: #selector(self!.dateChanged(_:)), for: .valueChanged)
                self!.timePicker.frame = CGRect(x: 0.0,
                                                y: UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height/2.5,
                                                width: UIScreen.main.bounds.size.width,
                                                height: UIScreen.main.bounds.size.height/2.5)
                self!.view.addSubview(self!.timePicker)
                
                self!.timeToolBar = UIToolbar(frame: CGRect(x: 0,
                                                        y: UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height/2.5,
                                                        width: UIScreen.main.bounds.size.width,
                                                        height: UIScreen.main.bounds.size.height/5))
                self!.timeToolBar.barStyle = .default
                self!.timeToolBar.items = [UIBarButtonItem(title: "CANCEL",
                                                       style: .done,
                                                       target: self,
                                                       action: #selector(self!.timerCancelButtonClicked)),
                                       UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                       target: nil,
                                                       action: nil),
                                       UIBarButtonItem(title: "OK",
                                                       style: .done,
                                                       target: self,
                                                       action: #selector(self!.onTimerDoneButtonClick))]
                self!.timeToolBar.tintColor = UIColor.black
                self!.timeToolBar.sizeToFit()
                self!.view.addSubview(self!.timeToolBar)
                
                self!.timePickerShown = true
            }
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.remm()
        }
    }
    @IBAction func cancelClick(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self!.delegate?.cancelButtonTapped()
            self!.dismiss(animated: true, completion: nil)
        }
    }

    @objc func onDateDoneButtonClick() {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
        dateFormatter.dateFormat = "dd-MM-YYYY"
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.setDate.text = self.dateFormatter.string(from: self.datePicker.date)
            self.datePickerShown = false
        }
    }
    
    @objc func onTimerDoneButtonClick() {
        timeToolBar.removeFromSuperview()
        timePicker.removeFromSuperview()
        dateFormatter.dateFormat = "hh:mm a"
//        //        let someDate = Date().addingTimeInterval(1)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.setTime.text = self.dateFormatter.string(from: self.timePicker.date)
        }
        timePickerShown = false
    }
    
    @objc func timerCancelButtonClicked(){
        timeToolBar.removeFromSuperview()
        timePicker.removeFromSuperview()
        timePickerShown = false
    }
    
    @objc func dateCancelButtonClicked(){
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
        datePickerShown = false
    }
    
    
    func remm() {
        DispatchQueue.main.async {
        let eventStore = EKEventStore()
            eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                DispatchQueue.main.async {

                let addedDate = "\(self.setDate.text!) \(self.setTime.text!)"
                let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy hh:mm a"
                let startDate = formatter.date(from: addedDate)
                let endDate = startDate?.addingTimeInterval(30*60)
                let alarmTime = startDate?.addingTimeInterval(-10*60)
                let alarm = EKAlarm(absoluteDate: alarmTime!)

                if (granted) && (error == nil) {
                    let event = EKEvent(eventStore: eventStore)
                        event.title = "Deposit Due Notification"
                        event.startDate = startDate
                        event.endDate = endDate
                        event.notes = self.reminderNote.text!
                        event.addAlarm(alarm)
                        event.calendar = eventStore.defaultCalendarForNewEvents
                    var event_id = ""
                    do{
                        try eventStore.save(event, span: .thisEvent)
                        event_id = event.eventIdentifier
                    }
                    catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "",
                                                      message: "Something Went Wrong. Please Try After Some Time.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { action in self.delegate?.submitButtonTapped()
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    if(event_id != ""){
                        print("event added !")
                        let alert = UIAlertController(title: "Alert",
                                                      message: "Due Date Reminder Set On Calender Successfully.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { action in self.delegate?.submitButtonTapped()
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "",
                                                      message: "Something Went Wrong. Please Try After Some Time.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { action in self.delegate?.submitButtonTapped()
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            })
        }
    }
}
