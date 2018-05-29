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
		manager.navigationBarTintColor = config.navigationBarTintColor
		manager.navigationBarStyle = config.navigationBarStyle
		
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
		self.navigationBar.tintColor = SASelectionManager.shared.navigationBarTintColor
		self.navigationBar.barStyle = SASelectionManager.shared.navigationBarStyle
	}
	
	private func checkAuthorization() {
		PHPhotoLibrary.requestAuthorization { (status) in
			DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
				switch status {
				case .authorized:
					self.viewControllers.first?.title = "所有相册"
					if self.showAlbumList {
						guard let listCtr = self.viewControllers.first as? AlbumsListController else {
							return
						}
						listCtr.models = AssetsManager.shared.fetchAllAlbums()
					} else {
						guard let model = AssetsManager.shared.fetchCameraRoll() else {
							return
						}
						let ctr: UIViewController = SASelectionManager.shared.isSingleImagePicker ? AlbumSingleSelectionController(model: model) :  AlbumMutiSelectionController(model: model)
						self.pushViewController(ctr, animated: false)
					}
				default:
                    self.showAlert(title: "请在iphone的\"设置-隐私-照片\"选项中，设置成允许访问您的相册",
                                   actions: ("确定", { _ in
                                    self.dismissController()
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
