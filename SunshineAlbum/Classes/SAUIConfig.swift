//
//  SAUIConfig.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/8.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class SAUIConfig {
	
	static let shared = SAUIConfig()
	
	private init() {
	
	}
	
	var tintColor = UIColor(redValue: 26, greenValue: 172, blueValue: 25, alpha: 0.95)
	
	var buttonDisableColor = UIColor(redValue: 22, greenValue: 82, blueValue: 23, alpha: 0.95)
	
	var disableColor = UIColor(redValue: 22, greenValue: 82, blueValue: 23, alpha: 0.95)
	
	var normalTextColor = UIColor.white
	
	var lightGrayTextColor = UIColor(redValue: 165, greenValue: 165, blueValue: 165, alpha: 0.95)
	
	var disableTextColor = UIColor(redValue: 103, greenValue: 107, blueValue: 112, alpha: 0.95)
	
}
