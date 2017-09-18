//
//  ImageCropperViewController.swift
//  Pods
//
//  Created by Garen on 2017/9/18.
//
//

import UIKit

class ImageCropperViewController: UIViewController {
	
	var assetModel: AssetModel?
	
	var imageCropFrame: CGRect = .zero
	
	var originalImage: UIImage? {
		didSet {
			guard let image = originalImage else { return }
			let oldWidth = imageCropFrame.size.width
			let oldHeight = image.size.height * (oldWidth / image.size.height)
			let oldX = imageCropFrame.origin.x + (imageCropFrame.width - oldWidth) / 2
			let oldY = imageCropFrame.origin.y + (imageCropFrame.size.height - oldHeight) / 2
			oldFrame = CGRect(x: oldX, y: oldY, width: oldWidth, height: oldHeight)
		}
	}
	
	var oldFrame: CGRect = .zero
	
	var largeFrame: CGRect = .zero
	
	var limitRatio: CGFloat = 0
	
	var latestFrame: CGRect = .zero
	
	lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.frame = UIScreen.main.bounds
		imageView.isUserInteractionEnabled = true
		imageView.isMultipleTouchEnabled = true
		return imageView
	}()
	
	lazy var overLayView: UIView = {
		let overLayView = UIView()
		
		return overLayView
	}()
	
	lazy var ratioView: UIView = {
		let ratioView = UIView()
		
		return ratioView
	}()
	
	convenience init(assetModel: AssetModel, imageCropFrame: CGRect = SASelectionManager.shared.imageCropFrame) {
		self.init()
		self.assetModel = assetModel
		self.imageCropFrame = imageCropFrame
		AssetsManager.shared.fetchPreviewImage(asset: assetModel.asset) { [weak self] (image) in
			guard let `self` = self else { return }
			self.originalImage = image
			self.imageView.image = image
		}
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setupViews()
        // Do any additional setup after loading the view.
    }
	
	private func setupViews() {
		view.backgroundColor = .black
		
		view.addSubview(imageView)
		
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
