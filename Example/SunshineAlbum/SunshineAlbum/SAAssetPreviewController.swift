//
//  SAAssetPreviewController.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class SAAssetPreviewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	var assetModels: [AssetModel] = []
	
	var currentItemIndex: Int = 0
    
    private var hideBars: Bool = false {
        didSet {
            navigationController?.setNavigationBarHidden(hideBars, animated: false)
			customBottomBar.isHidden = hideBars
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
        
        bar.didClickedFirst = { [weak self] sender in
            sender.isSelected = !sender.isSelected
            self?.pickUpImage(isFullImage: sender.isSelected)
        }
        
        bar.didClickedSecond = { [weak self] _ in
            self?.finishSelected()
        }
		
        return bar
    }()
	
	convenience init(assetModels: [AssetModel], selectedItem: Int) {
		self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: NSNumber(integerLiteral: 10)])
		self.assetModels = assetModels
		self.currentItemIndex = selectedItem
	}
	
	override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
		super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
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
        
        dataSource = self
        delegate = self
		
		automaticallyAdjustsScrollViewInsets = false
		
        let firstCtr = controllerAtIndex(currentItemIndex) as? UIViewController
        
        let controllers = (firstCtr != nil) ? [firstCtr!] : Array<UIViewController>()
        
        setViewControllers(controllers, direction: .forward, animated: false, completion: nil)
		
		view.addSubview(customBottomBar)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
		
		refreshBars()
		refreshFullImageButton()
    }

	private func controllerAtIndex(_ index: Int) -> PreviewContentControllerType? {

		guard index > 0 && index < self.assetModels.count else { return nil }
		
		let assetModel = self.assetModels[index]
		
		switch assetModel.type {
		case .image:
			let photoCtr = PreviewPhotoController(assetModel: assetModel)
			photoCtr.tapConent = { [weak self] in
				guard let `self`  = self else {
					return
				}
				self.hideBars = !self.hideBars
			}
			return photoCtr
		default:
			let videoCtr = PreviewVideoController(assetModel: assetModel)
			return videoCtr
		}
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
		
		let index = SASelectionManager.shared.selectedAssets.index { (model) -> Bool in
			return assetModel.identifier == model.identifier
		}
		rightButton.index = (index == nil) ? 0 : index! + 1
		rightButton.isSelected = assetModel.isSelected
		
		let doneButtonTitle = SASelectionManager.shared.selectedAssets.isEmpty ? "完成" : "完成(\(SASelectionManager.shared.selectedAssets.count))"
		customBottomBar.secondButton.setTitle(doneButtonTitle, for: .normal)
	}
	
    private func finishSelected() {
		guard currentItemIndex < self.assetModels.count else { return }
		let assetModel = self.assetModels[currentItemIndex]
		if SASelectionManager.shared.selectedAssets.isEmpty {
			SASelectionManager.shared.selectedAssets.append(assetModel)
		}
		(navigationController as? SunshineAlbumController)?.didFinishSelected()
    }
    
    
	// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		guard currentItemIndex > 0 else {
			return nil
		}
		currentItemIndex -= 1
		
		let previousCtr = controllerAtIndex(currentItemIndex)
        previousCtr?.recoverSubview()
		return previousCtr as? UIViewController
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		guard currentItemIndex < assetModels.count - 1 else {
			return nil
		}
		currentItemIndex += 1
		
        let nextPhotoCtr = controllerAtIndex(currentItemIndex + 1)
        nextPhotoCtr?.recoverSubview()
        return nextPhotoCtr as? UIViewController
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			refreshBars()
			refreshFullImageButton()
		}
	}
	
//	func presentationCount(for pageViewController: UIPageViewController) -> Int {
//		return 10
//	}
//	
//	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//		return 1
//	}
	
	
}
