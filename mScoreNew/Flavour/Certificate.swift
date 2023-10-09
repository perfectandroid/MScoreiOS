//
//  Certificate.swift
//  CCSCB
//
//  Created by Perfect on 17/01/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation

//let certificates: [Data] =
//{
////    var url = Bundle.main.url(forResource: "certificate", withExtension: "cer")
//    
//    let data = try! Data(contentsOf: certURL!)
//    return [data]
//}()

extension UIViewController
{
    @objc(URLSession:didReceiveChallenge:completionHandler:) func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0
        {
            if let certificate = SecTrustGetCertificateAtIndex(trust, 0)
            {
                let data = SecCertificateCopyData(certificate) as Data
                if certificates.contains(data)
                {
                    completionHandler(.useCredential,URLCredential(trust: trust))
                    return
                }
            }
        }
        completionHandler(.cancelAuthenticationChallenge,nil)
    }
}
