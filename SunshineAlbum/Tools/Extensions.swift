//
//  Extensions.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/13.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

#if DEBUG
	func debuglog(_ items: Any...) {
		print(items)
	}
#else
	func debuglog(_ items: Any...) {
	}
#endif


// MARK: - reuserId
extension UIView {

    static var reusedId: String {
        return String(describing: self)
    }
    
}

// MARK: - find nearest controller
extension UIView {
    
    func nearestController() -> UIViewController? {
        
        var next = self.superview
        
        while next != nil {
            
            if let nextResponder = next?.next as? UIViewController {
                return nextResponder
            }
            
            next = next?.superview
        }
        return nil
    }
    
}

// MARK: - UIScreen w h scale
extension UIScreen {
    
    static var ScreenScale: CGFloat {
        return UIScreen.main.scale
    }
    
    static var ScreenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var ScreenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
}
