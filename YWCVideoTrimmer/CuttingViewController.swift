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

class CuttingViewController: UIViewController, YWCVideoCuttingDelegate {
    var asset:AVAsset!
    var tempVideoPath = NSTemporaryDirectory() + "tmpMov.mov"
    var startTime:CGFloat = 0
    var endTime:CGFloat = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(back))
        
        guard let URLString = NSBundle.mainBundle().pathForResource("mv", ofType: "mp4") else {
            print("Cannot get video")
            return
        }
        let URL = NSURL(fileURLWithPath: URLString)
        asset = AVURLAsset(URL: URL)
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
        
        
        trimmerView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cut", style: .Plain, target: self, action: #selector(cutVideo))
        
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
        let duration = CMTimeMakeWithSeconds(Float64(endTime), asset.duration.timescale)
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
    
    
    
    func changePositionOfCuttingView(cuttingView: VideoCuttingView, startTime: CGFloat, endTime: CGFloat) {
        
    }
    
    func back() {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
