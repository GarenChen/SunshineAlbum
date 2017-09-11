//
//  AlbumMutiSelecttionView.swift
//  PhotosDemo
//
//  Created by Garen on 2017/8/19.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

public class AlbumThumbnailCollectionViewLayout: UICollectionViewFlowLayout {
	
	var cellPadding: CGFloat = 4
	
	var column: CGFloat = 4
	
	public override init() {
		super.init()
		setupLayout()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func setupLayout() {
		
		minimumInteritemSpacing = 0
		
		let width = (UIScreen.ScreenWidth - cellPadding) / column -  cellPadding
		let height = width
		
		itemSize = CGSize(width: width, height: height)
		minimumLineSpacing = cellPadding
		sectionInset = UIEdgeInsets(top: cellPadding, left: cellPadding, bottom: cellPadding, right: cellPadding)
	}
	
}

class AlbumMutiSelecttionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {

	var albumModel: AlbumsModel? {
		didSet {
			reloadData()
		}
	}
	
    var maxSelectedCount: Int = 9
	
    var selectedModel: Array<AssetModel> = [] {
        didSet {
            
            selectedModelsDidChange?(selectedModel)
            
            needMaskUnSelectedItems = selectedModel.count >= maxSelectedCount
            reloadItems(at: indexPathsForVisibleItems)
        }
    }
    
    var selectedModelsDidChange: ((Array<AssetModel>) -> Void)?
	
	var didSelectedCell: ((IndexPath, AssetModel) -> Void)?
	
	private var needMaskUnSelectedItems: Bool = false
	
	convenience init() {
		self.init(frame: .zero, collectionViewLayout: AlbumThumbnailCollectionViewLayout())
	}
	
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        setupViews()
	}
	
	private func setupViews() {
        
        backgroundColor = .white
        
		delegate = self
		dataSource = self
		
		register(UINib(nibName: ThumbnailPhotoCell.reusedId, bundle: Bundle.currentResourceBundle), forCellWithReuseIdentifier: ThumbnailPhotoCell.reusedId)
	}
	
	// MARK: - data source
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return albumModel?.assetModels.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		guard let albumModel = albumModel else { return UICollectionViewCell() }
		
		let assetModel = albumModel.assetModels[indexPath.item]
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailPhotoCell.reusedId, for: indexPath) as! ThumbnailPhotoCell
		
		cell.model = assetModel
		
		let index = selectedModel.index { (model) -> Bool in
			return model.identifier == assetModel.identifier
		}
		cell.showIndex = (index == nil) ? 0 : index! + 1
		
        if assetModel.type == .image {
            cell.showMask = !assetModel.isSelected && needMaskUnSelectedItems
        } else {
            cell.showMask = !selectedModel.isEmpty
        }

        cell.didClickSelectedButton = { [weak self, weak cell] (isSelected, model) in
            
            guard let `self` = self else { return }
            
            if isSelected && (self.selectedModel.count >= self.maxSelectedCount) {
                isSelected = false
                self.nearestController()?.showAlert(title: "最多只能选择\(self.maxSelectedCount)张照片",actions: ("确定", nil))
                return
            }
            
            model.isSelected = isSelected
            
            let index = self.selectedModel.index(where: { (selected) -> Bool in
                return selected.identifier == model.identifier
            })
			cell?.showIndex = (index == nil) ? 0 : index! + 1
            
            if isSelected && (index == nil) {
                self.selectedModel.append(model)
            } else if !isSelected && (index != nil) {
                self.selectedModel.remove(at: index!)
            }
        }
		return cell
	}
	
	// MARK: - delegate
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailPhotoCell
		cell?.isSelected = false
        
		guard let albumModel = albumModel else { return }
        
        let assetModel = albumModel.assetModels[indexPath.item]
        
        if (selectedModel.count >= maxSelectedCount) && !assetModel.isSelected {
            self.nearestController()?.showAlert(title: "最多只能选择\(self.maxSelectedCount)张照片",actions: ("确定", nil))
            return
        }

        if !selectedModel.isEmpty && (assetModel.type !=  .image) {
            return
        }

		didSelectedCell?(indexPath, assetModel)
	}

}
