//
//  ThumbnailPhotoCell.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/19.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

enum ThumbnailCellShowType {
	case MutiSelection
	case SingleSelection
}

class ThumbnailPhotoCell: UICollectionViewCell {
    
    var model: AssetModel? {
        didSet {
            guard let model = model else { return }
			
			selectedButton.isSelected = model.isSelected
			selectedButton.isHidden = model.type != .image
			videoIcon.isHidden = (model.type != .video)
			
			showIndex = 0
			
			durationLabel.text = (model.type == .video) ? String(format: "%d:%02d", Int(model.videoDuration) / 60, Int(model.videoDuration) % 60)  : nil
			
			thumbnailView.image = UIImage(named: "icon_album_placeholder", in: Bundle.currentResourceBundle, compatibleWith: nil)
			
			AssetsManager.shared.fetchThumbnailImage(asset: model.asset, width: SAAlbumThumbnailSize.width, height: SAAlbumThumbnailSize.height) { [weak self] (image) in
				self?.thumbnailView.image = image
			}
        }
    }
	
	var showMask: Bool = false {
		didSet {
			cellMaskView.isHidden = !showMask
		}
	}
	
	var showIndex: Int = 0 {
		didSet {
			selectedButton.index = showIndex
			selectedButton.isSelected = showIndex > 0
		}
	}
	
	var showType: ThumbnailCellShowType = .MutiSelection {
		didSet {
			selectedButton.isHidden = (showType == .SingleSelection)
		}
	}
	
	var didClickSelectedButton: ((inout Bool, AssetModel) -> Void)?
    
    @IBOutlet private weak var thumbnailView: UIImageView!

    @IBOutlet private weak var selectedButton: SelectionButton!
    
    @IBOutlet private weak var videoIcon: UIImageView!
    
    @IBOutlet private weak var durationLabel: UILabel!
    
    @IBOutlet private weak var cellMaskView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
		selectedButton.didClick = { [weak self] sender in
			
			guard let `self` = self else { return }
			
			var isSelected: Bool = !sender.isSelected
			
			guard let model = self.model else { return }
			
			self.didClickSelectedButton?(&isSelected, model)
			
			sender.isSelected = isSelected
		}
    }
	
	func refreshDisplayStatus(showMask: Bool, isSelected: Bool) {
		self.showMask = showMask
		selectedButton.isSelected = isSelected
	}

}
