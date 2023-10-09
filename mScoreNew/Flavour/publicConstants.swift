//
//  APIKeys.swift
//  mScoreNew
//  Created by Perfect on 16/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation

public let APIBaseUrlPart       = "/api/MV3"
public let APIBaseUrlPart1      = "/api"
//public let appLink = "itms-apps://itunes.apple.com/in/app/ccscb/id1450067825?mt=8"

//appstore Link
public var appLink              = "itms-apps://itunes.apple.com"
public var appName              = ""
//new in 3.0.0

public var TestingImageURL      = ""
public var TestingMachineId     = ""
public var TestingMobileNo      = ""
public var TestingURL           = ""
public var TestingBankHeader    = ""
public var TestingBankKey       = ""


public var BankIP               = ""
public var ImageURL             = ""

public var CompanyLogoImageCode = ""
public var AppIconImageCode     = ""
public var EwireCardService     = ""

public var BankKey              = ""
public var BankHeader           = ""

public var certificates: [Data] =
{
    let url = Bundle.main.url(forResource: OriginalCertName, withExtension: "cer")
    let data = try! Data(contentsOf: url!)
    return [data]
}()

public var instanceOfEncryptionPost    : EncryptionPost    = EncryptionPost()
