//
//  APINetwork.swift
//  mScoreNew
//
//  Created by MacBook on 05/12/22.
//  Copyright © 2022 PSS. All rights reserved.
//

import Foundation

// MARK: APIHANDLER

public enum HTTPMethod:String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError:Error{
    case badURL(status:Int,msg:String)
    case jsonError(status:Int,msg:String)
    case badRequest(status:Int,msg:String)
    case noData(status:Int,msg:String)
    case custom(status:Int,msg:String,Error)
}


class NetworkManagerVC:UIViewController,URLSessionDelegate{
    
    let EXMessage = "EXMessage"
    let ResponseMessage = "ResponseMessage"
    let ResponseCode = "ResponseCode"
    
    func APICallHandler(urlString:String,method :HTTPMethod = HTTPMethod.post, parameter:[String:String]=[:],completion:@escaping(Result<NSDictionary,NetworkError>)->Void)  {
        
        
        
        let baseUrl = BankIP + urlString
        
        
        
        let urls = URL(string: baseUrl)
        
        print("called url : - \(String(describing: urls)) -- \(parameter)")
        
        
        
        
        var request = URLRequest(url: urls!)
        
        request.timeoutInterval = 45
        
        request.setValue(Constants.APIHeaders.contentTypeValue, forHTTPHeaderField: Constants.APIHeaders.kContentType)
        
        request.httpMethod = method.rawValue
        
        do{
            
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            
        }
        catch{
            
            completion(.failure(.jsonError(status: 0, msg: "Something went wrong")))
            
            print("json error")
            
        }
        
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            
            
            let httpStatusCode = (response as? HTTPURLResponse)?.statusCode as? Int ?? -1
            
            if let error = error {
                
                completion(.failure(.custom(status: 0, msg: "Something went wrong", error)))
            }else if httpStatusCode != 200{
                completion(.failure(.badURL(status: httpStatusCode, msg: "Bad Url")))
                
            }else{
                guard let datas = data else {
                    completion(.failure(.noData(status: httpStatusCode, msg: "No Data Found")))
                    
                    return
                }
                
                do{
                    let jsonNsDictionary = try? JSONSerialization.jsonObject(with: datas, options: .mutableContainers) as? NSDictionary ?? [:]
                    
                    completion(.success(jsonNsDictionary!))
                    
                }
                catch{
                    
                    print("json response error")
                    completion(.failure(.jsonError(status: 0, msg: "Something went wrong")))
                }
            }//else close
            
            
            
        }
        
        task.resume()
        
        
        
    }
    
    func apiResponsStatusCheck<T>(of type: T.Type = T.self,_ datas:NSDictionary,completion:@escaping((T)->Void)){
        let successStatus = datas.value(forKey: "StatusCode") as? Int ?? -11
        completion(successStatus as! T)
    }
    
    func responseParse<T>(type:T.Type = T.self,datas:NSDictionary,key:String) -> T?{
        if let value = datas.value(forKey: key) as? T{
            return value
        }
        return nil
    }
    
    func messageView(onView:UIView){
        let blurview = UIView()
        blurview.backgroundColor  =  UIColor.black.withAlphaComponent(0.5)
        onView.addSubview(blurview)
        blurview.bounds = onView.bounds
        
        let stackview = UIStackView()
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .vertical
        stackview.roundCorners(5, UIRectCorner.allCorners)
        stackview.frame.size = CGSize(width: onView.frame.width - 15, height: 200)
        stackview.center = onView.center
        
        let messagelabel = UILabel()
        let okbutton = UIButton()
        okbutton.setTitle("Ok", for: UIControl.State.normal)
        stackview.addArrangedSubview(messagelabel)
        stackview.addArrangedSubview(okbutton)
        
        
        
    }
    
    func displayIndicator(activityView:UIActivityIndicatorView,blurview:UIView) {
        
        
        
        DispatchQueue.main.async {
            
            activityView.startAnimating()
            blurview.isHidden = false
            
        }
      
        
    }
    
    func removeIndicator(showMessagge:Bool,message:String,activityView:UIActivityIndicatorView,blurview:UIView){
        
        DispatchQueue.main.async{
            if showMessagge == true{
                self.present(messages.msg(message), animated: true, completion: nil)
            }
            blurview.isHidden = true
            activityView.stopAnimating()
        }
        
    }
    
    func apiErrorResponseResult(errResponse:NetworkError)->(Int,String){
        
        switch errResponse {
        case .badURL(let status, let msg):
            return (status,msg)
        case .jsonError(let status, let msg):
            return (status,msg)
        case .badRequest(let status, let msg):
            return (status,msg)
        case .noData(let status, let msg):
            return (status,msg)
        case .custom(let status, let msg, let error):
            debugPrint("apiErrorResponseResult:\(error.localizedDescription)")
            return (status,msg)
        }
    }
    
    
    
    
    
    
    
   
}



struct Constants {

    // API Keys
    struct APIKeys {
        //static var kClientKey = "JYRARXHZnEcTwGYa1sTS8mpR7WebBsH4Yn9Knsc-eAo"
    }

    // API Headers
    struct APIHeaders {
        static var kContentType = "Content-Type"
        static var contentTypeValue = "application/json"
    }


}

//protocol RequestHandler{
//    associatedtype RequestDataType
//    func makeRequest(from data:RequestDataType) -> URLRequest?
//}
//
//protocol ResponseHandler{
//    associatedtype ResponseDataType
//    func makeRequest(data:ResponseDataType,response:HTTPURLResponse) throws -> ResponseDataType
//}
//
//typealias APIHandler = RequestHandler & ResponseHandler
//
//
//extension RequestHandler {
//
//    func setQueryParams(parameters:[String: Any], url: URL) -> URL {
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
//        components?.queryItems = parameters.map { element in URLQueryItem(name: element.key, value: String(describing: element.value) ) }
//        return components?.url ?? url
//    }
//
//    func setDefaultHeaders(request: inout URLRequest) {
//        request.setValue(Constants.APIHeaders.contentTypeValue, forHTTPHeaderField: Constants.APIHeaders.kContentType)
//    }
//}
//
//
//
//
//struct Constants {
//
//    // API Keys
//    struct APIKeys {
//        //static var kClientKey = "JYRARXHZnEcTwGYa1sTS8mpR7WebBsH4Yn9Knsc-eAo"
//    }
//
//    // API Headers
//    struct APIHeaders {
//        static var kContentType = "Content-Type"
//        static var contentTypeValue = "application/json"
//    }
//
//
//}

