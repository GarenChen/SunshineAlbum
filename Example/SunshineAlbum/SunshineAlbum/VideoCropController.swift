//
//  VideoCropController.swift
//  SunshineAlbum
//
//  Created by ChenGuangchuan on 2017/9/11.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class VideoCropController: UIViewController {
    
    var assetModel: AssetModel?

    convenience init(assetModel: AssetModel) {
        self.init()
        self.assetModel = assetModel
        SAAssetsManager.shared.fetchAVPlayerItem(asset: assetModel.asset, success: { [weak self] (item) in
        })
        
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
