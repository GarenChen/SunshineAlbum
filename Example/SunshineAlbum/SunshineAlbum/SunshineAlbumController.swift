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

public enum SelectedType {
	case photo(Array<UIImage>)
	case video(URL)
}

public class SunshineAlbumController: UINavigationController {

	public var complitionHandler: ((SelectedType) -> Void)?
	
	public var showAlbumList: Bool = true
	
	/// 初始化方法
	/// - Parameters:
	///   - showAlbumList: Whether to show all albums,if false, show the Camera Roll
	///   - containVideo: Whether album contain video
	///   - complition: complition handler
	public convenience init(showAlbumList: Bool, containVideo: Bool, complition: @escaping (SelectedType) -> Void) {
		SAAssetsManager.shared.showVideo = containVideo
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
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if !showAlbumList {
			guard let model = SAAssetsManager.shared.fetchCameraRoll() else {
				return
			}
			let ctr = AlbumSelectionController(model: model)
			self.pushViewController(ctr, animated: false)
		}
	}
	
	private func setupView() {
		self.navigationBar.tintColor = .white
		self.navigationBar.barStyle = .blackTranslucent
	}
	
	internal func dismissController() {
		self.dismiss(animated: true, completion: nil)
	}
	
	public override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	internal func didFinishSelected() {
		
		dismissController()
		
		debuglog("\(SASelectionManager.shared.selectedAssets.description)")
		
		if let assetModel = SASelectionManager.shared.selectedAssets.first, assetModel.type == .video {
			SAAssetsManager.shared.imageManager.requestAVAsset(forVideo: assetModel.asset, options: nil) { [weak self] (avAsset, audioMix, info) in
				DispatchQueue.main.async { [weak self] in
					guard let asset = avAsset as? AVURLAsset else { return }
					self?.complitionHandler?(.video(asset.url))
				}
			}
			return
		}
		
		var images: [UIImage] = []
		SASelectionManager.shared.selectedAssets.forEach { (model) in
			
			if let image = SASelectionManager.shared.imagesCaches.object(forKey: model),!model.isFullImage {
				images.append(image)
			} else {
				SAAssetsManager.shared.fetchResultImage(asset: model.asset, isHightQuality: true, isFullImage: model.isFullImage, complition: { (image) in
					images.append(image)
				})
			}	
		}
		SASelectionManager.shared.selectedAssets = []
		SASelectionManager.shared.imagesCaches.removeAllObjects()
		complitionHandler?(.photo(images))
	}

}
