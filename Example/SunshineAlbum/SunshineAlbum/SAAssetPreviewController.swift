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
	
	var selectedItem: Int = 0
	
	convenience init(assetModels: [AssetModel], selectedItem: Int) {
		
		self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: NSNumber(integerLiteral: 10)])
		self.assetModels = assetModels
		self.selectedItem = selectedItem
	}
	
	override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
		super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let previewPhotoCtr = PreviewPhotoController()
		
		return previewPhotoCtr
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		let previewPhotoCtr = PreviewPhotoController()
		
		return previewPhotoCtr
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return 10
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return 1
	}
	
	
}
