//
//  PreviewBottomBar.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/28.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

class PreviewBottomBar: UIView {
    
    var didClickDoneButton: (() -> Void)?
    
    lazy var doneButton: UIButton = { [unowned self] in
        let doneButton = UIButton()
        doneButton.frame = CGRect(x: UIScreen.ScreenWidth - 80, y: 0, width: 70, height: 44)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setTitleColor(.lightGray, for: .highlighted)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.addTarget(self, action: #selector(clickDoneButton(_:)), for: .touchUpInside)
        return doneButton
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
        addSubview(self.doneButton)
    }
    
    func clickDoneButton(_ button: UIButton) {
        didClickDoneButton?()
    }

}
