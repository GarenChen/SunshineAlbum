//
//  DismissAction.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/19.
//  Copyright © 2017年 CGC. All rights reserved.
//

import Foundation
import UIKit

@objc protocol DismissAction: NSObjectProtocol  {
    @objc var rightCancleItem: UIBarButtonItem { get }
    @objc func dismissAction()
}

extension  UIViewController: DismissAction {
    
    @objc var rightCancleItem: UIBarButtonItem {
		return UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(dismissAction))
    }
    
    @objc func dismissAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
