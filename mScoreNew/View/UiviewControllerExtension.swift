//
//  extensionForUiview.swift
//  mScoreNew
//
//  Created by Perfect on 23/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

import Foundation

extension UIViewController
{
  
    
    
    
    func hideKeyboardWhenTappedAround()
    {
        let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    func showToast(message: String, controller: UIViewController)
    {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 7;
        toastContainer.clipsToBounds  =  true
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(controller.view.frame.height/40)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 10)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -10)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -10)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 10)
        toastContainer.addConstraints([a1, a2, a3, a4])
        
        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 30)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -30)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -40)
        controller.view.addConstraints([c1, c2, c3])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    func cardView(_ view:UIView)
    {
        view.layer.cornerRadius     = 10.0
        view.layer.shadowColor      = UIColor.gray.cgColor
        view.layer.shadowOffset     = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowRadius     = 15.0
        view.layer.shadowOpacity    = 0.7

    }
    
    func SetImage(ImageCode : String, ImageView: UIImageView, Delegate : URLSessionDelegate){
            // network reachability checking
        if Reachability.isConnectedToNetwork()
        {
            DispatchQueue.main.async {
                self.present(messages.msg(networkMsg), animated: true)
            }
            return
        }
        let url                 = URL(string: ImageURL + ImageCode)!
        var request             = URLRequest(url: url)
            request.httpMethod  = "get"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession(configuration: .default,
                                delegate: Delegate,
                                delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error")
                return
            }
            if let res = response as? HTTPURLResponse {
                let imaged = data
                print(imaged)
                print(res.statusCode)
            
                if res.statusCode == 200 {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imaged)
                        if image != nil{
                            ImageView.image = image
                        }
                        else{
                        }
                    }
                }
                else {
                }
             } else {
                 print("Couldn't get response code for some reason")
             }
            
        }
        task.resume()
    }
    
    
}






