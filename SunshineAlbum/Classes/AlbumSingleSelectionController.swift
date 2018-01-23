//
//  AlbumSingleSelectionController.swift
//  Pods
//
//  Created by Garen on 2017/9/18.
//
//

import UIKit

class AlbumSingleSelectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	var albumModel: AlbumsModel? {
		willSet {
			AssetsManager.shared.imageManager.stopCachingImagesForAllAssets()
		}
		
		didSet {
			guard let albumModel = albumModel else { return }
			AssetsManager.shared.imageManager.startCachingImages(for: albumModel.phAssets, targetSize: CGSize(width: SAAlbumThumbnailSize.width, height: SAAlbumThumbnailSize.height), contentMode: .aspectFill, options: AssetsManager.shared.imageFetchOptions)
		}
	}

	private var isFirstShow: Bool = true

	private lazy var collectionView: UICollectionView = { [unowned self] in
		let frame = CGRect(x: 0, y: UIScreen.topLayoutHeight, width: UIScreen.ScreenWidth, height: UIScreen.ScreenHeight - UIScreen.topLayoutHeight)
		
		let collectionView = UICollectionView(frame: frame, collectionViewLayout: AlbumThumbnailCollectionViewLayout())
		collectionView.backgroundColor = .white
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
		collectionView.register(UINib(nibName: ThumbnailPhotoCell.reusedId, bundle: Bundle.currentResourceBundle), forCellWithReuseIdentifier: ThumbnailPhotoCell.reusedId)
		return collectionView
	}()

	convenience init(model: AlbumsModel) {
		self.init()
		self.albumModel = model
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = albumModel?.albumName
		navigationItem.rightBarButtonItem = rightCancleItem
//		if #available(iOS 11, *) {
//			self.collectionView.contentInsetAdjustmentBehavior = .never
//		} else {
//			automaticallyAdjustsScrollViewInsets = false
//		}
		
		view.backgroundColor = .white
		setupViews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if isFirstShow {
			guard let albumModel = albumModel, albumModel.assetModels.count > 0 else {
				return
			}
			collectionView.scrollToItem(at: IndexPath(item: albumModel.assetModels.count - 1, section: 0), at: .bottom, animated: false)
			isFirstShow = false
		}
	}
	
	private func setupViews() {
		
		collectionView.frame = view.bounds
		collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		view.addSubview(collectionView)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - data source
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return albumModel?.assetModels.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		guard let albumModel = albumModel else { return UICollectionViewCell() }
		
		let assetModel = albumModel.assetModels[indexPath.item]
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailPhotoCell.reusedId, for: indexPath) as! ThumbnailPhotoCell

		cell.model = assetModel
		
		cell.showType = .SingleSelection

		return cell
	}
	
	// MARK: - delegate
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailPhotoCell
		cell?.isSelected = false
		
		guard let albumModel = albumModel else { return }
		
		let assetModel = albumModel.assetModels[indexPath.item]
		
		switch assetModel.type {
		case .image:
			if SASelectionManager.shared.canCropImage {
				let cropperController = ImageCropperViewController(assetModel: assetModel)
				cropperController.didCanceled = { [weak cropperController] in
					cropperController?.dismiss(animated: false, completion: nil)
				}
				cropperController.didCropped = { [weak self, weak cropperController] image in
					
					cropperController?.dismiss(animated: false, completion: nil)
					
					if let croppedImage = image {
						(self?.navigationController as? SunshineAlbumController)?.didFinishCroppedImage(image: croppedImage)
					}
					
				}
				present(cropperController, animated: true, completion: nil)
				
			} else {
				SASelectionManager.shared.selectedAssets = [assetModel]
				(navigationController as? SunshineAlbumController)?.didFinishSelectedImage()
			}
			
		case .video:
			guard Int(assetModel.videoDuration) > Int(SASelectionManager.shared.maxSelectedVideoDuration) else {
				AssetsManager.shared.imageManager.requestAVAsset(forVideo: assetModel.asset, options: nil) { [weak self] (avAsset, audioMix, info) in
					DispatchQueue.main.async { [weak self] in
						guard let asset = avAsset as? AVURLAsset else { return }
						(self?.navigationController as? SunshineAlbumController)?.didFinishSelectedVideo(asset: asset)
					}
				}
				return
			}
			guard SASelectionManager.shared.canEditVideo else {
				self.showAlert(title: "只能选择不超过\(Int(SASelectionManager.shared.maxSelectedVideoDuration))秒的视频文件！",actions: ("确定", nil))
				return
			}
			let cropCtr = VideoCropController(assetModel: assetModel)
			navigationController?.pushViewController(cropCtr, animated: false)
			
		default: break
		}
		
	}
	
}
