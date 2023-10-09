//
//  SearchResultViewController.swift
//  mScoreNew
//
//  Created by Perfect on 07/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
import WebKit


class StatementResultViewController: UIViewController, URLSessionDelegate , WKNavigationDelegate
{
    
    @IBOutlet weak var viewStatementWV: WKWebView!
    @IBOutlet weak var blurView                 : UIView!
    @IBOutlet weak var activityIndicator        : UIActivityIndicatorView!
    
    var fileName = String()
    var filePath = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewStatementWV.navigationDelegate = self
        self.navigationItem.leftItemsSupplementBackButton  = true

        
            let fileURL = URL(string: "http://docs.google.com/viewer?embedded=true&url=" + BankIP + "/" + self.filePath + "/" + self.fileName )
        DispatchQueue.main.async {
            self.viewStatementWV.load(URLRequest(url: fileURL!))
        }
    }
        
    @IBAction func Back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        self.blurView.isHidden = false
        self.activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()
        })
    }

}

