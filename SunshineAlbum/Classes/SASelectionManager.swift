//
//  SASelectionManager.swift
//  Pods
//
//  Created by Garen on 2017/9/7.
//
//

import Foundation
import Photos

/// 相册的设置
public class SunshineAlbumSelectionConfig {
	
	/// 最大图片选择数， 默认为 9, 当设置为小于等于 1 时,为选择单个图片
	public var maxSelectedCount: Int = 9

	/// 是否需要裁剪图片， 默认为false, 仅当 isSingleImagePicker 为 true 时有效
	public var canCropImage: Bool = false

	/// 裁剪图片区域高宽比, 仅当 canCropImage 为 true 时有效， 默认为1／1.
	/// 优先级低于 imageCropFrame
	public var imageCropHWRatio: CGFloat = 1
	
	/// 裁剪图片区域frame, 仅当 canCropImage 为 true 时有效.
	/// 设置为非零frame后优先级高于 imageCropHWRatio
	public var	imageCropFrame: CGRect = CGRect.zero
	
	/// 被裁减图片最大放大倍数
	public var limitRatio: CGFloat = 3
	
	/// 是否允许选择视频，默认为false
	public var containsVideo: Bool = false
	
	/// 选择视频所允许的最大时长，仅当 canSelectedVedio 为 true 时有效， 默认为10s， 设置0时 不限制时长
	public var maxSelectedVideoDuration: TimeInterval = 10
	
	/// 超过最大时长的视频是否可截断， 默认为false 表示不可截断不可选， 为true时截断后可选
	public var canEditVideo: Bool = false
	
	public init() {
		
	}
}

public class SASelectionManager {
	
	public static let shared = SASelectionManager()
	
	private init() { }
	
	/// 最大图片选择数， 默认为 9, 当设置为小于等于 1 时,为选择单个图片
	var maxSelectedCount: Int = 9 {
		didSet {
			isSingleImagePicker = (maxSelectedCount <= 1 )
		}
	}
	
	/// 是否为单个图片选择器
	var isSingleImagePicker: Bool = false
	
	/// 是否需要裁剪图片， 默认为false, 仅当 isSingleImagePicker 为 true 时有效
	var canCropImage: Bool = false
	
	/// 裁剪图片区域高宽比, 仅当 canCropImage 为 true 时有效， 默认为1／1.
	public var imageCropHWRatio: CGFloat = 1 {
		didSet {
			imageCropFrame = CGRect(x: 0, y: (UIScreen.ScreenHeight - 72 - UIScreen.ScreenWidth * imageCropHWRatio) / 2, width: UIScreen.ScreenWidth, height: UIScreen.ScreenWidth * imageCropHWRatio)
		}
	}
	
	/// 裁剪图片区域frame, 仅当 canCropImage 为 true 时有效.
	var	imageCropFrame: CGRect = CGRect(x: 0, y: (UIScreen.ScreenHeight - 72 - UIScreen.ScreenWidth) / 2, width: UIScreen.ScreenWidth, height: UIScreen.ScreenWidth)
	
	/// 被裁减图片最大放大倍数
	var limitRatio: CGFloat = 3
	
    /// 是否允许选择视频，默认为false
	var containsVideo: Bool = false
	
    /// 选择视频所允许的最大时长，仅当 canSelectedVedio 为 true 时有效， 默认为10s， 设置0时 不限制时长
    var maxSelectedVideoDuration: TimeInterval = 10
	
	/// 超过最大时长的视频是否可截断， 默认为false 表示不可截断不可选， 为true时截断后可选
	var canEditVideo: Bool = false
	
	var selectedAssets: [AssetModel] = [] {
		didSet {
			debuglog("SASelectionManager.selectedAssets: \(selectedAssets)")
		}
	}
	
	lazy var imagesCaches: NSCache<AssetModel, UIImage> = {
		let imagesCaches = NSCache<AssetModel, UIImage>()
		imagesCaches.countLimit = 64
		imagesCaches.name = "sunshine_album_images_cache"
		return imagesCaches
	}()
	
	
	/// 获取视频缩略图
	///
	/// - Parameter asset: asset
	/// - Returns: UIImage
	public func generateVideoImage(asset: AVURLAsset) -> UIImage? {
		let assetGen = AVAssetImageGenerator(asset: asset)
		assetGen.appliesPreferredTrackTransform = true
		let time = CMTimeMake(1, 60)
		guard let image = try? assetGen.copyCGImage(at: time, actualTime: nil) else { return nil }
		let videoImage = UIImage(cgImage: image, scale: 0.6, orientation: UIImageOrientation.up)
		return videoImage
	}
	
	
	/// 清除缓存
	public func cleanCaches() {
		SASelectionManager.shared.selectedAssets = []
		SASelectionManager.shared.imagesCaches.removeAllObjects()
	}
	
}

