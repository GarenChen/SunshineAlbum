//
//  ImageCropperViewController.swift
//  Pods
//
//  Created by Garen on 2017/9/18.
//
//

import UIKit

class ImageCropperViewController: UIViewController {
	
	var didCanceled: (() -> Void)?
	
	var didCropped: ((UIImage?) -> Void)?
	
	private var assetModel: AssetModel?
	
	private var imageCropFrame: CGRect = .zero
	
	private var originalImage: UIImage? {
		didSet {
			guard let image = originalImage else { return }
			let oldWidth = imageCropFrame.size.width
			let oldHeight = image.size.height * (oldWidth / image.size.width)
			let oldX = imageCropFrame.origin.x + (imageCropFrame.width - oldWidth) / 2
			let oldY = imageCropFrame.origin.y + (imageCropFrame.size.height - oldHeight) / 2
			oldFrame = CGRect(x: oldX, y: oldY, width: oldWidth, height: oldHeight)
			
			latestFrame = oldFrame
			largeFrame = CGRect(x: 0, y: 0, width: limitRatio * oldWidth, height: limitRatio * oldHeight)
			
			imageView.frame = oldFrame
		}
	}
	
	private var oldFrame: CGRect = .zero
	
	private var largeFrame: CGRect = .zero
	
	private var limitRatio: CGFloat = 0
	
