//
//  Alert.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/26.
//  Copyright © 2017年 CGC. All rights reserved.
//

import Foundation
import UIKit

protocol ShowAlertProtocol {
    
    func showAlert(title: String,
                   massage: String?,
                   style: UIAlertControllerStyle,
                   actions:(String, ((UIAlertAction) -> Void)?)...)
    
}

extension UIViewController: ShowAlertProtocol {
    
    func showAlert(title: String,
                   massage: String? = nil,
                   style: UIAlertControllerStyle = .alert,
                   actions: (String, ((UIAlertAction) -> Void)?)...) {
        
        let alertCtr = UIAlertController(title: title, message: massage, preferredStyle: style)
        
        actions.forEach { (action: (String, ((UIAlertAction) -> Void)?)) in
            
            alertCtr.addAction(
                UIAlertAction(title: action.0, style: .default, handler: action.1)
            )
        }
        
        self.present(alertCtr, animated: true, completion: nil)
    }
    
}
