//
//  AlbumsListCell.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/19.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit
import Photos

class AlbumsListCell: UITableViewCell {
    
    var albumModel: AlbumsModel? {
        didSet {
            debuglog(albumModel?.description ?? "albumModel is nil")
            guard let albumModel = albumModel else {
                return
            }
            titleLabel.text = albumModel.albumName
            quantityLabel.text = "(\(albumModel.count))"
            
            guard let firstAsset = albumModel.assetResult.firstObject else {
                return
            }
            
            PHImageManager.default().requestImage(for: firstAsset, targetSize: CGSize(width: 80, height: 80), contentMode: .aspectFill, options: nil) { [weak self] (image, info) in
                if let resultImage = image {
                    self?.thumbnailView.image = resultImage
                }
            }
        }
    }
    
    @IBOutlet private weak var thumbnailView: UIImageView!

    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var quantityLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
