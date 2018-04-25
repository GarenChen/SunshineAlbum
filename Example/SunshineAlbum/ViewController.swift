//
//  ViewController.swift
//  SunshineAlbum
//
//  Created by GarenChen on 09/06/2017.
//  Copyright (c) 2017 GarenChen. All rights reserved.
//

import UIKit
import SunshineAlbum

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib
		view.backgroundColor = .blue
		
		
		
		
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
	
		var config = SunshineAlbumSelectionConfig()
		config.maxSelectedCount = 8
		config.canCropImage = true
		config.containType = .both
		
		let ctr = SunshineAlbumController(showAlbumList: true, config: config) { (type) in
			switch type {
			case .photo(let images):
				var y: CGFloat = 0
				images.forEach({ (image) in
					let imageView = UIImageView(frame: CGRect(x: 0, y: y, width: UIScreen.main.bounds.size.width, height: 80))
					imageView.image = image
					imageView.contentMode = .scaleAspectFit
					self.view.addSubview(imageView)
					y += 80
				})
				
			case .video(let asset):
				print("video: \(asset)")
				print("video asset.url.absoluteString: \(asset.url.absoluteString)")
				print("video asset.url.path: \(asset.url.path)")
				break
			}
		}
		present(ctr, animated: true, completion: nil)
	}
	
	
}

