//
//  VideoCropButton.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/11.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class VideoCropButton: UIButton {

	var title: String? {
		didSet {
			setTitle(title, for: .normal)
		}
	}
	
	var didClick: ((_ sender: VideoCropButton) -> Void)?
	
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
		layer.borderWidth = 4
		layer.borderColor = UIColor.white.cgColor
		
		setBackgroundImage(SAUIConfig.shared.tintColor.toImage(), for: .normal)

		setTitleColor(.white, for: .normal)
		titleLabel?.font = UIFont.systemFont(ofSize: 14)
		
		addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
	}
	
	@objc private func click(_ sender: VideoCropButton) {
		
		didClick?(sender)
		
		transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
		
		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
			self.transform = CGAffineTransform.identity
		}, completion: nil)
		
	}

}
