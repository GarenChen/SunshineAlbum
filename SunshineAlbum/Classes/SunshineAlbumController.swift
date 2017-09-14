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
	case video(AVURLAsset)
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
	
	public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		SASelectionManager.shared.cleanCaches()
		super.dismiss(animated: flag, completion: completion)
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
    
    internal func didFinishSelectedVideo(asset: AVURLAsset) {
        dismissController()
        complitionHandler?(.video(asset))
    }
	
	internal func didFinishSelected() {
		
		debuglog("\(SASelectionManager.shared.selectedAssets.description)")

		var images: [UIImage] = []
		SASelectionManager.shared.selectedAssets.forEach { (model) in
			
			if let image = SASelectionManager.shared.imagesCaches.object(forKey: model),!model.isFullImage {
				images.append(image)
				debuglog("image: \(image)")
			} else {
				SAAssetsManager.shared.fetchResultImage(asset: model.asset, isFullImage: model.isFullImage, complition: { (image) in
					images.append(image)
					debuglog("image: \(image)")
				})
			}	
		}

		dismissController()
		
		complitionHandler?(.photo(images))
		
	}

}
