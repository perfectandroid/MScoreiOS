//
//  errorMessages.swift
//  mScoreNew
//
//  Created by Perfect on 26/12/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation

public class errorMessages
{
    class func error (_ error:NSError) -> UIAlertController
    {
        
        var alert = UIAlertController()
        
        
            if (error as NSError).code == -1001
            {
                alert = UIAlertController(title: "", message: "The request timed out.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))

            }
            else if (error as NSError).code == 500
            {
                alert = UIAlertController(title: "", message: "An internal server error occurred.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                

            }
            else
            {
                alert = UIAlertController(title: "", message: "An error has occurred.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            }
        
        
        
       
       
        return alert
    }
    
}

