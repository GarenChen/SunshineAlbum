//
//  SASelectionButton.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

//struct SelectionButtonConfig {
//	static let normalColor = UIColor(white: 0.7, alpha: 0.3)
//	static let selectedColor = UIColor(redValue: 10, greenValue: 118, blueValue: 233, alpha: 0.9)
//	
//	static let titleColor = UIColor.white
//	static let titleFont = UIFont.systemFont(ofSize: 14)
//	
//	static let borderWidth = 1
//	static let borderColor = UIColor.white.cgColor
//}

class SASelectionButton: UIButton {
	
	var index: Int = 0 {
		didSet {
			let indexStr: String? = (index > 0) ? "\(index)" : nil
			setTitle(indexStr, for: .selected)
		}
	}
	
	var didClick: ((_ sender: SASelectionButton) -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupViews()
	}
	
	private func setupViews() {
		layer.cornerRadius = frame.size.height / 2
		layer.masksToBounds = true
		layer.borderWidth = 1
		layer.borderColor = UIColor.white.cgColor
		
		let normalColor = UIColor(white: 0.7, alpha: 0.3)
		let selectedColor = SAUIConfig.shared.tintColor
		setBackgroundImage(normalColor.toImage(), for: .normal)
		setBackgroundImage(selectedColor.toImage(), for: .selected)
		
		setTitle(nil, for: .normal)
		setTitleColor(.white, for: .normal)
		titleLabel?.font = UIFont.systemFont(ofSize: 14)
		
		addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
	}
	
	@objc private func click(_ sender: SASelectionButton) {
		
		didClick?(sender)

		transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		
		UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { 
			self.transform = CGAffineTransform.identity
		}, completion: nil)

	}
	
}
