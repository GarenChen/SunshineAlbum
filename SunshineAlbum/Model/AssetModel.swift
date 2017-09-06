//
//  AssetModel.swift
//  PhotosDemo
//
//  Created by Garen on 2017/8/24.
//  Copyright © 2017年 CGC. All rights reserved.
//

import Foundation
import Photos

class AssetModel {
	
	var asset: PHAsset
	
	var type: PHAssetMediaType
	
	var identifier: String
	
	var isSelected: Bool = false
	
	/// 只有当type为video时有效
	var videoDuration: TimeInterval
	
	init(asset: PHAsset) {
		self.asset = asset
		self.type = asset.mediaType
		self.identifier = asset.localIdentifier
		self.videoDuration = asset.duration
	}
	
}

extension AssetModel: CustomStringConvertible {
	var description: String {
		return " identifier：\(identifier), type：\(type), videoDuration:\(videoDuration), asset: \(asset) isSelected: \(isSelected)"
	}
}
