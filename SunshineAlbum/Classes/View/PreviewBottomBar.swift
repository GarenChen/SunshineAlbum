//
//  PreviewBottomBar.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/28.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

class PreviewBottomBar: UIView {
    
    var didClickedFirst: ((UIButton) -> Void)?
    
    var didClickedSecond:  ((UIButton) -> Void)?

    lazy var firstButton: UIButton = { [unowned self] in
        let firstButton = UIButton()
        firstButton.frame = CGRect(x: 12, y: 8, width: 96, height: 32)
        firstButton.layer.cornerRadius = 2
        firstButton.layer.masksToBounds = true
        firstButton.contentHorizontalAlignment = .left
        firstButton.setTitleColor(SAUIConfig.shared.normalTextColor, for: .normal)
        firstButton.setTitleColor(SAUIConfig.shared.disableTextColor, for: .disabled)
        firstButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        firstButton.addTarget(self, action: #selector(didClickedfirstBtn(_:)), for: .touchUpInside)
        return firstButton
    }()
    
    lazy var secondButton: UIButton = { [unowned self] in
        let secondButton = UIButton()
        secondButton.backgroundColor = SAUIConfig.shared.tintColor
        secondButton.frame = CGRect(x: UIScreen.ScreenWidth - 76, y: 8, width: 66, height: 32)
        secondButton.layer.cornerRadius = 2
        secondButton.layer.masksToBounds = true
        secondButton.setTitleColor(SAUIConfig.shared.normalTextColor, for: .normal)
        secondButton.setTitleColor(SAUIConfig.shared.lightGrayTextColor, for: .disabled)
        secondButton.setBackgroundImage(SAUIConfig.shared.buttonDisableColor.toImage(), for: .disabled)
        secondButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        secondButton.addTarget(self, action: #selector(didClickedSeconedBtn(_:)), for: .touchUpInside)
        return secondButton
    }()
    
    lazy var decLabel: UILabel = { [unowned self] in
        let decLabel = UILabel()
        decLabel.textColor = SAUIConfig.shared.lightGrayTextColor
        decLabel.font = UIFont.systemFont(ofSize: 14)
        decLabel.textAlignment = .left
        decLabel.frame = CGRect(x: 10, y: 8, width: UIScreen.ScreenWidth - 86, height: 32)
        return decLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.15, blue: 0.15, alpha: 0.9)
        
        addSubview(firstButton)
        addSubview(decLabel)
        addSubview(secondButton)
		
    }
    
    @objc private func didClickedfirstBtn(_ button: UIButton) {
        didClickedFirst?(button)
    }
    
    @objc private func didClickedSeconedBtn(_ button: UIButton) {
        didClickedSecond?(button)
    }

}
