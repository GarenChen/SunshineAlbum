//
//  AlbumMutiSelectionController.swift
//  PhotosDemo
//
//  Created by Garen on 2017/8/19.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit
import Photos

public class AlbumThumbnailCollectionViewLayout: UICollectionViewFlowLayout {
	
	var cellPadding: CGFloat = 4
	
	var column: CGFloat = 4
	
	public override init() {
		super.init()
		setupLayout()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func setupLayout() {
		
		minimumInteritemSpacing = 0
		
		let width = (UIScreen.ScreenWidth - cellPadding) / column -  cellPadding
		let height = width
		
		itemSize = CGSize(width: width, height: height)
		minimumLineSpacing = cellPadding
		sectionInset = UIEdgeInsets(top: cellPadding, left: cellPadding, bottom: cellPadding, right: cellPadding)
	}
}

class AlbumMutiSelectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

	var albumModel: AlbumsModel? {
		willSet {
			AssetsManager.shared.imageManager.stopCachingImagesForAllAssets()
		}
		
		didSet {
			guard let albumModel = albumModel else { return }
			AssetsManager.shared.imageManager.startCachingImages(for: albumModel.phAssets, targetSize: CGSize(width: SAAlbumThumbnailSize.width, height: SAAlbumThumbnailSize.height), contentMode: .aspectFill, options: AssetsManager.shared.imageFetchOptions)
		}
	}
	
	var selectedModel: Array<AssetModel> = [] {
		didSet {
			SASelectionManager.shared.selectedAssets = selectedModel
			needMaskUnSelectedItems = selectedModel.count >= SASelectionManager.shared.maxSelectedCount
			refreshVisiableCellDisplayStatus()
			refreshCustomBars()
		}
	}
	
    private var isFirstShow: Bool = true
	
	private var needMaskUnSelectedItems: Bool = false
	
	private lazy var collectionView: UICollectionView = { [unowned self] in
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: AlbumThumbnailCollectionViewLayout())
		collectionView.backgroundColor = .white
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
		collectionView.register(UINib(nibName: ThumbnailPhotoCell.reusedId, bundle: Bundle.currentResourceBundle), forCellWithReuseIdentifier: ThumbnailPhotoCell.reusedId)
		return collectionView
	}()
    
    private lazy var customBottombar: PreviewBottomBar = { [unowned self] in
        let bar  = PreviewBottomBar(frame: CGRect(x: 0, y: UIScreen.ScreenHeight - UIScreen.bottomBarHeight, width: UIScreen.ScreenWidth, height: UIScreen.bottomBarHeight))
		bar.firstButton.setTitle("预览", for: .normal)
		bar.decLabel.isHidden = true
		bar.didClickedFirst = { [weak self] sender in
			self?.clickToPreview()
		}
		bar.didClickedSecond = { [weak self] _ in
			self?.finishSelected()
		}
        return bar
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
		automaticallyAdjustsScrollViewInsets = false
        
		setupViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedModel = SASelectionManager.shared.selectedAssets
		if isFirstShow {
			guard let albumModel = albumModel, albumModel.assetModels.count > 0 else {
				return
			}
			collectionView.scrollToItem(at: IndexPath(item: albumModel.assetModels.count - 1, section: 0), at: .bottom, animated: false)
			isFirstShow = false
		}
    }
	
	private func setupViews() {
		view.addSubview(collectionView)
		collectionView.frame = CGRect(x: 0, y: UIScreen.topLayoutHeight, width: UIScreen.ScreenWidth, height: UIScreen.ScreenHeight - UIScreen.topLayoutHeight - UIScreen.bottomBarHeight)
        view.addSubview(customBottombar)
        refreshCustomBars()
	}

    private func refreshCustomBars() {
		customBottombar.firstButton.isEnabled = !selectedModel.isEmpty
        customBottombar.secondButton.isEnabled = !selectedModel.isEmpty
        
        let doneButtonTitle = selectedModel.isEmpty ? "完成" : "完成(\(selectedModel.count))"
        customBottombar.secondButton.setTitle(doneButtonTitle, for: .normal)
    }
    
	private func finishSelected() {
        (navigationController as? SunshineAlbumController)?.didFinishSelectedImage()
    }
	
	private func clickToPreview() {
		let previewCtr = AssetPreviewController(assetModels: SASelectionManager.shared.selectedAssets, selectedItem: 0)
		self.navigationController?.pushViewController(previewCtr, animated: true)
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func refreshVisiableCellDisplayStatus() {
		
		collectionView.indexPathsForVisibleItems.forEach {[weak self] (indexPath) in
			guard let `self` = self else { return }
			guard let albumModel = self.albumModel else { return }
			guard let cell = self.collectionView.cellForItem(at: indexPath) as? ThumbnailPhotoCell else { return }
			
			let assetModel = albumModel.assetModels[indexPath.item]
			
			let index = self.selectedModel.index { (model) -> Bool in
				return model.identifier == assetModel.identifier
			}
			
			cell.showIndex = (index == nil) ? 0 : index! + 1
			
			if assetModel.type == .image {
				cell.showMask = !assetModel.isSelected && self.needMaskUnSelectedItems
			} else {
				cell.showMask = !self.selectedModel.isEmpty
			}
			
		}
		
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
		
		let index = selectedModel.index { (model) -> Bool in
			return model.identifier == assetModel.identifier
		}
		cell.showIndex = (index == nil) ? 0 : index! + 1
		
		if assetModel.type == .image {
			cell.showMask = !assetModel.isSelected && needMaskUnSelectedItems
		} else {
			cell.showMask = !selectedModel.isEmpty
		}
		
		cell.didClickSelectedButton = { [weak self, weak cell] (isSelected, model) in
			
			guard let `self` = self else { return }
			
			if isSelected && (self.selectedModel.count >= SASelectionManager.shared.maxSelectedCount) {
				isSelected = false
				self.showAlert(title: "最多只能选择\(SASelectionManager.shared.maxSelectedCount)张照片",actions: ("确定", nil))
				return
			}
			
			model.isSelected = isSelected
			
			let index = self.selectedModel.index(where: { (selected) -> Bool in
				return selected.identifier == model.identifier
			})
			cell?.showIndex = (index == nil) ? 0 : index! + 1
			
			if isSelected && (index == nil) {
				self.selectedModel.append(model)
			} else if !isSelected && (index != nil) {
				self.selectedModel.remove(at: index!)
			}
		}
		return cell
	}
	
	// MARK: - delegate
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailPhotoCell
		cell?.isSelected = false
		
		guard let albumModel = albumModel else { return }
		
		let assetModel = albumModel.assetModels[indexPath.item]
		
		if assetModel.type == .video && Int(assetModel.videoDuration) > Int(SASelectionManager.shared.maxSelectedVideoDuration) && !SASelectionManager.shared.canEditVideo {
			showAlert(title: "只能选择不超过\(Int(SASelectionManager.shared.maxSelectedVideoDuration))秒的视频文件！",actions: ("确定", nil))
			return
		}
		
		if (selectedModel.count >= SASelectionManager.shared.maxSelectedCount) && !assetModel.isSelected {
			showAlert(title: "最多只能选择\(SASelectionManager.shared.maxSelectedCount)张照片",actions: ("确定", nil))
			return
		}
		
		if !selectedModel.isEmpty && (assetModel.type !=  .image) {
			return
		}
		
		let previewController = AssetPreviewController(assetModels: albumModel.assetModels, selectedItem: indexPath.item)
		navigationController?.pushViewController(previewController, animated: true)
	}

}
