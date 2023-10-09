//
//  messagesViewController.swift
//  mScoreNew
//
//  Created by Perfect on 21/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

// msgs and offr view
import UIKit

class messagesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var table: UITableView!{
        didSet{
           table.isHidden = true
        }
    }
    
    var fetchedMsgsOrOffers:[Messages] = []
    var msghead     = [String]()
    var msgDetail   = [String]()
    var msgdate     = [String]()
    var msgOrOffer  = Int()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        table.estimatedRowHeight = 40.0
//        table.rowHeight = UITableViewAutomaticDimension
        if msgOrOffer == 0{
            navItem.title = "Messages"
        }
        else if msgOrOffer == 1{
            navItem.title = "Offers"
        }
        else{
            navItem.title = ""
        }
        do{
            fetchedMsgsOrOffers = try coredatafunction.fetchObjectofMessage()
            for fetchedMsgOrOffr in fetchedMsgsOrOffers
            {
                if msgOrOffer == fetchedMsgOrOffr.value(forKey: "messagType") as! Int
                {
                    msghead.append(fetchedMsgOrOffr.value(forKey: "messagHead") as! String)
                    msgdate.append(Date().formattedDateFromString(dateString: fetchedMsgOrOffr.value(forKey: "messagDate") as! String,ipFormatter: "MM/dd/yyyy HH:mm:ss a", opFormatter: "dd MMM yyyy")!)
                    msgDetail.append(fetchedMsgOrOffr.value(forKey: "messagDetail") as! String)
                }
            }
        }
        catch
        {
        }
        // cell top space settings
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        table.reloadData()
        
        if msghead.count == 0{
            self.present(messages.msg("No data to display."), animated: true, completion: nil)
        }
        else{
            table.isHidden = false
        }
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return msghead.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! messageTableViewCell
            cell.head.text = msghead[indexPath.item]
            cell.date.text = msgdate[indexPath.item]
            cell.msg.text = msgDetail[indexPath.item]
        return cell
    }
//    func formattedDateFromString(dateString: String) -> String?
//    {
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss a"
//        if let date = inputFormatter.date(from: dateString)
//        {
//            let outputFormatter = DateFormatter()
//            outputFormatter.dateFormat = "dd MMM yyyy"
//            return outputFormatter.string(from: date)
//        }
//        return nil
//    }
}
