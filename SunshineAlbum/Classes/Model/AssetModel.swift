//
//  AssetModel.swift
//  PhotosDemo
//
//  Created by Garen on 2017/8/24.
//  Copyright © 2017年 CGC. All rights reserved.
//

import Foundation
import Photos

open class AssetModel {
	
	open var asset: PHAsset
	
	open var type: PHAssetMediaType
	
	open var identifier: String
	
	open var isSelected: Bool = false
	
    /// 只有当type为image时有效
    open var isFullImage: Bool = false
    
	/// 只有当type为video时有效
	open var videoDuration: TimeInterval
	
	public init(asset: PHAsset) {
		self.asset = asset
		self.type = asset.mediaType
		self.identifier = asset.localIdentifier
		self.videoDuration = asset.duration
	}
	
}

extension AssetModel: CustomStringConvertible {
	open var description: String {
		return " identifier：\(identifier), type：\(type), videoDuration:\(videoDuration), asset: \(asset) isSelected: \(isSelected)"
	}
}
