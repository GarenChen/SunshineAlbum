//
//  UIColor+Extension.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIColor to UIImage
extension UIColor {
	
	func toImage() -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
		UIGraphicsBeginImageContext(rect.size)
		defer { UIGraphicsEndImageContext() }
		
		let context = UIGraphicsGetCurrentContext()!
		context.setFillColor(self.cgColor)
		context.fill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		return image
	}
}

extension UIColor {
	
	convenience init(redValue: Int, greenValue: Int, blueValue: Int, alpha: Float = 1.0) {
		self.init(red: CGFloat(redValue)/255.0, green: CGFloat(greenValue)/255.0, blue: CGFloat(blueValue)/255.0, alpha: CGFloat(alpha))
	}
}
