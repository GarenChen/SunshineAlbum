//
//  AlbumsModel.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/12.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit
import Photos

class AlbumsModel {

    var albumName: String
	
    var count: Int

	var assetResult: PHFetchResult<PHAsset>
	
	lazy var assetModels: Array<AssetModel> = { [unowned self] in
		
		var models: Array<AssetModel> = []
		self.assetResult.enumerateObjects( { (asset, index, _) in
			let assetModel = AssetModel(asset: asset)
			models.append(assetModel)
		})
		return models
	}()

	init(assetResult: PHFetchResult<PHAsset>, name: String?) {
		self.assetResult = assetResult
		self.albumName = name ?? ""
		self.count = assetResult.count
		
		
	}
	
}

extension AlbumsModel: CustomStringConvertible {
	var description: String {
		return " 相册名称：\(albumName), 照片数：\(count), assetResult: \(assetResult) "
	}
}
