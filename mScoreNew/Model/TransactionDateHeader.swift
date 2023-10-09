//
//  TransactionDateHeader.swift
//  mScoreNew
//
//  Created by Perfect on 16/11/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import UIKit
protocol ExpandableHeaderViewDelegate
{
    func toggleSection(header:TransactionDateHeader, section:Int)
}
class TransactionDateHeader: UITableViewHeaderFooterView
{
    var delegate:ExpandableHeaderViewDelegate?
    var section:Int!
    
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    @objc func selectHeaderAction(gestureRecognizer:UITapGestureRecognizer)
    {
        let cell = gestureRecognizer.view as! TransactionDateHeader
        delegate?.toggleSection(header: self, section: cell.section)
//        cell.section = section
//        cell.delegate = self as? ExpandableHeaderViewDelegate
    }
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    func customInit(title: String, section:Int, delegate:ExpandableHeaderViewDelegate)
    {
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.textLabel?.textColor = UIColor.black
        self.contentView.backgroundColor = UIColor.lightGray
    }

}
