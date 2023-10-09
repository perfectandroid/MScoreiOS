//
//  FAQViewController.swift
//  mScoreNew
//
//  Created by Perfect on 06/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit


class faqViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!{
        didSet{
            navItem.title = "Frequently Asked Questions"
        }
    }
    @IBOutlet weak var faqTable: UITableView!{
        didSet{
            faqTable.estimatedRowHeight = 40
            faqTable.rowHeight = UITableView.automaticDimension
        }
    }
    var dataSource = [ExpandingTableViewCellContent]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        dataSource = [ExpandingTableViewCellContent(title: "How secured is Mscore ?", descri: "It is fully secured mobile application which is fully encrypted. Also, it is built with advanced security features."),
                      ExpandingTableViewCellContent(title: "What is End-to-End Data Encryption ?", descri: "It is a methode of secure communication that prevents third parties from accessing data while it's transferred from one end system or device to another."),
                      ExpandingTableViewCellContent(title: "What is a Virtual Card ? ", descri: "A virtual card is a randomly-generated number linked with your account number. It is encrypted into a card to help you perform a smoother transaction at the bank."),
                      ExpandingTableViewCellContent(title: "How does a Virtual Card works ?", descri: "By scanning the QR code on the back of your virtual card, one can do any kind of transaction at the bank effortlessly."),
                      ExpandingTableViewCellContent(title: "How to generate QR code ?", descri: "Tap on the virtual card on the screen. you get a virtual card instantly with your Name and Photograph printed on the front and QR code and Bar code at the back."),
                      ExpandingTableViewCellContent(title: "How to generate a statement report ?", descri: "Tap on the Account Details on the screen. Tap the screen icon, enter the valid dates, tap on the statement. Now you can view/download the report."),
                      ExpandingTableViewCellContent(title: "How to set a due date reminder ?", descri: "Under due date list, tap on the bell icon. Then enter the time & date. Note that the Date can only be set prior to the due date and before the current date.")]
    }
    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = faqTable.dequeueReusableCell(withIdentifier: "faqCell") as! faqTableViewCell
        cell.set(content: dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = dataSource[indexPath.row]
        content.expanded = !content.expanded
        faqTable.reloadRows(at: [indexPath], with: .automatic)
    }
}
