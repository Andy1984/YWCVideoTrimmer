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
import RxCocoa
import RxSwift
import SnapKit
import HMSegmentedControl

class VideoTrimViewController: UIViewController, YWCVideoTrimViewDelegate {
    var asset:AVAsset!
    var tempVideoPath = NSTemporaryDirectory() + "tmpMov.mov"
    var startTime:CGFloat = 0
    var endTime:CGFloat = 0
    var videoPlaybackPosition:CGFloat = 0
    var player:AVPlayer!
    var playButton:UIButton!
    var trimView:VideoTrimView!
    var durationLabel:UILabel!
    
    let disposeBag = DisposeBag()
    
    var playScrollView:UIScrollView!
    var playerLayer:CALayer!
    
    deinit {
        print("销毁")
    }
    
    //隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cut", style: .Plain, target: self, action: #selector(cutVideo))
        self.navigationController?.navigationBar.translucent = false
        
        guard let URLString = NSBundle.mainBundle().pathForResource("mxsf", ofType: "mp4") else {
            print("Cannot get video")
            return
        }
    
        
        
        let URL = NSURL(fileURLWithPath: URLString)
        asset = AVURLAsset(URL: URL)
        player = AVPlayer(URL: URL)
        player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 2), queue: dispatch_get_main_queue()) { (time) in
            let t = CMTimeGetSeconds(time)
            print(t)
        }
        
        playScrollView = UIScrollView(frame: CGRectMake(0,0,ScreenWidth, ScreenWidth))
        view.addSubview(playScrollView)
        playScrollView.contentSize = CGSizeMake(ScreenWidth*asset.width/asset.height, ScreenWidth)
        playScrollView.showsHorizontalScrollIndicator = true
        playScrollView.showsVerticalScrollIndicator = true
        
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRectMake(0, 0, ScreenWidth*asset.width/asset.height, ScreenWidth)
        playScrollView.layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = UIColor.blackColor().CGColor
        
        playButton = UIButton(frame: CGRectMake(0,0,ScreenWidth,ScreenWidth))
        playButton.userInteractionEnabled = false
        self.view.addSubview(playButton)
        let tap = UITapGestureRecognizer(target: self, action: #selector(playButtonClicked))
        playScrollView.addGestureRecognizer(tap)
        
        let emptyImage = createImage(UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSizeMake(1, 1))
        playButton.setImage(emptyImage, forState: .Normal)
        playButton.setImage(UIImage(named: "success@3x"), forState: .Selected)
        trimView = VideoTrimView(frame: CGRectZero, player: self.player)
        self.view.addSubview(trimView)
        trimView.frame = CGRectMake(0, 400, 300, 100)
        trimView.showsRulerView = true
        trimView.trackerColor = .whiteColor()
        trimView.resetSubviews()
        trimView.enlargeTriggerScope(10)
        trimView.delegate = self
        
        
        
        
        newFunctionBar()
        
        

    }
    
    func newFunctionBar() {
        let functionBar = UIView(frame: CGRectMake(0, ScreenWidth, ScreenWidth, 50))
        view.addSubview(functionBar)
        
        //DurationLabel
        durationLabel = UILabel(frame: CGRectMake(0,0,150,50))
        functionBar.addSubview(durationLabel)
        durationLabel.textColor = .darkGrayColor()
        let duration = trimView.endTime - trimView.startTime
        durationLabel.text = String(format: "  %.1fs", duration)
        durationLabel.font = UIFont.systemFontOfSize(14)
        
        
        let videoSizeSegmentedControl = HMSegmentedControl(sectionImages: [UIImage(named: "trim_11_unselected")!,UIImage(named: "trim_169_unselected")!], sectionSelectedImages: [UIImage(named: "trim_11_selected")!,UIImage(named: "trim_169_selected")!])
        functionBar.addSubview(videoSizeSegmentedControl)
        videoSizeSegmentedControl.snp_makeConstraints { (make) in
            make.height.equalTo(50)
            make.centerY.equalTo(functionBar.snp_centerY)
            make.right.equalTo(functionBar.snp_right)
            make.width.equalTo(100)
        }
        videoSizeSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone
        videoSizeSegmentedControl.indexChangeBlock = { [weak self] index in
            if index == 0 {
                self!.playScrollView.contentSize = CGSizeMake(ScreenWidth*self!.asset.width/self!.asset.height, ScreenWidth)
                self!.playerLayer.frame = CGRectMake(0, 0, ScreenWidth*self!.asset.width/self!.asset.height, ScreenWidth)
            } else if index == 1 {
                self!.playScrollView.contentSize = CGSizeMake(ScreenWidth, ScreenWidth)
                self!.playerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth)
            }
            
        }
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
    
    func cutVideo() {
        
        deleteTempFile()
        
        
        let compatiblePresets = AVAssetExportSession.exportPresetsCompatibleWithAsset(self.asset)
        guard compatiblePresets.contains(AVAssetExportPresetMediumQuality) else {
            print("No AVAssetExportPresetMediumQuality")
            return
        }
        let exportSession = AVAssetExportSession(asset: self.asset, presetName: AVAssetExportPresetPassthrough)
        let fileURL = NSURL.fileURLWithPath(self.tempVideoPath)
        
        exportSession?.outputURL = fileURL
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
        
        let start = CMTimeMakeWithSeconds(Float64(startTime), asset.duration.timescale)
        let duration = CMTimeMakeWithSeconds(Float64(endTime - startTime), asset.duration.timescale)
        let range = CMTimeRangeMake(start, duration)
        exportSession?.timeRange = range
        
        let timer = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
        SVProgressHUD.setDefaultMaskType(.Clear)
        let disposable = timer.subscribeNext { _ in
            SVProgressHUD.showProgress(exportSession!.progress, status: "Cutting")
        }
        
        
        //这里应该加个progress
        exportSession?.exportAsynchronouslyWithCompletionHandler({
            let status:AVAssetExportSessionStatus = exportSession!.status
            
            switch status {
            case .Failed:
                print(exportSession!.error)
            case .Cancelled:
                print("Cancel")
            case .Completed:
                print("completed")
                
                dispatch_async(dispatch_get_main_queue(), {
                    disposable.dispose()
                    
                    let movieURL = NSURL.fileURLWithPath(self.tempVideoPath)
                    let s = NSSelectorFromString("video:didFinishSavingWithError:contextInfo:")
                    
                    SVProgressHUD.showWithStatus("Saving...")
                    UISaveVideoAtPathToSavedPhotosAlbum(movieURL.relativePath!, self, s, nil)
                })
                
                
                
                
            default: "Never enter into status"
            }
            
            
        })
    }
    
    func video(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: UnsafeMutablePointer<Void>) {
        
        let e:NSError? = error
        if e == nil {
            SVProgressHUD.showSuccessWithStatus("Success")
        } else {
            SVProgressHUD.showErrorWithStatus(e!.description)
        }
        
        
        
        
    }
    
    func changePositionOfVideoTrimView(trimView: VideoTrimView, startTime: CGFloat, endTime: CGFloat) {
        if startTime != self.startTime {
            self.seekVideoToPosition(startTime)
        }
        self.startTime = startTime
        self.endTime = endTime
        self.player.pause()
        playButton.selected = true

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
