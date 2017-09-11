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
	
    private var isFirstShow: Bool = true
    
	private lazy var selectionView = AlbumMutiSelecttionView()
    
    private lazy var customBottombar: PreviewBottomBar = { [unowned self] in
        let bar  = PreviewBottomBar(frame: CGRect(x: 0, y: UIScreen.ScreenHeight - UIScreen.bottomBarHeight, width: UIScreen.ScreenWidth, height: UIScreen.bottomBarHeight))
		bar.firstButton.setTitle("预览", for: .normal)
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

        selectionView.selectedModel = SASelectionManager.shared.selectedAssets
        
        guard let albumModel = albumModel else { return }
        if isFirstShow {
            selectionView.scrollToItem(at: IndexPath(item: albumModel.count - 1, section: 0), at: .bottom, animated: false)
            isFirstShow = false
        }
    }
	
	private func setupViews() {
		
		view.addSubview(selectionView)
        
		selectionView.albumModel = albumModel
		selectionView.maxSelectedCount = SASelectionManager.shared.maxSelectedCount
		selectionView.didSelectedCell = { [weak self] (indexPath, assetModel) in
            
			guard let `self` = self else { return }
            guard let albumModel = self.albumModel else { return }
			
			let previewCtr = SAAssetPreviewController(assetModels: albumModel.assetModels, selectedItem: indexPath.item)
			self.navigationController?.pushViewController(previewCtr, animated: true)
		}
        
        selectionView.selectedModelsDidChange = { [weak self] selectedModels in
            self?.selectedModelsDidChange(selectedModels)
        }
		
		selectionView.frame = CGRect(x: 0, y: UIScreen.topLayoutHeight, width: UIScreen.ScreenWidth, height: UIScreen.ScreenHeight - UIScreen.topLayoutHeight - UIScreen.bottomBarHeight)
        
        view.addSubview(customBottombar)
        refreshCustomBars()
	}

    private func selectedModelsDidChange(_ selectedModel: [AssetModel]) {
        
        refreshCustomBars()
        
        SASelectionManager.shared.selectedAssets = selectedModel
    }
    
    private func refreshCustomBars() {
        
        customBottombar.decButton.isHidden = true
		
		customBottombar.firstButton.isEnabled = !selectionView.selectedModel.isEmpty
        customBottombar.secondButton.isEnabled = !selectionView.selectedModel.isEmpty
        
        let doneButtonTitle = selectionView.selectedModel.isEmpty ? "完成" : "完成(\(selectionView.selectedModel.count))"
        customBottombar.secondButton.setTitle(doneButtonTitle, for: .normal)
    }
    
	private func finishSelected() {
        (navigationController as? SunshineAlbumController)?.didFinishSelected()
    }
	
	private func clickToPreview() {
		let previewCtr = SAAssetPreviewController(assetModels: SASelectionManager.shared.selectedAssets, selectedItem: 0)
		self.navigationController?.pushViewController(previewCtr, animated: true)
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

}
