//
//  SAUIConfig.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/8.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public class SAUIConfig {
	
	public static let shared = SAUIConfig()
	
	private init() {
	
	}
	
	public var tintColor = UIColor(redValue: 26, greenValue: 172, blueValue: 25, alpha: 0.95)
	
	public var buttonDisableColor = UIColor(redValue: 22, greenValue: 82, blueValue: 23, alpha: 0.95)
	
	public var disableColor = UIColor(redValue: 22, greenValue: 82, blueValue: 23, alpha: 0.95)
	
	public var normalTextColor = UIColor.white
	
	public var lightGrayTextColor = UIColor(redValue: 165, greenValue: 165, blueValue: 165, alpha: 0.95)
	
	public var disableTextColor = UIColor(redValue: 103, greenValue: 107, blueValue: 112, alpha: 0.95)
}

struct SAAlbumThumbnailSize {
	static let width: CGFloat = 100
	static let height: CGFloat = 100
}
