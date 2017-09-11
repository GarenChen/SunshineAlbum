//
//  UIView+Extension.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

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

extension UIView {
	
}
