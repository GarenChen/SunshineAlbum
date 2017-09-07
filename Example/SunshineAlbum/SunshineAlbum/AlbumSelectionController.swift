//
//  AlbumSelectionController.swift
//  PhotosDemo
//
//  Created by Garen on 2017/8/19.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

class AlbumSelectionController: UIViewController {

	var albumModel: AlbumsModel?
	
    var isFirstShow: Bool = true
    
	private lazy var selectionView = AlbumMutiSelecttionView()
    
    private lazy var customBottombar: PreviewBottomBar = { [unowned self] in
        let bar  = PreviewBottomBar(frame: CGRect(x: 0, y: UIScreen.ScreenHeight - 44, width: UIScreen.ScreenWidth, height: 44))
        bar.didClickDoneButton = { [weak self] in
            self?.clickDoneButton()
        }
        return bar
    }()
    
    var maxSelectedCount: Int = 9

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
        guard let photoSelectorCtr = navigationController as? PhotoSelectorController else { return }
        selectionView.selectedModel = photoSelectorCtr.selectedModels
        
        guard let albumModel = albumModel else { return }
        if isFirstShow {
            selectionView.scrollToItem(at: IndexPath(item: albumModel.count - 1, section: 0), at: .bottom, animated: false)
            isFirstShow = false
        }
    }
	
	private func setupViews() {
		
		view.addSubview(selectionView)
        
		selectionView.albumModel = albumModel
		selectionView.maxSelectedCount = 4
		selectionView.didSelectedCell = { [weak self] (indexPath, assetModel) in
            
			guard let `self` = self else { return }
            guard let albumModel = self.albumModel else { return }
            
            if assetModel.type == .image {
                let previewCtr = SAAssetPreviewController(assetModels: albumModel.assetModels, selectedItem: indexPath.item)
//				(albumsModel: albumModel, selectedItem: indexPath.item)
//                previewCtr.maxSelectedCount = self.maxSelectedCount
                self.navigationController?.pushViewController(previewCtr, animated: true)
            } else {
                let previewCtr = PreviewVideoController(assetModel: assetModel)
                previewCtr.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(previewCtr, animated: true)
            }
            
		}
        
        selectionView.selectedModelsDidChange = { [weak self] selectedModels in
            self?.selectedModelsDidChange(selectedModels)
        }
		
		selectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - 44)
        
        view.addSubview(customBottombar)
        refreshCustomBars()
	}

    func selectedModelsDidChange(_ selectedModel: [AssetModel]) {
        
        refreshCustomBars()
        
        guard let photoSelectorCtr = navigationController as? PhotoSelectorController else { return }
        photoSelectorCtr.selectedModels = selectedModel
    }
    
    private func refreshCustomBars() {

        customBottombar.doneButton.isEnabled = !selectionView.selectedModel.isEmpty
        
        let doneButtonTitle = selectionView.selectedModel.isEmpty ? "完成" : "完成(\(selectionView.selectedModel.count))"
        customBottombar.doneButton.setTitle(doneButtonTitle, for: .normal)
    }
    
    func clickDoneButton() {
        guard let photoSelectorCtr = navigationController as? PhotoSelectorController else { return }
        photoSelectorCtr.didFinishSelectedPhotos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

}
