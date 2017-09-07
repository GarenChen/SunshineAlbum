//
//  PreviewVideoController.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/29.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class PreviewVideoController: AVPlayerViewController {

    var assetModel: AssetModel?
    
    var isPlay: Bool = false
    
    var playItem: AVPlayerItem?
    
    private lazy var customBottombar: PreviewBottomBar = { [unowned self] in
        let bar  = PreviewBottomBar(frame: CGRect(x: 0, y: UIScreen.ScreenHeight - 44, width: UIScreen.ScreenWidth, height: 44))
        bar.doneButton.setTitle("完成", for: .normal)
        bar.didClickDoneButton = { [weak self] in
            self?.clickDoneButton()
        }
        return bar
    }()
    
    private lazy var playerLayer: AVPlayerLayer = { [unowned self] in
        let playLayer = AVPlayerLayer(player: self.player)
        playLayer.frame = self.view.frame
        return playLayer
    }()
    
    private lazy var playButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon_preview_video_play"), for: .normal)
        button.setImage(UIImage(named: "icon_preview_video_play_highlighted"), for: .highlighted)
        button.addTarget(self, action: #selector(didclickPlayButton(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        self.view.addConstraints([
            NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        return button
    }()
    
    convenience init(assetModel: AssetModel) {
        self.init()
        self.assetModel = assetModel
        SAAssetsManager.shared.fetchAVPlayerItem(asset: assetModel.asset, success: { [weak self] (item) in
            self?.playItem = item
        })
        
    }
    
    convenience init(url: URL) {
        self.init()
        self.playItem = AVPlayerItem(url: url)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return isPlay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        
        self.player = AVPlayer(playerItem: playItem)
        
        self.showsPlaybackControls = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillRisgnActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(endPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        _ = playButton
        view.addSubview(customBottombar)
    }
    
    func endPlaying() {
        self.didclickPlayButton(self.playButton)
        self.player?.currentItem?.seek(to: CMTime(value: 0, timescale: 1))
    }
    
    func appWillRisgnActive() {
        if isPlay {
            self.didclickPlayButton(self.playButton)
        }
    }
    
    func showBars(_ isshow: Bool) {
        navigationController?.setNavigationBarHidden(!isshow, animated: false)
        self.customBottombar.isHidden = !isshow
        _ = super.prefersStatusBarHidden
    }
    
    func didclickPlayButton(_ sender: UIButton) {
        if !isPlay {
            isPlay = true
            sender.setImage(nil, for: .normal)
            sender.setImage(nil, for: .highlighted)
            showBars(false)
            self.player?.play()
        } else {
            isPlay = false
            sender.setImage(UIImage(named: "icon_preview_video_play"), for: .normal)
            sender.setImage(UIImage(named: "icon_preview_video_play_highlighted"), for: .highlighted)
            showBars(true)
            self.player?.pause()
        }
    }
    
    func clickDoneButton() {
        guard let photoSelectorCtr = navigationController as? PhotoSelectorController else { return }
        guard let model = assetModel else { return }
        photoSelectorCtr.didFinishSelectedVideo(assetModel: model)
    }
    
}
