//
//  CuttingViewController.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 5/23/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class CuttingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(back))
        
        guard let URLString = NSBundle.mainBundle().pathForResource("mv", ofType: "mp4") else {
            print("Cannot get video")
            return
        }
        let URL = NSURL(fileURLWithPath: URLString)
        let asset = AVURLAsset(URL: URL)
        let playerVC = AVPlayerViewController()
        let playItem = AVPlayerItem(asset: asset)
        playerVC.player = AVPlayer(playerItem: playItem)
        playerVC.showsPlaybackControls = false
        playerVC.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth)
        view.addSubview(playerVC.view)
        playerVC.player?.play()
        
        
        
        let trimmerView = VideoCuttingView(frame: CGRectZero, asset: asset)
        
        self.view.addSubview(trimmerView)
        trimmerView.frame = CGRectMake(0, 400, 300, 100)
        trimmerView.showsRulerView = true
        trimmerView.trackerColor = .cyanColor()
        trimmerView.resetSubviews()
        
        
        
        
    }
    
    func back() {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
