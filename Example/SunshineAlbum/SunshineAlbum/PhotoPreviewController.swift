//
//  PhotoPreviewController.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/27.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit

class PhotoPreviewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var albumsModel: AlbumsModel? {
        didSet {
        }
    }
    
    var selectedItem: Int = 0
    
    var maxSelectedCount: Int = 9
    
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.ScreenWidth + 20, height: UIScreen.ScreenHeight)
        
        let coll = UICollectionView(frame: CGRect(x: -10, y: 0, width: UIScreen.ScreenWidth + 20, height: UIScreen.ScreenHeight), collectionViewLayout: layout)
        coll.isPagingEnabled = true
        coll.showsHorizontalScrollIndicator = false
        coll.scrollsToTop = false
        coll.dataSource = self
        coll.delegate = self
        coll.register(UINib(nibName: PhotoPreviewCell.reusedId, bundle: nil), forCellWithReuseIdentifier: PhotoPreviewCell.reusedId)
        return coll
    }()
    
    private lazy var backButton: UIButton = { [unowned self] in
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        backButton.setImage(UIImage(named: "icon_preview_back_dark"), for: .normal)
        return backButton
    }()
    
    private lazy var selectedButton: UIButton = { [unowned self] in
        let selectedButton = UIButton()
        selectedButton.frame = CGRect(x: UIScreen.ScreenWidth - 64, y: 0, width: 64, height: 64)
        selectedButton.imageEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        selectedButton.addTarget(self, action: #selector(clickSelectedButton(_:)), for: .touchUpInside)
        selectedButton.setImage(UIImage(named: "icon_preview_normal_light"), for: .normal)
        selectedButton.setImage(UIImage(named: "icon_picture_selected"), for: .selected)
        return selectedButton
    }()

    private lazy var customNavagationBar: UIView = { [unowned self] in
        let bar = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.ScreenWidth, height: 64))
        bar.backgroundColor = UIColor(colorLiteralRed: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
        bar.addSubview(self.backButton)
        bar.addSubview(self.selectedButton)
        return bar
    }()

    private lazy var customBottombar: PreviewBottomBar = { [unowned self] in
        let bar  = PreviewBottomBar(frame: CGRect(x: 0, y: UIScreen.ScreenHeight - 44, width: UIScreen.ScreenWidth, height: 44))
//        bar.didClickDoneButton = { [weak self] in
//            self?.clickDoneButton()
//        }
        return bar
    }()
    
    private var isShowBars: Bool = true

    convenience init(albumsModel: AlbumsModel, selectedItem: Int) {
        self.init()
        self.albumsModel = albumsModel
        self.selectedItem = selectedItem
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupviews()
    }
    
    private func setupviews() {
        
        view.addSubview(collectionView)
        view.addSubview(customNavagationBar)
        view.addSubview(customBottombar)
        
        refreshCustomBars()
        
        collectionView.scrollToItem(at: IndexPath(item: selectedItem, section: 0), at: .left, animated: false)
        
        collectionView.backgroundColor = .black
        
    }
    
    private func refreshCustomBars() {
        
        if isShowBars {
            customNavagationBar.isHidden = false
            customBottombar.isHidden = false
            
            guard let photoSelectorCtr = navigationController as? PhotoSelectorController else { return }
            guard let albumsModel = albumsModel else { return }
            
            let currentModel = albumsModel.assetModels[selectedItem]
            
            selectedButton.isSelected = currentModel.isSelected
            
//            customBottombar.doneButton.isEnabled = !photoSelectorCtr.selectedModels.isEmpty
//            
//            let doneButtonTitle = photoSelectorCtr.selectedModels.isEmpty ? "完成" : "完成(\(photoSelectorCtr.selectedModels.count))"
//            customBottombar.doneButton.setTitle(doneButtonTitle, for: .normal)
            
        } else {
            customNavagationBar.isHidden = true
            customBottombar.isHidden = true
        }
        
    }
    
    func clickBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func clickSelectedButton(_ button: UIButton) {
        guard let photoSelectorCtr = navigationController as? PhotoSelectorController else { return }
        guard let model = albumsModel?.assetModels[selectedItem] else { return }
        
        let isSelected = !button.isSelected
        if isSelected && (photoSelectorCtr.selectedModels.count >= maxSelectedCount) {
            showAlert(title: "最多只能选择\(self.maxSelectedCount)张照片",actions: ("确定", nil))
            return
        }
        
        button.isSelected = isSelected
        
        model.isSelected = button.isSelected
        
        let index = photoSelectorCtr.selectedModels.index(where: { (selected) -> Bool in
            return selected.identifier == model.identifier
        })
        if button.isSelected && (index == nil) {
            photoSelectorCtr.selectedModels.append(model)
        } else if !button.isSelected && (index != nil) {
            photoSelectorCtr.selectedModels.remove(at: index!)
        }
        
        refreshCustomBars()
    }
    
    func clickDoneButton() {
         guard let photoSelectorCtr = navigationController as? PhotoSelectorController else { return }
        photoSelectorCtr.didFinishSelectedPhotos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - uicollectionview delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsModel?.assetModels.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let model = albumsModel?.assetModels[indexPath.item] else { return UICollectionViewCell() }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPreviewCell.reusedId, for: indexPath) as! PhotoPreviewCell
        cell.model = model
        cell.clickImage = { [weak self] in
            guard let `self` = self else { return }
            self.isShowBars = !self.isShowBars
            self.refreshCustomBars()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PhotoPreviewCell)?.recoverSubview()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetWidth = scrollView.contentOffset.x + (UIScreen.ScreenWidth + 20) * 0.5
        let currentItem = Int(offsetWidth / (UIScreen.ScreenWidth + 20))
        if selectedItem != currentItem {
            selectedItem = currentItem
            refreshCustomBars()
        }
    }
    
}
