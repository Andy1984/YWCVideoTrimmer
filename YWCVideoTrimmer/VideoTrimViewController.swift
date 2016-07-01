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
import SVProgressHUD
import SnapKit

class VideoTrimViewController: UIViewController, YWCVideoTrimViewDelegate {
    var playerLayerFrame:CGRect!
    var playerScrollViewContentSize:CGSize!
    var asset:AVAsset!
    var tempVideoPath = NSTemporaryDirectory() + "tmpMov.mov"
    var startTime:CGFloat = 0
    var endTime:CGFloat = 0
    var videoPlaybackPosition:CGFloat = 0
    var player:AVPlayer!
    var playButton:UIButton!
    var trimView:VideoTrimView!
    var durationLabel:UILabel!
    var playerScrollView:UIScrollView!
    var playerLayer:CALayer!
    var addBackgroundViewController:AddBackgroundViewController!
    var backgroundLayerImage:UIImage = createImage(UIColor.blackColor(), size: CGSizeMake(750,750))
    enum VideoTrim {
        case OriginalAspectRatio
        case FillSquare
        case CropSquare
    }
    var videoTrimMode: VideoTrim = .CropSquare
    deinit {
        print("deinit")
    }
    
    //隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cut", style: .Plain, target: self, action: #selector(videoOutput))
        self.navigationController?.navigationBar.translucent = false
        
        guard let URLString = NSBundle.mainBundle().pathForResource("mxsf", ofType: "mp4") else {
            print("Cannot get video")
            return
        }
        let URL = NSURL(fileURLWithPath: URLString)
        asset = AVURLAsset(URL: URL)
        
        if asset.width >= asset.height {
            playerLayerFrame = CGRectMake(0, 0, ScreenWidth * asset.width/asset.height, ScreenWidth)
            playerScrollViewContentSize = CGSizeMake(ScreenWidth * asset.width / asset.height, ScreenWidth)
        } else {
            playerLayerFrame = CGRectMake(0, 0, ScreenWidth, ScreenWidth * asset.height / asset.width)
            playerScrollViewContentSize = CGSizeMake(ScreenWidth, ScreenWidth * asset.height / asset.width)
        }
        
        
        newPlayerView(asset)
        
        newTrimView()
        
        newFunctionBar()
        button11Clicked()
        
