//
//  ThumbnailPhotoCell.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/19.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

class ThumbnailPhotoCell: UICollectionViewCell {
    
    var model: AssetModel? {
        didSet {
            guard let model = model else { return }
			
			selectedButton.isSelected = model.isSelected
			selectedButton.isHidden = model.type != .image
			videoIcon.isHidden = (model.type != .video)

			durationLabel.text = (model.type == .video) ? "\(Int(model.videoDuration) / 60):\(Int(model.videoDuration) % 60)" : nil
			
			thumbnailView.image = UIImage(named: "icon_album_placeholder")
			
			PhotoSelectorManager.shared.fetchThumbnailImage(asset: model.asset, width: 100 * UIScreen.ScreenScale, height: 100 * UIScreen.ScreenScale) { [weak self] (image) in
				self?.thumbnailView.image = image
			}
        }
    }
	
	var showMask: Bool = false {
		didSet {
			cellMaskView.isHidden = !showMask
		}
	}
	
	var didClickSelectedButton: ((inout Bool, AssetModel) -> Void)?
    
    @IBOutlet private weak var thumbnailView: UIImageView!

    @IBOutlet private weak var selectedButton: UIButton!
    
    @IBOutlet private weak var videoIcon: UIImageView!
    
    @IBOutlet private weak var durationLabel: UILabel!
    
    @IBOutlet private weak var cellMaskView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	@IBAction func clickSelectedButton(_ sender: UIButton) {
		
        var isSelected: Bool = !sender.isSelected
        
        guard let model = model else { return }
        
		didClickSelectedButton?(&isSelected, model)

		sender.isSelected = isSelected
	}
	
}
