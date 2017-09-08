//
//  PhotoPreviewCell.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/27.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

class PhotoPreviewCell: UICollectionViewCell, PreviewContentType, UIScrollViewDelegate {
    
    @IBOutlet private weak var contentScrollView: UIScrollView!

    @IBOutlet private weak var contentImageView: UIImageView!
    
    var tapConent: (() -> Void)?
    
    var model: AssetModel? {
        didSet {
            guard let model = model else { return }
            contentImageView.image = nil
            
            SAAssetsManager.shared.fetchPreviewImage(asset: model.asset, isHightQuality: true) { [weak self] (image) in
                guard let `self` = self else { return }
                self.contentImageView.image = image
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentScrollView.delegate = self
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapImageView))
        addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapImageView(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
    }
    
    func recoverSubview() {
        contentScrollView.setZoomScale(1, animated: false)
    }
    
    func singleTapImageView() {
        tapConent?()
    }
    
    func doubleTapImageView(_ gesture: UITapGestureRecognizer) {
        if contentScrollView.zoomScale > 1 {
            contentScrollView.setZoomScale(1, animated: true)
        } else {
            let touchPoint = gesture.location(in: contentImageView)
            let newScale = contentScrollView.maximumZoomScale
            let xSize = frame.size.width / newScale
            let ySize = frame.size.height / newScale
            contentScrollView.zoom(to: CGRect(x: touchPoint.x - xSize/2, y: touchPoint.y - ySize/2, width: xSize, height: ySize), animated: true)
        }
    }
    
    // MARK: - UIScroll view delegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }

}
