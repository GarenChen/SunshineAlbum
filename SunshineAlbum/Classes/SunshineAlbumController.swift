//
//  SunshineAlbumController.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/8.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

public enum SelectedType {
	case photo(Array<UIImage>)
	case video(AVURLAsset)
}

public class SunshineAlbumController: UINavigationController {

	public var complitionHandler: ((SelectedType) -> Void)?
	
	public var showAlbumList: Bool = true
	
	/// 便利初始化方法
	///
	/// - Parameters:
	///   - showAlbumList: 进入时是否显示相册列表，默认为false，为false时显示「相机胶卷」
	///   - config: 相册相关配置 SunshineAlbumSelectionConfig
	///   - complition: 回调
	public convenience init(showAlbumList: Bool = false,
	                        config: SunshineAlbumSelectionConfig = SunshineAlbumSelectionConfig(),
	                        complition: @escaping (SelectedType) -> Void) {
		
		let manager = SASelectionManager.shared
		
		manager.maxSelectedCount = config.maxSelectedCount
		manager.canCropImage = config.canCropImage
		manager.imageCropHWRatio = config.imageCropHWRatio
		if config.imageCropFrame != .zero {
			manager.imageCropFrame = config.imageCropFrame
		}
		manager.limitRatio = config.limitRatio
		manager.containType = config.containType
		manager.maxSelectedVideoDuration = config.maxSelectedVideoDuration
		manager.canEditVideo = config.canEditVideo
		
		let albumsList = AlbumsListController(models: [])
		self.init(rootViewController: albumsList)
		self.showAlbumList = showAlbumList
		self.complitionHandler = complition
	}
	
	override init(rootViewController: UIViewController) {
		super.init(rootViewController: rootViewController)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		checkAuthorization()
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	private func setupView() {
		self.navigationBar.tintColor = .white
		self.navigationBar.barStyle = .blackTranslucent
	}
	
	private func checkAuthorization() {
		PHPhotoLibrary.requestAuthorization { (status) in
			DispatchQueue.main.async {
				switch status {
				case .authorized:
					self.viewControllers.first?.title = "所有相册"
					if !self.showAlbumList {
						guard let model = AssetsManager.shared.fetchCameraRoll() else {
							return
						}
						let ctr: UIViewController = SASelectionManager.shared.isSingleImagePicker ? AlbumSingleSelectionController(model: model) :  AlbumMutiSelectionController(model: model)
						self.pushViewController(ctr, animated: false)
					}
					
				default:
					self.showAlert(title: "尚未获取照片的使用权限，请在设置中开启「照片」",
					               actions: ("取消", nil), ("前往设置", { _ in
									if let url = URL(string: UIApplicationOpenSettingsURLString),  UIApplication.shared.canOpenURL(url) {
										UIApplication.shared.openURL(url)
									}
								}))
				}
			}
		}
	}
	
	func dismissController() {
		self.dismiss(animated: true, completion: nil)
	}
	
	public override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func didFinishCroppedImage(image: UIImage) {
		dismissController()
		SASelectionManager.shared.cleanCaches()
		complitionHandler?(.photo([image]))
	}
	
    func didFinishSelectedVideo(asset: AVURLAsset) {
        dismissController()
		SASelectionManager.shared.cleanCaches()
        complitionHandler?(.video(asset))
    }
	
	func didFinishSelectedImage() {
		
		debuglog("\(SASelectionManager.shared.selectedAssets.description)")

		var images: [UIImage] = []
		SASelectionManager.shared.selectedAssets.forEach { (model) in
			
			if let image = SASelectionManager.shared.imagesCaches.object(forKey: model),!model.isFullImage {
				images.append(image)
				debuglog("image: \(image)")
			} else {
				AssetsManager.shared.fetchResultImage(asset: model.asset, isFullImage: model.isFullImage, complition: { (image) in
					images.append(image)
					debuglog("image: \(image)")
				})
			}	
		}

		dismissController()
		SASelectionManager.shared.cleanCaches()
		complitionHandler?(.photo(images))
		
	}

}
