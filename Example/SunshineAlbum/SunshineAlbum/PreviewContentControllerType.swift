//
//  PreviewContentControllerType.swift
//  SunshineAlbum
//
//  Created by ChenGuangchuan on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

protocol PreviewContentType: class {
    
    var tapConent: (() -> Void)? {get set}
    
    func recoverSubview()
}
