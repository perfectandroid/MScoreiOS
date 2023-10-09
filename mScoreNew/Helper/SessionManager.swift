//
//  SessionManager.swift
//  mScoreNew
//
//  Created by MacBook on 16/12/22.
//  Copyright © 2022 PSS. All rights reserved.
//

import Foundation

class SessionManager{
    
   // var logOutHandler : (() -> Void)?
    
    static let shared = SessionManager()
    
    private init(){}
    
    func logOut(completion : @escaping (() -> Void)) {
        
        DispatchQueue.main.async {
            completion()
        }
       
    }
    
    func sessionExpiredCall(){
        let storyBoard  = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController() as! SplashViewController
        vc.isLogOutCalled(true)
        vc.outSession = true
        UIApplication.shared.windows.first?.rootViewController = vc
        
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    
}

 protocol OwnAccountDetailsProtocol {
     
     func ownAccountDetails(subMode:Int,token:String,custID:String,completion:@escaping(Result<NSDictionary,NetworkError>)->Void)
}


class ParserViewModel : NetworkManagerVC,OwnAccountDetailsProtocol{
    
    
    
    func ownAccountDetails(subMode: Int, token: String, custID: String, completion: @escaping (Result<NSDictionary, NetworkError>) -> Void) {
        
        let urlPath = APIBaseUrlPart1+"/AccountSummary/OwnAccounDetails"
        
        let arguments = ["FK_Customer":"\(custID)","ReqMode":"13",
                         "token":"\(token)","BankKey":BankKey,
                         "BankHeader":BankHeader,
                         "SubMode":"\(subMode)"]
        self.APICallHandler(urlString: urlPath, method: .post, parameter: arguments) { getResul in
            
            completion(getResul)
            
        }
    }
    
    func apiParser(urlDomin:String=APIBaseUrlPart1,urlPath:String,arguments:[String:String],completion: @escaping (Result<NSDictionary, NetworkError>) -> Void) {
        
        let urlCompletePath = urlDomin+urlPath
        
        self.APICallHandler(urlString: urlCompletePath, method: .post, parameter: arguments) { getResult in
            DispatchQueue.main.async {
                completion(getResult)
            }
            
        }
        
        
    }
    
    func parserErrorHandler(_ catchError:NetworkError,vc:UIViewController){
        var msg = ""
        
        let response = self.apiErrorResponseResult(errResponse: catchError)
        msg = response.1
        
        
        DispatchQueue.main.async {
            vc.present(messages.msg(msg), animated: true, completion: nil)
        }
    }
    
    func mainThreadCall(comepletion:@escaping()->()) {
        DispatchQueue.main.async {
            comepletion()
        }
    }
    
    func resultHandler(exMsgKey:String="EXMessage",datas:NSDictionary,modelKey:String) -> (String,AnyHashable) {
        let exMsg = datas.value(forKey: exMsgKey) as? String ?? ""
        let modelDetails = datas.value(forKey: modelKey) as? NSDictionary
        
        
        return (exMsg,modelDetails)
    }
    
    func successFailhandler(statusCode:Int,modelInfo:NSDictionary,exmsg:String,showFailure:errorShow = .hide,vc:UIViewController,msgShow:Bool=true,comepletion:@escaping(Bool)->()){
        
        let modelInfo = modelInfo
        let response = modelInfo.value(forKey: "ResponseMessage") as? String ?? ""
        let exMsg = exmsg
        
        
        if statusCode == 0{
            
            
            print("Response: ====== Success ==========")
//            if exMsg == ""{
                
            comepletion(true)
                
//            }else{
//                self.mainThreadCall {
//                    vc.present(messages.msg(exMsg), animated: true, completion: nil)
//                }
//            }
            
        }else{
                       
            
            print("Response: ====== Failed ==========")
            
            if !modelInfo.isEqual(to: [:]){
                
                if response == "Invalid Token"{
                    
                    SessionManager.shared.logOut {
                        
                        SessionManager.shared.sessionExpiredCall()
                        return
                    }
                    
                }else{
                    
                    if showFailure == .hide{
                    
                    self.mainThreadCall {
                        let msgString = response == "" ? exMsg : response
                        if msgString != "" && msgShow == true{
                            vc.present(messages.msg(msgString), animated: true, completion: nil)
                        }
                    }
                    
                    }else{
                        
                        comepletion(false)
                        
                    }
                    
                }
                
            }else{
                
                self.mainThreadCall {
                    vc.present(messages.msg(exMsg), animated: true, completion: nil)
                }
                
                
            }
        }
        
    }
    
}


struct Facade{
    
    func setImage(imageView:UIImageView,img:UIImage) {
        imageView.image = img
    }
}

enum errorShow{
    case hide
    case show
    
}



public func tableEmptyAlertView(show:Bool=false,table:UITableView,text:String = "No data found"){
    
    if show==false{
        table.backgroundView = nil
    }
    else
    {
        let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: table.bounds.size.width, height: table.bounds.size.height))
               noDataLabel.text             = text
               noDataLabel.textColor        = UIColor.black
               noDataLabel.font             = UIFont(name: "Open Sans", size: 13)
               noDataLabel.textAlignment    = .center
        table.backgroundView = noDataLabel
        table.separatorStyle = .none
    }
}







//struct SessionViewModel{
//    
//    weak var delegate : SessionLogOutDelegate?
//    
//    
//}
