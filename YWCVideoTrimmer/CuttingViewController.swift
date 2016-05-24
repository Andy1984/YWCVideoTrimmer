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
        
        guard let URLString = NSBundle.mainBundle().pathForResource("launchScreen", ofType: "mp4") else {
            print("Cannot get video")
            return
        }
        let URL = NSURL(fileURLWithPath: URLString)
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(URL: URL)
        playerVC.showsPlaybackControls = false
        playerVC.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth)
        view.addSubview(playerVC.view)
        playerVC.player?.play()
        
        
    }
    
    func back() {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
