//
//  APIKeys.swift
//  mScoreNew
//
//  Created by Perfect on 16/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation
import UIKit

public let mobilePadNextButton = UIButton(type: UIButton.ButtonType.custom)

public var customerPhoneNum     = ""
public var UDID                 = ""
public var selectedSectionName  = String()
public let blueColor            = UIColor(red: 0.0/255.0,
                                          green: 128.0/255.0,
                                          blue: 255.0/255.0,
                                          alpha: 0.8)
public let lightGreyColor       = UIColor(red: 202.0/255.0,
                                          green: 204.0/255.0,
                                          blue: 206.0/255.0,
                                          alpha: 0.8)
public let greenColour          = UIColor(red: 0.0/255.0,
                                          green: 100.0/255.0,
                                          blue: 0.0/255.0,
                                          alpha: 0.8)
public let underLineGreen      = UIColor(red: 0.0/255.0,
                                         green: 59.0/255.0,
                                          blue: 13.0/255.0,
                                          alpha: 1.0)
public let prepaidRechargeValues  = ["Airtel \n 1",
                                    "V! \n 2",
                                    "BSNL \n 3",
                                    "Jio \n 400"]
public let postpaidRechargeValues = ["Airtel \n 31",
                                     "V! \n 33",
                                     "BSNL Mobile \n 36"]
public let dthRechargeValues      = ["Airtel DTH \n 23",
                                     "Big TV DTH \n 20",
                                     "Dish TV DTH \n 18",
                                     "Sun DTH \n 22",
                                     "Tata Sky DTH \n 19",
                                     "Videocon DTH \n 21"]
public let landlineRechargeValues = ["Airtel Landline \n 42",
                                     "BSNL Landline \n 37",
                                     "MTNL Landline \n 41"]
public let datacardRechargeValues = ["Mbrowse \n 13",
                                     "NetConnect + \n 4",
                                     "NetConnect 3G \n 5",
                                     "Tata Photon + \n 9"]
public let fullCircleValues       = ["Andhra Pradesh",
                                     "Assam",
                                     "Bihar & Jharkhand",
                                     "Chennai",
                                     "Delhi",
                                     "Gujarat",
                                     "Haryana",
                                     "Himachal Pradesh",
                                     "Jammu & Kashmir",
                                     "Karnataka",
                                     "Kerala",
                                     "Kolkata",
                                     "Madhya Pradesh & Chattisgarh",
                                     "Maharashtra & Goa(except mumbai)",
                                     "Mumbai",
                                     "North East",
                                     "Orissa",
                                     "Punjab",
                                     "Rajasthan",
                                     "Tamil Nadu",
                                     "Uttar Pradesh - East",
                                     "Uttar Pradesh - West",
                                     "West Bengal"]
//public let rechargeAccType        = ["Savings bank",
//                                     "Current account",
//                                     "Cash credit",
//                                     "Member loan",
//                                     "Recurring deposit",
//                                     "Jewell loan",
//                                     "GDS"]
public let rechargeAccType        = ["Savings Bank",
                                     "Current Account",
                                     "Cash Credit"]
public let updationHour           = ["00","01","02","03","04","05",
                                     "06","07","08","09","10","11",
                                     "12","13","14","15","16","17",
                                     "18","19","20","21","22","23"]

public let oddCell       = UIColor(red: 206.0/255.0,
                                   green: 209.0/255.0,
                                   blue: 209.0/255.0,
                                   alpha: 1.0)
public let headerCell    = UIColor(red: 175.0/255.0,
                                   green: 192.0/255.0,
                                   blue: 211.0/255.0,
                                   alpha: 1.0)
public let lightBlue    = UIColor(red: 175.0/255.0,
                                  green: 206.0/255.0,
                                  blue: 255.0/255.0,
                                  alpha: 1.0)

public let aboutUsText = """


* Supports multiple accounts of the same customer
* Supports Savings Bank and Current Account
* Statement Viewing facility with filtering
* Search option based on the Date, Amount, Transaction Type
* Sort transactions on Date, Amount
* Private & Public messages
* Fully secured with encryption
* Smart synchronization
* Virtual card
* Rating & Feedback
* Branch Details with Location
* Passbook Summary Details
* Complete Account Summary
* Due notifications
* Standing Notifications
* Customer Alert (Reminders)

Advantages for Customers
    
* Access Bank statement from anywhere
* No need to visit the Bank for updating passbook
* Passbook is updated automatically
* Saves Time & Money for Customers
* Get personalized offers from Bank
* Customers can Recharge any prepaid Mobile/ DTH
* Send money to any account, any time, anywhere
* Send messages to Customer regarding new offers and events

Advantages for Bank
    
* No Paper, Passbook nor Printing is required
* No dedicated staffs required to perform Passbook printing
* Saves Time & Money for Bank
* Next Generation Banking for Next Generation Customers
* Paperless Banking

Security

* Secured Transmission using TLS 1.2 protocol over the transport layer
* End to End Data Encryption using application-level functions
* Random token generation and verification for each transaction
* Encrypted Database
* PIN-based primary authentication
* OTP based dual authentication
* Security Policy implemented in firewall
"""

var DashBoardColors: [UIColor] = [UIColor(red: 79/255, green: 195/255, blue: 247/255, alpha: 1),
                                  UIColor(red: 240/255, green: 98/255, blue: 146/255, alpha: 1),
                                  UIColor(red: 255/255, green: 213/255, blue: 79/255, alpha: 1),
                                  UIColor(red: 129/255, green: 199/255, blue: 132/255, alpha: 1),
                                  UIColor(red: 149/255, green: 117/255, blue: 205/255, alpha: 1),
                                  UIColor(red: 229/255, green: 115/255, blue: 115/255, alpha: 1),
                                  UIColor(red: 161/255, green: 136/255, blue: 127/255, alpha: 1),
                                  UIColor(red: 100/255, green: 181/255, blue: 246/255, alpha: 1),
                                  UIColor(red: 186/255, green: 104/255, blue: 200/255, alpha: 1),
                                  UIColor(red: 121/255, green: 134/255, blue: 203/255, alpha: 1),
                                  UIColor(red: 77/255, green: 182/255, blue: 172/255, alpha: 1),
                                  UIColor(red: 255/255, green: 241/255, blue: 118/255, alpha: 1),
                                  UIColor(red: 255/255, green: 138/255, blue: 101/255, alpha: 1),
                                  UIColor(red: 77/255, green: 208/255, blue: 225/255, alpha: 1),
                                  UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1),
                                  UIColor(red: 174/255, green: 213/255, blue: 129/255, alpha: 1),
                                  UIColor(red: 255/255, green: 183/255, blue: 77/255, alpha: 1),
                                  UIColor(red: 144/255, green: 164/255, blue: 174/255, alpha: 1),
                                  UIColor(red: 179/255, green: 136/255, blue: 255/255, alpha: 1),
                                  UIColor(red: 220/255, green: 231/255, blue: 117/255, alpha: 1)]
