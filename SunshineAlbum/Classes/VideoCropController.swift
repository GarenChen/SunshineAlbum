//
//  VideoCropController.swift
//  SunshineAlbum
//
//  Created by ChenGuangchuan on 2017/9/11.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

enum VideoEditingType {
	case standby
	case editing
	case finish
}

class VideoCropController: UIViewController {
    
    var assetModel: AssetModel?
	
	var isPlaying: Bool = false
	
	var editingType: VideoEditingType = .standby {
		didSet {
			rightButtonItem.isEnabled = (editingType == .finish)
		}
	}
	
	var totalDurations: CMTime = kCMTimeZero
	
	var currentDurations: CMTime = kCMTimeZero
	
	var startedDurations: CMTime = kCMTimeZero
	
	var endDurations: CMTime = kCMTimeZero

	var secondDelta: Double = 0
	
	private var playerItem: AVPlayerItem?
	
	private var player: AVPlayer?
	
	private var playbackTimeObserver: Any?
	
	private lazy var playerView: PlayerView = { [unowned self] in
		let playerView = PlayerView()
		playerView.frame = CGRect(x: 0, y: 44, width: UIScreen.ScreenWidth, height: UIScreen.ScreenHeight - 144)
		return playerView
	}()
	
	private lazy var rightButtonItem: UIBarButtonItem = { [unowned self] in
		UIBarButtonItem(title: "重新截取", style: .plain, target: self, action: #selector(didClickedRightItem))
	}()
	
	private lazy var videoSlider: UISlider = { [unowned self] in
		let videoSlider = UISlider(frame: CGRect(x: 20, y: UIScreen.ScreenHeight - 100, width: UIScreen.ScreenWidth - 40, height: 20))
		videoSlider.isContinuous = true
		videoSlider.minimumTrackTintColor = .lightGray
		videoSlider.addTarget(self, action: #selector(videoSliderJump(_:)), for: .touchUpInside)
		videoSlider.addTarget(self, action: #selector(videoSliderValueChanged(_:)), for: .valueChanged)
		return videoSlider
	}()

	private lazy var startButton: VideoCropButton = { [unowned self] in
		let startButton = VideoCropButton(frame: CGRect(x: (UIScreen.ScreenWidth - 80) / 2, y: UIScreen.ScreenHeight - 80, width: 80, height: 80))
		startButton.title = "开始截取"
		startButton.didClick = { [weak self] sender in
			self?.didClickStartEditingButton(sender)
		}
		return startButton
	}()
	
	override var prefersStatusBarHidden: Bool {
		return true
	}

    convenience init(assetModel: AssetModel) {
        self.init()
        self.assetModel = assetModel
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.rightBarButtonItem = rightButtonItem
		view.addSubview(playerView)
		view.addSubview(videoSlider)
		view.addSubview(startButton)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let assetModel = assetModel else { return }
		AssetsManager.shared.fetchAVPlayerItem(asset: assetModel.asset, success: { [weak self] (item) in
			DispatchQueue.main.async {
				self?.setupPlayerItem(item)
			}
			
		})
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
		playerItem?.removeObserver(self, forKeyPath: "status")
		
		if playbackTimeObserver != nil {
			playerView.player.removeTimeObserver(playbackTimeObserver!)
		}
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "status" {
			guard let item = playerItem, item.status == .readyToPlay else {
				return
			}
			
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }
				self.totalDurations = item.duration
				self.setupVideoSlider(duration: self.totalDurations)
				self.monitoringPlayback(playerItem: item)
			}

		}
	}
	
	private func setupPlayerItem(_ playerItem: AVPlayerItem) {
		self.playerItem = playerItem
		self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(endPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
		player = AVPlayer(playerItem: self.playerItem)
		playerView.player = player
	}
	
	private func monitoringPlayback(playerItem: AVPlayerItem) {
		playbackTimeObserver = playerView.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil) { [weak self] (time) in

			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }
				
				self.currentDurations = playerItem.currentTime()
				
				let currentSecond =  Double(playerItem.currentTime().value) / Double(playerItem.currentTime().timescale)
				
				self.videoSlider.setValue(Float(currentSecond), animated: true)
				
				self.secondDelta = currentSecond - CMTimeGetSeconds(self.startedDurations)
//				
//				print("startedDurations:\(self.startedDurations)")
//				print("currentDurations:\(self.currentDurations)")
//				
				if self.editingType == .editing {
					self.startButton.title = "00:\(String(format: "%02d", Int(self.secondDelta)))"
				}

				if self.secondDelta >= 10 {
					self.pause()
					self.endDurations = self.currentDurations
					self.videoSlider.isUserInteractionEnabled = true
					self.editingType = .finish
					self.startButton.title = "完成"
				}
			}
		}
	}
//	
//	private func convertTime(seconds: Float) ->  {
//		
//	}
	
	private func play() {
		playerView.player.rate = 1.0
		playerView.player.play()
	}
	
	private func pause() {
		playerView.player.pause()
	}
	
	@objc private func endPlaying() {
		
		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }
			self.playerView.player.currentItem?.seek(to: CMTime(value: 0, timescale: 1))
			self.videoSlider.isUserInteractionEnabled = true
			self.editingType = .finish
			self.startButton.title = "完成"
			self.endDurations = self.currentDurations
		}
		
	}
	
	@objc private func didClickedRightItem() {
		videoSlider.isUserInteractionEnabled = false
		startedDurations = currentDurations
		editingType = .editing
		play()
	}
	
	private func setupVideoSlider(duration: CMTime) {
		videoSlider.maximumValue = Float(CMTimeGetSeconds(duration))
		debuglog("setupVideoSlider maximumValue : \(videoSlider.maximumValue)")
	}

	@objc private func videoSliderJump(_ sender: UISlider) {
		debuglog("videoSliderValueChanged : \(sender.value)")

		let changedTime = CMTime(seconds: Double(Int(sender.value)), preferredTimescale: 1)
		self.currentDurations = changedTime
		playerView.player.seek(to: changedTime) { (finished) in
			
		}
	}
	
	@objc private func videoSliderValueChanged(_ sender: UISlider) {
		debuglog("videoSliderValueChanged : \(sender.value)")
		
		if sender.value == 0.0 {
			playerView.player.seek(to: kCMTimeZero, completionHandler: { (finished) in
			})
		}
	}
	
	@objc private func didClickStartEditingButton(_ sender: UIButton) {
		switch self.editingType {
		case .standby:
			videoSlider.isUserInteractionEnabled = false
			editingType = .editing
			startedDurations = currentDurations
			play()
		case .editing:
			pause()
			videoSlider.isUserInteractionEnabled = true
			editingType = .finish
			startButton.title = "完成"
			self.endDurations = self.currentDurations
		case .finish:
			videoSlider.isUserInteractionEnabled = true
            guard let assetModel = assetModel else { return }
            AssetsManager.shared.cropVideo(asset: assetModel.asset, startTime: self.startedDurations, endTime: self.endDurations, success: { [weak self] (url) in
                print("\(url)")
				let asset = AVURLAsset(url: url, options: nil)
                DispatchQueue.main.async {  [weak self] in
                    (self?.navigationController as? SunshineAlbumController)?.didFinishSelectedVideo(asset: asset)
                }
				
            })
			debuglog("completed")
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
