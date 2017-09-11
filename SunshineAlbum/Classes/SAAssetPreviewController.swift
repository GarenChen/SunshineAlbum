//
//  SAAssetPreviewController.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class SAAssetPreviewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

	var assetModels: [AssetModel] = []
	
	var currentItemIndex: Int = 0
    
    private var isBarsHidden: Bool = false {
        didSet {
            navigationController?.setNavigationBarHidden(isBarsHidden, animated: false)
			customBottomBar.isHidden = isBarsHidden
        }
    }
    
    private lazy var rightButton: SASelectionButton = { [unowned self] in
        let rightButton = SASelectionButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        rightButton.didClick = {[weak self] sender in
            self?.didClickedRightItem(sender)
        }
        return rightButton
    }()
    
    private lazy var customBottomBar: PreviewBottomBar = { [unowned self] in
        let bar  = PreviewBottomBar(frame: CGRect(x: 0, y: UIScreen.ScreenHeight - UIScreen.bottomBarHeight, width: UIScreen.ScreenWidth, height: UIScreen.bottomBarHeight))
        
        bar.didClickedFirst = { [weak self, weak bar] sender in
            sender.isSelected = !sender.isSelected
            bar?.decButton.isSelected = sender.isSelected
            self?.pickUpImage(isFullImage: sender.isSelected)
        }
        
        bar.didClickedSecond = { [weak self] _ in
            self?.finishSelected()
        }
		
        return bar
    }()
	
	private lazy var collectionView: UICollectionView = { [unowned self] in
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		layout.itemSize = CGSize(width: UIScreen.ScreenWidth + 20, height: UIScreen.ScreenHeight)
		
		let coll = UICollectionView(frame: CGRect(x: -10, y: 0, width: UIScreen.ScreenWidth + 20, height: UIScreen.ScreenHeight), collectionViewLayout: layout)
		coll.isPagingEnabled = true
		coll.showsHorizontalScrollIndicator = false
		coll.scrollsToTop = false
		coll.dataSource = self
		coll.delegate = self
		coll.register(UINib(nibName: PhotoPreviewCell.reusedId, bundle: Bundle.currentResourceBundle), forCellWithReuseIdentifier: PhotoPreviewCell.reusedId)
        coll.register(UINib(nibName: VideoPreviewCell.reusedId, bundle: Bundle.currentResourceBundle), forCellWithReuseIdentifier: VideoPreviewCell.reusedId)
		return coll
	}()
	
	convenience init(assetModels: [AssetModel], selectedItem: Int) {
		self.init()
		self.assetModels = assetModels
		self.currentItemIndex = selectedItem
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupViews() {
        
        title = " "
        
        collectionView.dataSource = self
        collectionView.delegate = self
		
		automaticallyAdjustsScrollViewInsets = false
		
		view.addSubview(collectionView)
		view.addSubview(customBottomBar)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
		
		refreshBars()
		refreshFullImageButton()
		
		collectionView.scrollToItem(at: IndexPath(item: currentItemIndex, section: 0), at: .left, animated: false)
		collectionView.backgroundColor = .black
    }
	
    @objc private func didClickedRightItem(_ sender: UIButton) {
		
		guard currentItemIndex < self.assetModels.count else { return }
		let assetModel = self.assetModels[currentItemIndex]
		
		let isSelected = !sender.isSelected
		
		if isSelected && (SASelectionManager.shared.selectedAssets.count >= SASelectionManager.shared.maxSelectedCount) {
			showAlert(title: "最多只能选择\(SASelectionManager.shared.maxSelectedCount)张照片",actions: ("确定", nil))
			return
		}
		
		sender.isSelected = isSelected
		
		assetModel.isSelected = isSelected
		
		let index = SASelectionManager.shared.selectedAssets.index { (model) -> Bool in
			return assetModel.identifier == model.identifier
		}
		
		if isSelected && (index == nil) {
			SASelectionManager.shared.selectedAssets.append(assetModel)
		} else if !isSelected && (index != nil) {
			SASelectionManager.shared.selectedAssets.remove(at: index!)
		}
		
		refreshBars()
    }
    
    private func pickUpImage(isFullImage: Bool) {
        guard currentItemIndex < self.assetModels.count else { return }
        let assetModel = self.assetModels[currentItemIndex]
        assetModel.isFullImage = isFullImage
		refreshFullImageButton()
    }
	
	private func refreshFullImageButton() {
		
		guard currentItemIndex < self.assetModels.count else { return }
		let assetModel = self.assetModels[currentItemIndex]
		if assetModel.isFullImage {
			SAAssetsManager.shared.caculateOriginalDataLength(asset: assetModel.asset, complition: {[weak self] (data, lengthDec) in
				self?.customBottomBar.firstButton.setTitle("原图\(lengthDec)", for: .selected)
			})
		} else {
			customBottomBar.firstButton.setTitle("原图", for: .normal)
		}
	}
	
	private func refreshBars() {
        
		guard currentItemIndex < self.assetModels.count else { return }
		let assetModel = self.assetModels[currentItemIndex]
        
        if assetModel.type == .video {
            rightButton.isHidden = true
            customBottomBar.showType = .video
            let isVideoTooLong = Int(assetModel.videoDuration) > Int(SASelectionManager.shared.maxSelectedVideoDuration)
            
            print("\(assetModel.videoDuration)")
            print("\(SASelectionManager.shared.maxSelectedVideoDuration)")
            
            customBottomBar.secondButton.isEnabled = true
            customBottomBar.decLabel.text = isVideoTooLong ? "只能选择不超过10秒的视频文件！" : nil
            customBottomBar.secondButton.setTitle(isVideoTooLong ? "编辑" : "完成", for: .normal)
            
            if !SASelectionManager.shared.selectedAssets.isEmpty {
                customBottomBar.decLabel.text = "不能同时选择图片和视频文件！"
                customBottomBar.secondButton.isEnabled = false
            }
            
        } else {
            
            let index = SASelectionManager.shared.selectedAssets.index { (model) -> Bool in
                return assetModel.identifier == model.identifier
            }
            rightButton.index = (index == nil) ? 0 : index! + 1
            rightButton.isSelected = assetModel.isSelected
            rightButton.isHidden = false
            
            customBottomBar.showType = .photo
            let doneButtonTitle = SASelectionManager.shared.selectedAssets.isEmpty ? "完成" : "完成(\(SASelectionManager.shared.selectedAssets.count))"
            customBottomBar.secondButton.setTitle(doneButtonTitle, for: .normal)
        }
		
	}
	
    private func finishSelected() {
        
		guard currentItemIndex < self.assetModels.count else { return }
		let assetModel = self.assetModels[currentItemIndex]
        
        // 视频
        if assetModel.type == .video {
            
            // 视频需要截取
            if Int(assetModel.videoDuration) > Int(SASelectionManager.shared.maxSelectedVideoDuration) {
                let cropCtr = VideoCropController(assetModel: assetModel)
                navigationController?.pushViewController(cropCtr, animated: false)
                return
            }
            
            // 视频不需要截取
            SAAssetsManager.shared.imageManager.requestAVAsset(forVideo: assetModel.asset, options: nil) { [weak self] (avAsset, audioMix, info) in
                DispatchQueue.main.async { [weak self] in
                    guard let asset = avAsset as? AVURLAsset else { return }
                    (self?.navigationController as? SunshineAlbumController)?.didFinishSelectedVideo(url: asset.url)
                }
            }
            return
        }
        
        // 图片
		if SASelectionManager.shared.selectedAssets.isEmpty {
			SASelectionManager.shared.selectedAssets.append(assetModel)
		}
		(navigationController as? SunshineAlbumController)?.didFinishSelected()
    }
	
	// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return assetModels.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let model = assetModels[indexPath.item]
        
        if model.type == .video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoPreviewCell.reusedId, for: indexPath) as! VideoPreviewCell
            cell.assetModel = model
            cell.tapConentToHideBar = { [weak self] isHidden in
                guard let `self` = self else { return }
                self.isBarsHidden = isHidden
                self.refreshBars()
            }
            return cell
        }
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPreviewCell.reusedId, for: indexPath) as! PhotoPreviewCell
		cell.model = model
		cell.tapConentToHideBar = { [weak self] isHidden in
			guard let `self` = self else { return }
			self.isBarsHidden = isHidden
			self.refreshBars()
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        for cell in collectionView.visibleCells {
            (cell as? PreviewContentType)?.recoverSubview()
        }

	}
    
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offsetWidth = scrollView.contentOffset.x + (UIScreen.ScreenWidth + 20) * 0.5
		let currentItem = Int(offsetWidth / (UIScreen.ScreenWidth + 20))
		if currentItemIndex != currentItem {
			currentItemIndex = currentItem
			refreshBars()
		}
	}
	
}
