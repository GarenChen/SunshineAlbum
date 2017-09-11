//
//  VideoPreviewCell.swift
//  SunshineAlbum
//
//  Created by ChenGuangchuan on 2017/9/9.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPreviewCell: UICollectionViewCell, PreviewContentType {
    
    var assetModel: AssetModel? {
        didSet {
            guard let model = assetModel else { return }
            
            SAAssetsManager.shared.fetchAVPlayerItem(asset: model.asset, success: {[weak self] (playerItem) in
                DispatchQueue.main.async { [weak self] in
                    self?.setupPlayerItem(playerItem)
                }
            }, failure: { [weak self] (_) in
                DispatchQueue.main.async { [weak self] in
                    self?.nearestController()?.showAlert(title: "无法播放此视频！",
                                                         massage: nil,
                                                         style: .alert,
                                                         actions: ("确定", nil))
                }
            })
        }
    }
    
    var tapConentToHideBar: ((Bool) -> Void)?
    
    var isPlaying: Bool = false
    
    private lazy var playerView: PlayerView = { [unowned self] in
        let playerView = PlayerView()
        self.addSubview(playerView)
        return playerView
    }()
    
    private var playerItem: AVPlayerItem?
    
    private var player: AVPlayer?
    
    private lazy var playButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon_preview_video_play.png", in: Bundle.currentResourceBundle, compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "icon_preview_video_play_highlighted.png", in: Bundle.currentResourceBundle, compatibleWith: nil), for: .highlighted)
        button.addTarget(self, action: #selector(didclickPlayButton(_:)), for: .touchUpInside)
        self.addSubview(button)
        self.addConstraints([
            NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _ = playerView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.playerItem?.removeObserver(self, forKeyPath: "status")
    }
    
    private func setupPlayerItem(_ playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        player = AVPlayer(playerItem: self.playerItem)
        playerView.player = player
        playerView.frame = self.bounds
    }
    
    func recoverSubview() {
        if isPlaying {
            didclickPlayButton(playButton)
        }
    }
    
    @objc private func endPlaying() {
        didclickPlayButton(playButton)
        playerView.player.currentItem?.seek(to: CMTime(value: 0, timescale: 1))
    }
    
    @objc private func didclickPlayButton(_ sender: UIButton) {
        if !isPlaying {
            isPlaying = true
            sender.setImage(nil, for: .normal)
            sender.setImage(nil, for: .highlighted)
            play()
        } else {
            isPlaying = false
            sender.setImage(UIImage(named: "icon_preview_video_play.png", in: Bundle.currentResourceBundle, compatibleWith: nil), for: .normal)
            sender.setImage(UIImage(named: "icon_preview_video_play_highlighted.png", in: Bundle.currentResourceBundle, compatibleWith: nil), for: .highlighted)
            pause()
        }
        tapConentToHideBar?(isPlaying)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            guard let item = playerItem, item.status == .readyToPlay else {
                return
            }
            _ = playButton
        }
    }
    
    private func play() {
        playerView.player.rate = 1.0
        playerView.player.play()
    }
    
    private func pause() {
        playerView.player.pause()
    }

}
