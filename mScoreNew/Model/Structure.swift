//
//  Details.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation
//res for error
//res message display
struct errorResponseValue
{
    var title:String
    var msg:String
}
//res message display
struct responseValue
{
    var title:String
    var msg:String
    var resValue:keyValue
}
struct keyValue
{
    var key:[String]
    var value:[String]
}
// own bank otpscreen
struct ImpsNeftRtgsPaymentValues
{
    var encryAcc:String
    var encryAccModule:String
    var encryBeneName:String
    var encryBeneAccNumber:String
    var encryIFSC:String
    var encryAmount:String
    var encryMode:String
    var encryBeneAdd:String
    var encryPin:String
    var imei:String
    var token:String
}
// benificiarylist
struct reciverlist
{
    var list:[listData]
}
struct listData
{
    var beneName:String
    var beneIfsc:String
    var beneAccNumb:String

}
// senderReceiverList
struct senderreciverlist
{
    var list:[senderreciverlistData]
}
struct senderreciverlistData
{
    var UserID:Int
    var FK_SenderID:Int
    var SenderName:String
    var SenderMobile:String
    var ReceiverAccountno:String
}
// settings
struct settingsInfo
{
    var acc:String
    var accTypeShoort:String
    var days:String
    var hrs:String
    var mins:String
}
struct standingInstraInfoList {
    var standingInstraInfoListData:[standingInstraInfo]
}

struct standingInstraInfo
{
    var slNo:String
    var source:String
    var destination:String
    var date:String
    var amount:Double
}

struct moduleSummaryDetailsData
{
    var slNo:Int
    var head:String
    var data:String
   
}


//  details struct
//struct details
//{
//    var acInfo:[cusInfo]
//}
//struct cusInfo
//{
//    var customerId:Int
//    var customerNo:String
//    var customerName:String
//    var customerAddress1:String
//    var customerAddress2:String
//    var customerAddress3:String
//    var mobileNo:String
//    var pin:String
//    var default1:NSNull
//    var login:Int
//    var TokenNo:String
//    var DMenu:String
//    var accounts:[accInfo]
//}
//
//struct accInfo
//{
//    var account:Int
//    var demandDeposit_id:Int
//    var acno:String
//    var lastacessdate:String
//    var module:String
//    var acType:String
//    var typeShort:String
//    var branchCode:String
//    var branchName:String
//    var branchShort:String
//    var depositDate:String
//    var oppmode:String
//    var FK_CustomerID:String
//    var AvailableBal:Float32
//    var UnClrBal:Float32
//    var transactions:[transInfo]
//}
//struct transInfo
//{
//    var transaction:Int
//    var fk_DemandDeposit:String
//    var effectDate:String
//    var amount:String
//    var chequeNo:String
//    var chequeDate:String
//    var narration:String
//    var transType:String
//    var remarks:String
//    var OpeningBal:NSNull
//}

