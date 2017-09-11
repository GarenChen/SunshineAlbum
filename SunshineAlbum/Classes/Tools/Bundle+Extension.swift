//
//  Bundle+Extension.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
	
	static var currentResourceBundle: Bundle? {
		let path =  Bundle(for: SAAssetsManager.self).path(forResource: "SunshineAlbum", ofType: "bundle") ?? ""
		return Bundle(path: path)
	}
	
}
