//
//  PreviewPhotoController.swift
//  SunshineAlbum
//
//  Created by Garen on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class PreviewPhotoController: UIViewController, PreviewContentControllerType, UIScrollViewDelegate {

    var assetModel: AssetModel? {
        didSet{
            
        }
    }
    
    var tapConent: (() -> Void)?
    
    private lazy var contentView: UIScrollView = { [unowned self] in
        let contentview = UIScrollView()
        contentview.maximumZoomScale = 2.5
        contentview.minimumZoomScale = 1
        contentview.contentMode = .scaleAspectFit
        contentview.delegate = self
        return contentview
    }()
    
    private lazy var imageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    convenience init(assetModel: AssetModel) {
        self.init()
        self.assetModel = assetModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchImageAndDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.black
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapImageView))
        view.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapImageView(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    private func fetchImageAndDisplay() {
        guard let model = assetModel else {
            return
        }
        if let image = SASelectionManager.shared.imagesCaches.object(forKey: model)  {
            imageView.image = image
            return
        }
        SAAssetsManager.shared.fetchPreviewImage(asset: model.asset, isHightQuality: true) { [weak self] (image) in
            
            guard let `self` = self else { return }
            guard let model = self.assetModel else { return }
            
            self.imageView.image = image
            SASelectionManager.shared.imagesCaches.setObject(image, forKey: model)
        }
    }

    func recoverSubview() {
        contentView.setZoomScale(1, animated: false)
    }
    
    @objc private func singleTapImageView() {
        tapConent?()
    }
    
    @objc private func doubleTapImageView(_ gesture: UITapGestureRecognizer) {
        if contentView.zoomScale > 1 {
            contentView.setZoomScale(1, animated: true)
        } else {
            let touchPoint = gesture.location(in: contentView)
            let newScale = contentView.maximumZoomScale
            let xSize = view.bounds.size.width / newScale
            let ySize = view.bounds.size.height / newScale
            contentView.zoom(to: CGRect(x: touchPoint.x - xSize/2, y: touchPoint.y - ySize/2, width: xSize, height: ySize), animated: true)
        }
    }
    
    // MARK: - UIScroll view delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
