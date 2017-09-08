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
        firstButton.backgroundColor = UIColor(redValue: 10, greenValue: 118, blueValue: 233, alpha: 0.9)
        firstButton.frame = CGRect(x: 10, y: 0, width: 70, height: 44)
        firstButton.layer.cornerRadius = 2
        firstButton.layer.masksToBounds = true
        firstButton.setTitleColor(.white, for: .normal)
        firstButton.setTitleColor(.lightGray, for: .highlighted)
        firstButton.setBackgroundImage(UIColor(redValue: 10, greenValue: 118, blueValue: 233, alpha: 0.9).toImage(), for: .selected)
        firstButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        firstButton.addTarget(self, action: #selector(didClickedfirstBtn(_:)), for: .touchUpInside)
        return firstButton
    }()
    
    lazy var secondButton: UIButton = { [unowned self] in
        let secondButton = UIButton()
        secondButton.backgroundColor = UIColor(redValue: 10, greenValue: 118, blueValue: 233, alpha: 0.9)
        secondButton.frame = CGRect(x: UIScreen.ScreenWidth - 80, y: 0, width: 70, height: 44)
        secondButton.layer.cornerRadius = 2
        secondButton.layer.masksToBounds = true
        secondButton.setTitleColor(.white, for: .normal)
        secondButton.setTitleColor(.lightGray, for: .highlighted)
        secondButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        secondButton.addTarget(self, action: #selector(didClickedSeconedBtn(_:)), for: .touchUpInside)
        return secondButton
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
        addSubview(secondButton)
    }
    
    @objc private func didClickedfirstBtn(_ button: UIButton) {
        didClickedFirst?(button)
    }
    
    @objc private func didClickedSeconedBtn(_ button: UIButton) {
        didClickedSecond?(button)
    }

}
