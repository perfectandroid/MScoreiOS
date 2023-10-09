//  SectionSearchViewController.swift
//  mScoreNew
//  Created by Perfect on 28/11/18.
//  Copyright © 2018 PSS. All rights reserved.

import UIKit

class SectionSearchViewController: NetworkManagerVC,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var sectionName     : UITextField!
    @IBOutlet weak var nothingToDisplay: UILabel!
    
    @IBOutlet weak var sectionsInTable : UITableView!
    
//    var kseb: KSEBSections?
    var fullSection     = [String]()
    var selectedSection = String()
    var TokenNo         = String()
    
    var checkValidSection: Bool {
        return !self.sectionName.text!.isEmpty && self.sectionName.text!.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
        }
    
    private var parserViewModel : ParserViewModel = ParserViewModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do
        {
            let fetchedCusDetails = try coredatafunction.fetchObjectofCus()
            for fetchedCusDetail in fetchedCusDetails
            {
                TokenNo = fetchedCusDetail.value(forKey: "tokenNum") as! String
                
            }
        }
        catch
        {

        }
        
        self.hideKeyboardWhenTappedAround()
        sectionName.addTarget(self, action: #selector(SectionSearchViewController.textFieldDidChange), for: .editingChanged)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
   
    
    fileprivate func fetchSectionListFromApi() {
        let url     = URL(string: BankIP + APIBaseUrlPart + "/KSEBSectionList?Sectionname=" + sectionName.text! + "&BankKey=\(BankKey)")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task    = session.dataTask(with: url!) { data,response,error in
            
            if error != nil
            {
                self.present(errorMessages.error(error! as NSError), animated: true, completion: nil)
                
                return
            }
            let dataInString = String(data: data!, encoding: String.Encoding.utf8)
            if dataInString == "{\"KSEBSectionList\":[]}"
            {
                DispatchQueue.main.async { [weak self] in
                    self?.fullSection = []
                    self?.sectionsInTable.reloadData()
                    self?.nothingToDisplay.text = "Nothing to display"
                }
            }
            else
            {
                do{
                    
                    let datas = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    let secInfos = datas.value(forKey: "KSEBSectionList") as! [NSDictionary]
                    self.fullSection = []
                    
                    for secInfo in secInfos
                    {
                        let secCode = secInfo.value(forKey: "SectionCode") as! NSString
                        var secName = secInfo.value(forKey: "SectionName") as! String
                        secName = secName.replacingOccurrences(of: "\t",
                                                               with: "",
                                                               options: NSString.CompareOptions.literal,
                                                               range: nil)
                        
                        self.fullSection.append(secName + "     " + String(secCode))
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.sectionsInTable.reloadData()
                        
                        self?.nothingToDisplay.text = ""
                    }
                }
                catch{
                    DispatchQueue.main.async { [weak self] in
                        self?.fullSection = []
                        self?.sectionsInTable.reloadData()
                        self?.nothingToDisplay.text = "Nothing to display"
                    }
                }
            }
        }
        task.resume()
    }
    
    //FIXME: ========= searchSectionAreaListApi() ==========
    fileprivate func searchSectionAreaListApi(sections: String){
        
        // network reachability checking
       
        if Reachability.isConnectedToNetwork() {
            parserViewModel.mainThreadCall {
                self.present(messages.msg(networkMsg), animated: true, completion: nil)
            }
            return
        }
        
        
        let ksebSectionName = sections
        let searchTxt = checkValidSection == false ? "00000" : ksebSectionName
        print(checkValidSection)
        let urlPath = "/Recharge/KSEBSectionDetails"
        let arguMents = ["Token":TokenNo,
                         "BankKey":BankKey,
                         "BankHeader":BankHeader,
                         "SectioName":searchTxt]
        
        parserViewModel.apiParser(urlPath: urlPath, arguments: arguMents) { getResult in
            
            switch getResult{
            case.success(let datas):
                self.apiResponsStatusCheck(of: Int.self, datas) { statusCode in
                    let responseViewModel =  self.parserViewModel.resultHandler(datas: datas,modelKey:"KSEBSectionDetails")
                    let exMsg = responseViewModel.0
                    let modelInfo = responseViewModel.1 as? NSDictionary ?? [:]
                    if statusCode == 2 || exMsg == "No Data Found"{
                        
                        self.parserViewModel.mainThreadCall {
                            self.fullSection = []
                            self.sectionsInTable.reloadData()
                            self.nothingToDisplay.text = "Nothing to display"
                            
                        }
                        return
                    }
                    self.parserViewModel.successFailhandler(statusCode: statusCode, modelInfo: modelInfo, exmsg: exMsg,vc:self) { status in
                        
                    
                        
                        let ksebSectionList = modelInfo.value(forKey: "KSEBSectionList") as? [NSDictionary] ?? []
                    
                        self.fullSection = []
                        
                        if ksebSectionList.count>0{
                        ksebSectionList.forEach { item in
                            let sectionCode = item.value(forKey: "SectionCode") as? Int ?? 0000
                            
                            let sectionName = (item.value(forKey: "SectionName") as? String ?? "").replacingOccurrences(of: "\t", with: "")
                            self.fullSection.append("\(sectionName)   \(sectionCode)")
                         }
                        }
                        
                        
                        
                        self.parserViewModel.mainThreadCall {
                            
                            self.sectionsInTable.reloadData()
                            self.nothingToDisplay.text = ""
                            
                        }
                        
                    }
                }
            case.failure(let errorJson):
                self.parserViewModel.parserErrorHandler(errorJson, vc: self)
            }
            
        }
        
        
    }
    
    @objc func textFieldDidChange()
    {
        
        searchSectionAreaListApi(sections: sectionName.text ?? "")
        
        
        //fetchSectionListFromApi()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if fullSection.count == 0
        {
            
            self.parserViewModel.mainThreadCall {
                self.nothingToDisplay.text = "Nothing to display"
            }
            return 0
            
        }
        else
        {
            return fullSection.count
        }
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if fullSection.count != 0
        {
            return 40
        }
        else
        {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sections") as! SectionTableViewCell
        cell.sectionsToDisplay.text = fullSection[indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let currentCell     = tableView.cellForRow(at: indexPath) as! SectionTableViewCell
        selectedSection     = currentCell.sectionsToDisplay.text!
        selectedSectionName = selectedSection
        navigationController?.popViewController(animated: true)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) {
                  return false
              }
             
              return super.canPerformAction(action, withSender: sender)
    }


}


