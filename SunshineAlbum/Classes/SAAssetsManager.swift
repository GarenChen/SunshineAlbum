//
//  SAAssetsManager.swift
//  Pods
//
//  Created by Garen on 2017/9/7.
//
//

import Foundation
import Photos

class SAAssetsManager: NSObject {
	
	static let shared = SAAssetsManager()
	
    static let videoCacheName = "SunshineVideo.mp4"
    
	var showVideo: Bool = false
	
	var photoFetchOptions: PHFetchOptions {
		let options = PHFetchOptions()
		if !showVideo {
			options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
		}
		options.sortDescriptors = Array(arrayLiteral: NSSortDescriptor(key: "creationDate", ascending: true))
		return options
	}
	
	let imageManager: PHImageManager = {
		return PHImageManager.default()
	}()
	
	private override init() {
		super.init()
	}
	
	/// 获取所有相册
	///
	/// - Returns: 本地所有相册
	func fetchAllAlbums() -> [AlbumsModel] {
		
		//系统智能相册
		let smartResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: .any, options: nil)
		let smarts = handleCollectionFetchResult(smartResult)
		
		//用户相册
		let userResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumUserLibrary, options: nil)
		let users = handleCollectionFetchResult(userResult)
		
		return (smarts + users)
	}
	
	/// 获取相机胶卷
	///
	/// - Returns: 相机胶卷的模型 AlbumsModel
	func fetchCameraRoll() -> AlbumsModel? {
		
		let cameraRollResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
		
		let cameraRolls = handleCollectionFetchResult(cameraRollResult)
		
		debuglog(cameraRolls.description)
		
		return cameraRolls.first
	}
	
	/// 获取输出照片
	///
	/// - Parameters:
	///   - asset: PHAsset
	///   - isHightQuality: 是否是高清图
	///   - complition: 回调
    func fetchResultImage(asset: PHAsset, isHightQuality: Bool = true, isFullImage: Bool = false, complition: @escaping (UIImage) -> Void) {
		
        var size: CGSize = .zero
        
        if !isFullImage {
            let scale = isHightQuality ? UIScreen.ScreenScale : 1.0
            let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            let pixelWidth = UIScreen.ScreenWidth * scale
            let pixelHeight = UIScreen.ScreenWidth / aspectRatio
            size = CGSize(width: pixelWidth, height: pixelHeight)
        }

		let options = PHImageRequestOptions()
		options.resizeMode = .exact
		options.isNetworkAccessAllowed = false
		options.deliveryMode = isHightQuality ? .highQualityFormat : .fastFormat
		options.isSynchronous = true
		
		fetchImage(asset: asset, targetSize: size, options: options, success: complition)
	}
    
    /// 获取照片原图
    ///
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - complition: 回调
    func fetchPreviewImage(asset: PHAsset, complition: @escaping (UIImage) -> Void) {
        let size = CGSize.zero
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = false
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        fetchImage(asset: asset, targetSize: size, options: options, success: complition)
    }
	
	/// 获取照片预览图
	///
	/// - Parameters:
	///   - asset: PHAsset
	///   - isHightQuality: 是否是高清图
	///   - complition: 回调
	func fetchPreviewImage(asset: PHAsset, isHightQuality: Bool, complition: @escaping (UIImage) -> Void) {
		
		let scale = isHightQuality ? UIScreen.ScreenScale : 1.0
		let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
		let pixelWidth = UIScreen.ScreenWidth * scale
		let pixelHeight = UIScreen.ScreenWidth / aspectRatio
		
		let size = CGSize(width: pixelWidth, height: pixelHeight)
		
		let options = PHImageRequestOptions()
		options.resizeMode = .fast
		options.isNetworkAccessAllowed = false
		options.deliveryMode = isHightQuality ? .highQualityFormat : .fastFormat
		options.isSynchronous = false
		
		fetchImage(asset: asset, targetSize: size, options: options, success: complition)
	}
	
	/// 获取资源缩略图
	///
	/// - Parameters:
	///   - asset: asset
	///   - width: 宽
	///   - height: 高
	///   - complition: 获取成功后回调，获取失败时不调用
	func fetchThumbnailImage(asset: PHAsset, width: CGFloat, height: CGFloat, complition: @escaping (UIImage) -> Void) {
		
		let size = CGSize(width: width, height: height)
		
		let options = PHImageRequestOptions()
		options.resizeMode = .fast
		options.isNetworkAccessAllowed = false
		options.deliveryMode = .fastFormat
		
		fetchImage(asset: asset, targetSize: size, options: options, success: complition)
	}
	
	/// 获取特定尺寸图片
	func fetchImage(asset: PHAsset, targetSize: CGSize, options: PHImageRequestOptions, success: @escaping (UIImage) -> Void, failure: ((Error?) -> Void)? = nil) {
		
		imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
			
			guard let resultImage = image else {
				failure?(info?[PHImageErrorKey] as? Error)
				return
			}
			success(resultImage)
		}
		
	}
    
    /// 获取照片原数据
    ///
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - complition: 回调
    func caculateOriginalDataLength(asset: PHAsset, complition: @escaping (Data, String) -> Void) {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = false
        imageManager.requestImageData(for: asset, options: options) { (data, string, orientation, info) in
            debuglog("data: \(String(describing: data)), string: \(String(describing: string)), orientation:\(orientation), info: \(String(describing: info))")
            guard let data = data else { return }
            let length = (data.count ?? 0) / (1024 * 1024)
            let lenghtStr = String(format: "%.2fM", length)
            complition(data, lenghtStr)
        }
    }
    
    /// 获取视频资源
	func fetchAVPlayerItem(asset: PHAsset, success:@escaping (AVPlayerItem) -> Void, failure: (([AnyHashable: Any]?) -> Void)? = nil) {
		let options = PHVideoRequestOptions()
		options.isNetworkAccessAllowed = false
		options.version = .original
		self.imageManager.requestPlayerItem(forVideo: asset, options: options) { (item, info) in
			if item != nil {
				success(item!)
			} else {
				failure?(info)
			}
		}
	}
	
	/// 构建相册model
	///
	/// - Parameter result: 资源集合 PHFetchResult<PHAssetCollection>
	/// - Returns: 相册模型 Array<AlbumsModel>
	private func handleCollectionFetchResult(_ result: PHFetchResult<PHAssetCollection>) -> Array<AlbumsModel> {
		
		var models: [AlbumsModel] = []
		
		result.enumerateObjects({ (collection, index, _) in
			
			let assetResult = PHAsset.fetchAssets(in: collection, options: self.photoFetchOptions)
			
			if assetResult.count > 0 {
				let model = AlbumsModel(assetResult: assetResult, name: collection.localizedTitle)
				models.append(model)
			}
		})
		
		return models
	}
	
    func cropVideo(asset: PHAsset, startTime: CMTime, endTime: CMTime, success: ((URL) -> Void)?) {
		
		imageManager.requestAVAsset(forVideo: asset, options: nil) {(avAsset, audioMix, info) in
			
			guard let asset = avAsset as? AVURLAsset else { return }
			
			let range = CMTimeRange(start: startTime, end: endTime)
			
			let mixComposition = AVMutableComposition()
			
			let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
			
			let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
			
            let assetVideoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first!
            
            let assetAudioTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first!
            
			do {
				try compositionVideoTrack.insertTimeRange(range, of: assetVideoTrack, at: kCMTimeZero)
				try compositionAudioTrack.insertTimeRange(range, of: assetAudioTrack, at: kCMTimeZero)
			} catch let e {
				print(e)
			}

            compositionVideoTrack.preferredTransform = assetVideoTrack.preferredTransform
			
			let assetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetPassthrough)
			
			let outPutPath = NSTemporaryDirectory().appending(SAAssetsManager.videoCacheName)
			
			print("outPutPath \(outPutPath)")
            
            let url = URL(fileURLWithPath: outPutPath)
			
			assetExportSession?.outputFileType = AVFileTypeMPEG4
            
            assetExportSession?.outputURL = url
			
			assetExportSession?.shouldOptimizeForNetworkUse = true
			
            if FileManager.default.fileExists(atPath: outPutPath) {
                do {
                    try FileManager.default.removeItem(atPath: outPutPath)
                } catch let e {
                    print(e)
                }
            }
            
			assetExportSession?.exportAsynchronously(completionHandler: { 
				print("assetExportSession export finished")
                success?(url)
                SAAssetsManager.saveToPhotoWithUrl(url: url)
			})
		}
		
	}

    /// 保存视频到相册
    ///
    /// - Parameter url: 视频URL
    static func saveToPhotoWithUrl(url: URL) {
        PHPhotoLibrary.shared().performChanges({ 
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }, completionHandler: nil)
    }
	
}
