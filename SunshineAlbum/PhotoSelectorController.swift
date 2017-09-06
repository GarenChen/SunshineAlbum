//
//  PhotoSelectorController.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/11.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

enum SelectedType {
    case photo(Array<UIImage>)
    case video(URL)
}

class PhotoSelectorController: UINavigationController {

    var selectedModels: [AssetModel] = []
    
    var complitionHandler: ((SelectedType) -> Void)?
    
    var showAlbumList: Bool = true

    convenience init(showAlbumList: Bool, containVideo: Bool, complition: @escaping (SelectedType) -> Void) {
        PhotoSelectorManager.shared.showVideo = containVideo
        let albumsList = AlbumsListController(models: [])
        self.init(rootViewController: albumsList)
        self.showAlbumList = showAlbumList
        self.complitionHandler = complition
        
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !showAlbumList {
            guard let model = PhotoSelectorManager.shared.fetchCameraRoll() else {
                return
            }
            let ctr = AlbumSelectionController(model: model)
            self.pushViewController(ctr, animated: false)
        }
    }
    
    func setupView() {
        self.navigationBar.tintColor = .white
        self.navigationBar.barStyle = .blackTranslucent
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didFinishSelectedPhotos() {
        
        dismissController()
        
        debuglog("\(selectedModels.description)")
        var images: [UIImage] = []
        selectedModels.forEach { (model) in
            PhotoSelectorManager.shared.fetchResultImage(asset: model.asset, isHightQuality: true, complition: { (image) in
                images.append(image)
            })
        }
        complitionHandler?(.photo(images))
    }
    
    func didFinishSelectedVideo(assetModel: AssetModel) {
        
        dismissController()
        debuglog("\(assetModel.description)")
        
        PhotoSelectorManager.shared.imageManager.requestAVAsset(forVideo: assetModel.asset, options: nil) { [weak self] (avAsset, audioMix, info) in
            
            guard let asset = avAsset as? AVURLAsset else { return }
            self?.complitionHandler?(.video(asset.url))
        }
        
    }
    
}