        addBackgroundViewController = AddBackgroundViewController()
        self.addChildViewController(self.addBackgroundViewController)
        self.view.addSubview(self.addBackgroundViewController.view)
        addBackgroundViewController.dismiss()
        // backgroundImageLayer is strong referenced by the block `didSelectBackground`, so it will not dealloc when `viewDidLoad` finished
        let backgroundImageLayer: CALayer = CALayer()
        addBackgroundViewController.didSelectBackground = { [weak self] image in
            guard self != nil else {
                return
            }
            self!.backgroundLayerImage = image
            backgroundImageLayer.contents =  image.CGImage
            backgroundImageLayer.frame = self!.playerLayer.bounds
            if self!.playerLayer.sublayers?.contains(backgroundImageLayer) == false {
                self!.playerLayer.insertSublayer(backgroundImageLayer, atIndex: 0)
            }
        }
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Clear)
    }
    
    
    
    func newTrimView() {
        let margin: CGFloat = 15
        let x: CGFloat = margin
        let w: CGFloat = ScreenWidth - 2 * margin
        let h: CGFloat = 70
        let y: CGFloat = ScreenWidth + 50 + (ScreenHeight - 44 - ScreenWidth - 50 - h)/2
        let frame = CGRectMake(x, y, w, h)
        trimView = VideoTrimView(frame: frame, player: self.player)
        self.view.addSubview(trimView)
        trimView.trackerColor = .whiteColor()
        if self.asset.seconds > 30 {
            trimView.maxLength = 30
        } else {
            trimView.maxLength = self.asset.seconds
        }
        trimView.extraVerticalScope = 25
        trimView.resetSubviews()
        
        trimView.delegate = self
        
        
        self.endTime = CGFloat(trimView.maxLength)
    }
    
    func newPlayerView(asset:AVAsset) {
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        
        
        playerScrollView = UIScrollView(frame: CGRectMake(0,0,ScreenWidth, ScreenWidth))
        playerScrollView.backgroundColor = .blackColor()
        view.addSubview(playerScrollView)
        playerScrollView.contentSize = playerScrollViewContentSize
        playerScrollView.showsHorizontalScrollIndicator = false
        playerScrollView.showsVerticalScrollIndicator = false
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerLayerFrame
        playerScrollView.layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = UIColor.blackColor().CGColor
        
        playButton = UIButton(frame: CGRectMake(0,0,ScreenWidth,ScreenWidth))
        playButton.userInteractionEnabled = false
        self.view.addSubview(playButton)
        let tap = UITapGestureRecognizer(target: self, action: #selector(playButtonClicked))
        playerScrollView.addGestureRecognizer(tap)
        
        let emptyImage = createImage(UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSizeMake(1, 1))
        playButton.setImage(emptyImage, forState: .Selected)
        playButton.setImage(UIImage(named: "cut_play"), forState: .Normal)
    }
    
    var button11: UIButton!
    var button169: UIButton!
    func newFunctionBar() {
        let functionBar = UIView(frame: CGRectMake(0, ScreenWidth, ScreenWidth, 50))
        view.addSubview(functionBar)
        
        //DurationLabel
        durationLabel = UILabel(frame: CGRectMake(0,0,150,50))
        functionBar.addSubview(durationLabel)
        durationLabel.textColor = .darkGrayColor()
        durationLabel.font = UIFont.systemFontOfSize(14)
        let duration = trimView.maxLength
        durationLabel.text = String(format: "  %.1fs", duration)
        
        //button169
        button169 = UIButton()
        functionBar.addSubview(button169)
        button169.snp_makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.centerY.equalTo(functionBar.snp_centerY)
            make.right.equalTo(functionBar)
        }
        button169.setImage(UIImage(named: "trim_169_selected"), forState: .Selected)
        button169.setImage(UIImage(named: "trim_169_unselected"), forState: .Normal)
        button169.addTarget(self, action: #selector(button169Clicked), forControlEvents: .TouchUpInside)
        
        //button11
        button11 = UIButton()
        functionBar.addSubview(button11)
        button11.snp_makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.centerY.equalTo(functionBar.snp_centerY)
            make.right.equalTo(button169.snp_left)
        }
        button11.setImage(UIImage(named: "trim_11_selected"), forState: .Selected)
        button11.setImage(UIImage(named: "trim_11_unselected"), forState: .Normal)
        button11.addTarget(self, action: #selector(button11Clicked), forControlEvents: .TouchUpInside)
    }
    
    func button11Clicked() {
        button11.selected = true
        button169.selected = false
        self.playerLayer.frame = self.playerLayerFrame
        self.playerScrollView.contentSize = self.playerScrollViewContentSize
        self.videoTrimMode = .CropSquare
    }
    
    func button169Clicked() {
        button169.selected = true
        button11.selected = false
        self.playerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth)
        self.playerScrollView.contentSize = CGSizeMake(ScreenWidth, ScreenWidth)
        self.addBackgroundViewController.present()
        self.videoTrimMode = .FillSquare
    }
    
    func playButtonClicked(){
        playButton.selected = !playButton.selected
        if playButton.selected {
            self.player.pause()
        } else {
            self.player.play()
        }
    }
    
    func deleteTempFile() {
        let URL = NSURL(fileURLWithPath: self.tempVideoPath)
        let fm = NSFileManager.defaultManager()
        if fm.fileExistsAtPath(URL.path!) {
            do {
                try fm.removeItemAtURL(URL)
            } catch {
                print(error)
            }
        } else {
            print("Regular: no file by that name")
        }
    }
    
    enum TrimVideoMethod {
        case Original
        case FillSquare
        case CropSquare
    }
    
    var manager: VideoTrimManager!
    
    func videoOutput(sender: UIBarButtonItem) {
        sender.enabled = false
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            sender.enabled = true
        }
        self.deleteTempFile()
        let progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(refreshProgress), userInfo: nil, repeats: true)
        
        
        let startCMT = CMTimeMake(Int64(self.startTime * 1000000), 1000000)
        let durationCMT = CMTimeMake(Int64((self.endTime - self.startTime) * 1000000), 1000000)
        let timeRange = CMTimeRangeMake(startCMT, durationCMT)
        let completionHandler: ((AVAssetExportSession!) -> Void) = { session in
             dispatch_async(dispatch_get_main_queue(), {
                progressTimer.invalidate()
                SVProgressHUD.dismiss()
                guard let status: AVAssetExportSessionStatus = session.status else {
                    return
                }
                switch status {
                case .Completed:
                    let movieURL = NSURL.fileURLWithPath(self.tempVideoPath)
                    let avvc = AVPlayerViewController()
                    avvc.player = AVPlayer(URL: movieURL)
                    self.presentViewController(avvc, animated: true, completion: nil)
                default:break
                }
            })
        }
        
        switch self.videoTrimMode {
        case .OriginalAspectRatio:
            let manager = VideoTrimManager()
            self.manager = manager
            manager.timeRange = timeRange
            manager.asset = self.asset
            manager.outputURL = NSURL.fileURLWithPath(self.tempVideoPath)
            manager.completionHandler = completionHandler
            manager.unexpectedStatus = { info in
                SVProgressHUD.showErrorWithStatus(info)
            }
            manager.trimOriginalAspectRatio()
            
        case .CropSquare:
            let manager = VideoTrimManager()
            self.manager = manager
            manager.playerScrollView = self.playerScrollView
            manager.timeRange = timeRange
            manager.asset = self.asset
            manager.outputURL = NSURL.fileURLWithPath(self.tempVideoPath)
            manager.completionHandler = completionHandler
            manager.unexpectedStatus = { info in
                SVProgressHUD.showErrorWithStatus(info)
            }
            manager.trimCropSquare()
            
        case .FillSquare:
            let manager = VideoTrimManager()
            self.manager = manager
            manager.timeRange = timeRange
            manager.asset = self.asset
            manager.outputURL = NSURL.fileURLWithPath(self.tempVideoPath)
            manager.completionHandler = completionHandler
            manager.backgroundLayerImage = self.backgroundLayerImage
            manager.unexpectedStatus = { info in
                SVProgressHUD.showErrorWithStatus(info)
            }
            manager.trimFillSquare()
        }
    }
    
    func refreshProgress() {
        guard let p = self.manager.exportSession?.progress else {
            return
        }
        SVProgressHUD.showProgress(p)
    }
    
    func changePositionOfVideoTrimView(trimView: VideoTrimView, startTime: CGFloat, endTime: CGFloat) {
        if startTime != self.startTime {
            self.seekVideoToPosition(startTime)
        }
        self.startTime = startTime
        self.endTime = endTime
        self.player.pause()
        playButton.selected = true
        
        let duration = trimView.endTime - trimView.startTime
        durationLabel.text = String(format: "  %.1fs", duration)
    }
    
    func seekVideoToPosition(position:CGFloat) {
        self.videoPlaybackPosition = position
        let time = CMTimeMakeWithSeconds(Double(self.videoPlaybackPosition), self.player.currentTime().timescale)
        self.player.seekToTime(time, toleranceBefore: CMTimeMakeWithSeconds(1.0, 1), toleranceAfter: CMTimeMakeWithSeconds(1.0, 1))
        
        

    }
    
    func back() {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
