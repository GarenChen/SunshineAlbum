//
//  SANavigationBar.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class SANavigationBar: UIToolbar {

	var didClickedBack: (() -> Void)?
	
	var didClickedRightItem: ((UIButton) -> Void)?
	
	var backItemTitle: String? {
		didSet {
			backButton.setTitle(backItemTitle, for: .normal)
		}
	}
	
	var rightItemIndex: Int = 0 {
		didSet {
			rightButton.index = rightItemIndex
		}
	}
	
	private lazy var backButton: UIButton = {
		let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 44))
		let backIcon = UIImage(named: "icon_back.png", in: Bundle.currentResourceBundle, compatibleWith: nil)
		backButton.setImage(backIcon, for: .normal)
		backButton.addTarget(self, action: #selector(clickBackButton(sender:)), for: .touchUpInside)
		return backButton
	}()
	
	private lazy var rightButton: SASelectionButton = { [unowned self] in
		let rightButton = SASelectionButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
		rightButton.didClick = {[weak self] sender in
			self?.didClickedRightItem?(sender)
		}
		return rightButton
	}()
	

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupViews()
	}
	
	private func setupViews() {
		
		barStyle = .blackTranslucent
		
		let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		items = [UIBarButtonItem(customView: backButton), flexibleSpace, UIBarButtonItem(customView: rightButton)]
	}
	
	@objc private func clickBackButton(sender: UIButton) {
		didClickedBack?()
	}

}
