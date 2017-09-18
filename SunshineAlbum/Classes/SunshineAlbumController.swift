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
	///   - showAlbumList: 进入时是否显示列表，默认为true，为false时显示「相机胶卷」
	///   - maxSelectedCount: 最大图片选择数， 默认为 9, 当设置为小于等于 1 时,为选择单个图片
	///   - containsVideo: 是否允许选择视频文件
	///   - complition: <#complition description#>
	public convenience init(showAlbumList: Bool = true,
	                        maxSelectedCount: Int = 9,
	                        containsVideo: Bool = true,
	                        complition: @escaping (SelectedType) -> Void) {
		SASelectionManager.shared.maxSelectedCount = maxSelectedCount
		SASelectionManager.shared.containsVideo = containsVideo
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
	
	public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		SASelectionManager.shared.cleanCaches()
		super.dismiss(animated: flag, completion: completion)
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
	
	internal func dismissController() {
		self.dismiss(animated: true, completion: nil)
	}
	
	public override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    internal func didFinishSelectedVideo(asset: AVURLAsset) {
        dismissController()
        complitionHandler?(.video(asset))
    }
	
	internal func didFinishSelectedImage() {
		
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
		
		complitionHandler?(.photo(images))
		
	}

}