	private var latestFrame: CGRect = .zero
	
	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.frame = UIScreen.main.bounds
		imageView.isUserInteractionEnabled = true
		imageView.isMultipleTouchEnabled = true
		return imageView
	}()
	
	private lazy var overlayView: UIView = { [unowned self] in
		let overLayView = UIView(frame: self.view.bounds)
		overLayView.alpha = 0.5
		overLayView.backgroundColor = .black
		overLayView.isUserInteractionEnabled = false
		return overLayView
	}()
	
	private lazy var ratioView: UIView = { [unowned self] in
		let ratioView = UIView(frame: self.imageCropFrame)
		ratioView.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor
		ratioView.layer.borderWidth = 1
		return ratioView
	}()
	
	private lazy var bottomBar: UIView = { [unowned self] in
		let bottomBar = UIView(frame: CGRect(x: 0, y: UIScreen.ScreenHeight - 72, width: UIScreen.ScreenWidth, height: 72))
		bottomBar.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		
		let cancelButton = UIButton(frame: CGRect(x: 12, y: 0, width: 80, height: 72))
		cancelButton.contentHorizontalAlignment = .left
		cancelButton.setTitle("取消", for: .normal)
		cancelButton.setTitleColor(.white, for: .normal)
		cancelButton.addTarget(self, action: #selector(didClickCancel(_:)), for: .touchUpInside)
		bottomBar.addSubview(cancelButton)
		
		let confirmButton = UIButton(frame: CGRect(x: UIScreen.ScreenWidth - 92, y: 0, width: 80, height: 72))
		confirmButton.contentHorizontalAlignment = .right
		confirmButton.setTitle("确定", for: .normal)
		confirmButton.setTitleColor(.white, for: .normal)
		confirmButton.addTarget(self, action: #selector(didClickConfirm(_:)), for: .touchUpInside)
		bottomBar.addSubview(confirmButton)
		
		return bottomBar
	}()
	
	convenience init(assetModel: AssetModel,
	                 imageCropFrame: CGRect = SASelectionManager.shared.imageCropFrame,
	                 limitRatio: CGFloat = SASelectionManager.shared.limitRatio) {
		self.init()
		self.assetModel = assetModel
		self.imageCropFrame = imageCropFrame
		self.limitRatio = limitRatio
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
		
		addGestureRecognizer()
		
		view.addSubview(overlayView)
		
		view.addSubview(ratioView)
		
		view.addSubview(bottomBar)
		
		overlayClipping()
	}
	
	private func addGestureRecognizer() {
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
		let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
		view.addGestureRecognizer(pinch)
		view.addGestureRecognizer(pan)
	}
	
	private func overlayClipping() {
		let maskLayer = CAShapeLayer()
		let path = CGMutablePath()
		
		/// left
		path.addRect(CGRect(x: 0, y: 0, width: ratioView.frame.origin.x, height: overlayView.frame.size.height))
		
		/// right
		path.addRect(CGRect(x: ratioView.frame.origin.x + ratioView.frame.size.width, y: 0, width: overlayView.frame.size.width - ratioView.frame.origin.x - ratioView.frame.size.width, height: overlayView.frame.size.height))
		
		/// top
		path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.size.width, height: ratioView.frame.origin.y))
		
		/// bottom
		path.addRect(CGRect(x: 0, y: ratioView.frame.origin.y + ratioView.frame.size.height, width: overlayView.frame.size.width, height: overlayView.frame.size.height - ratioView.frame.origin.y + ratioView.frame.size.height))
		
		maskLayer.path = path
		overlayView.layer.mask = maskLayer
	}
	
	@objc private func didPinch(_ sender: UIPinchGestureRecognizer) {
		
		if sender.state == .began || sender.state == .changed {
			imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
			sender.scale = 1
			
		} else if sender.state == .ended {
			
			var newFrame = imageView.frame
			newFrame = handleScaleOverflow(frame: newFrame)
			newFrame = handleBorderOverflow(frame: newFrame)
			UIView.animate(withDuration: 0.3, animations: { 
				self.imageView.frame = newFrame
				self.latestFrame = newFrame
			})
		}
		
	}
	
	@objc private func didPan(_ sender: UIPanGestureRecognizer) {
		if sender.state == .began || sender.state == .changed {
			let absCenterX = imageCropFrame.origin.x + imageCropFrame.size.width / 2
			let absCenterY = imageCropFrame.origin.y + imageCropFrame.size.height / 2
			let scaleRatio = imageView.frame.size.width / imageCropFrame.size.width
			
			let acceleratorX = 1 - CGFloat(fabs(Double(absCenterX - imageView.center.x))) / (scaleRatio * absCenterX)
			let acceleratorY = 1 - CGFloat(fabs(Double(absCenterY - imageView.center.y))) / (scaleRatio * absCenterY)
			let translation = sender.translation(in: imageView.superview)
			imageView.center = CGPoint(x: imageView.center.x + translation.x * acceleratorX,
			                           y: imageView.center.y + translation.y * acceleratorY)
			sender.setTranslation(.zero, in: imageView.superview)
		} else if sender.state == .ended {
			var newFrame = imageView.frame
			newFrame = handleBorderOverflow(frame: newFrame)
			UIView.animate(withDuration: 0.3, animations: { 
				self.imageView.frame = newFrame
				self.latestFrame = newFrame
			})
		}
	}
	
	@objc private func didClickCancel(_ sender: UIButton) {
		didCanceled?()
	}
	
	@objc private func didClickConfirm(_ sender: UIButton) {
		didCropped?(getCroppedImage())
	}
	
	private func handleScaleOverflow(frame: CGRect) -> CGRect {
		var newFrame = frame
		let originCenter = CGPoint(x: newFrame.origin.x + newFrame.size.width/2, y: newFrame.origin.y + newFrame.size.height / 2)
		if newFrame.size.width < oldFrame.size.width {
			newFrame = oldFrame
		}
		if newFrame.size.width > largeFrame.size.width {
			newFrame = largeFrame
		}
		newFrame.origin = CGPoint(x: originCenter.x - newFrame.size.width / 2,
		                          y: originCenter.y - newFrame.size.height / 2)
		return newFrame
	}
	
	private func handleBorderOverflow(frame: CGRect) -> CGRect {
		var newFrame = frame
		if newFrame.origin.x > imageCropFrame.origin.x {
			newFrame.origin.x = imageCropFrame.origin.x
		}
		if newFrame.maxX < imageCropFrame.size.width {
			newFrame.origin.x = imageCropFrame.size.width - newFrame.size.width
		}
		
		if newFrame.origin.y > imageCropFrame.origin.y {
			newFrame.origin.y = imageCropFrame.origin.y
		}
		if newFrame.maxY < imageCropFrame.origin.y + imageCropFrame.size.height {
			newFrame.origin.y = imageCropFrame.origin.y + imageCropFrame.size.height - newFrame.size.height
		}
		
		if imageView.frame.size.width > imageView.frame.size.height && newFrame.size.height <= imageCropFrame.size.height {
			newFrame.origin.y = imageCropFrame.origin.y + (imageCropFrame.size.height - newFrame.size.height) / 2
		}
		return newFrame
	}
	
	private func getCroppedImage() -> UIImage? {
		
		guard let originalImage = originalImage else { return nil }
		
		let squareFrame = imageCropFrame
		
		let scaleRatio = latestFrame.size.width / originalImage.size.width
		
		var x = (squareFrame.origin.x - latestFrame.origin.x) / scaleRatio
		var y = (squareFrame.origin.y - latestFrame.origin.y) / scaleRatio
		var w = squareFrame.size.width / scaleRatio
		var h = squareFrame.size.height / scaleRatio
		
		if latestFrame.size.width < imageCropFrame.size.width {
			let newW = originalImage.size.width
			let newH = newW * (imageCropFrame.size.height / imageCropFrame.size.width)
			x = 0
			y = y + (h - newH) / 2
			w = newW
			h = newH
		}
		if latestFrame.size.height < imageCropFrame.size.height {
			let newH = originalImage.size.height
			let newW = newH * (imageCropFrame.size.width / imageCropFrame.size.height)
			x = x + (w - newW) / 2
			y = 0
			w = newW
			h = newH
		}
		
		let newImageRect = CGRect(x: x, y: y, width: w, height: h)
		
		
		guard let newImage = originalImage.cgImage?.cropping(to: newImageRect) else {
			return nil
		}
		
		UIGraphicsBeginImageContext(newImageRect.size)
		guard  let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		context.draw(newImage, in: newImageRect)
		let resultImage = UIImage(cgImage: newImage)
		UIGraphicsEndImageContext()
		
		return resultImage
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
