//
//  ViewController.swift
//  SunshineAlbum
//
//  Created by GarenChen on 09/06/2017.
//  Copyright (c) 2017 GarenChen. All rights reserved.
//

import UIKit
//import SunshineAlbum

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
		let ctr = PhotoSelectorController(showAlbumList: false, containVideo: true) { (type) in
			switch type {
			case .photo(let images):
				
				images.forEach({ (image) in
					let imageView = UIImageView()
					imageView.image = image
					imageView.frame = self.view.bounds
					imageView.contentMode = .scaleAspectFit
					self.view.addSubview(imageView)
					sleep(3)
				})
				
			case .video(_):
				break
			}
		}
		present(ctr, animated: true, completion: nil)
	}
	
	
}

