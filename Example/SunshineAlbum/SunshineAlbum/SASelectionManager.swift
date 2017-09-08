//
//  SASelectionManager.swift
//  Pods
//
//  Created by Garen on 2017/9/7.
//
//

import Foundation
import Photos

class SASelectionManager {
	
	static let shared = SASelectionManager()
	
	private init() {
		
	}
	
	var maxSelectedCount: Int = 9
	
	/// 选中图片
	lazy var selectedAssets: [AssetModel] = []
	
	
	/// 大图缓存
	lazy var imagesCaches: NSCache<AssetModel, UIImage> = {
		let imagesCaches = NSCache<AssetModel, UIImage>()
		imagesCaches.countLimit = 64
		imagesCaches.name = "sunshine_album_images_cache"
		return imagesCaches
	}()
	
}

