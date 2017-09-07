//
//  DebugLog.swift
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




