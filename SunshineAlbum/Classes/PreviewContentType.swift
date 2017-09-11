//
//  PreviewContentType.swift
//  SunshineAlbum
//
//  Created by ChenGuangchuan on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

protocol PreviewContentType: class {
    
    var tapConentToHideBar: ((Bool) -> Void)? {get set}
    
    func recoverSubview()
}
