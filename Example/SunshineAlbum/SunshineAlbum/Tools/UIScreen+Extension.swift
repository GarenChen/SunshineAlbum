//
//  UIScreen+Extension.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIScreen w h scale
extension UIScreen {
	
	static var ScreenScale: CGFloat {
		return UIScreen.main.scale
	}
	
	static var ScreenSize: CGSize {
		return UIScreen.main.bounds.size
	}
	
	static var ScreenWidth: CGFloat {
		return UIScreen.main.bounds.size.width
	}
	
	static var ScreenHeight: CGFloat {
		return UIScreen.main.bounds.size.height
	}
	
}
