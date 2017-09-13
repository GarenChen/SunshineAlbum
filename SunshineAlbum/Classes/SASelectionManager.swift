//
//  SASelectionManager.swift
//  Pods
//
//  Created by Garen on 2017/9/7.
//
//

import Foundation
import Photos

public class SASelectionManager {
	
	public static let shared = SASelectionManager()
	
	private init() {
		
	}
	
	public var maxSelectedCount: Int = 9
    
    public var maxSelectedVideoDuration: TimeInterval = 10
	
	/// 选中图片
	lazy var selectedAssets: [AssetModel] = []
	
	/// 大图缓存
	lazy var imagesCaches: NSCache<AssetModel, UIImage> = {
		let imagesCaches = NSCache<AssetModel, UIImage>()
		imagesCaches.countLimit = 64
		imagesCaches.name = "sunshine_album_images_cache"
		return imagesCaches
	}()
	
	public func generateVideoImage(asset: AVURLAsset) -> UIImage? {
		let assetGen = AVAssetImageGenerator(asset: asset)
		assetGen.appliesPreferredTrackTransform = true
		let time = CMTimeMake(1, 60)
		guard let image = try? assetGen.copyCGImage(at: time, actualTime: nil) else { return nil }
		let videoImage = UIImage(cgImage: image, scale: 0.6, orientation: UIImageOrientation.up)
		return videoImage
	}
	
	
}

