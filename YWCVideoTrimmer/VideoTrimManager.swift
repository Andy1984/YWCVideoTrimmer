//
//  VideoTrimManager.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 6/22/16.
//  Copyright © 2016 MI. All rights reserved.
//

import Foundation
import AVFoundation
import SVProgressHUD

class VideoTrimManager {
    
    var asset: AVAsset!
    
    var startTime: NSTimeInterval!
    var endTime: NSTimeInterval!
    
    var outputURL: NSURL!
    var exportSession: AVAssetExportSession?
    lazy var backgroundLayerImage: UIImage = UIImage(named: "pattern_0")!
    weak var playerScrollView: UIScrollView?
    var presetName: String = AVAssetExportPresetHighestQuality
    var outputFileType: String = AVFileTypeQuickTimeMovie
    var exportAsynchronouslyWithCompletionHandler:(() -> Void) = {}
    
    
    
    enum TrimVideoMode {
        case Original
        case FillSquare
        case CropSquare
    }
    
    func trimOriginalAspectRatio() {
        let startCMT = CMTimeMake(Int64(self.startTime * 1000000), 1000000)
        let durationCMT = CMTimeMake(Int64((self.endTime - self.startTime) * 1000000), 1000000)
        let timeRange = CMTimeRangeMake(startCMT, durationCMT)
        
        
        let exportSession = AVAssetExportSession(asset: self.asset, presetName: self.presetName)
        
        exportSession?.outputURL = outputURL
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
        
//        let start = CMTimeMakeWithSeconds(Float64(startTime), asset.duration.timescale)
//        let duration = CMTimeMakeWithSeconds(Float64(endTime - startTime), asset.duration.timescale)
//        let range = CMTimeRangeMake(start, duration)
//        exportSession?.timeRange = range
        
        exportSession?.timeRange = timeRange
        
        //这里应该加个progress
        exportSession?.exportAsynchronouslyWithCompletionHandler({
            let status:AVAssetExportSessionStatus = exportSession!.status
            
            switch status {
            case .Failed:
                print(exportSession!.error)
                SVProgressHUD.showErrorWithStatus(exportSession!.error?.description)
            case .Cancelled:
                print("Cancel")
            case .Completed:
                print("completed")
                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.exportAsynchronouslyWithCompletionHandler()
                })
                
                
            default: "Never enter into status"
            }
            
            
        })
        
    }
    
    func trimFillSquare() {
        
    }
    
    func trimCropSquare() {
        
    }
    
    
    
    
    var trimVideoMode: TrimVideoMode = .Original
    
    func trim() {
        let startCMT = CMTimeMake(Int64(self.startTime * 1000000), 1000000)
        let durationCMT = CMTimeMake(Int64((self.endTime - self.startTime) * 1000000), 1000000)
        let timeRange = CMTimeRangeMake(startCMT, durationCMT)
        
        // Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        // 3 - Video track
        // Guard let, because there must be videoTrack, or it is not a video
        guard let videoTrack: AVAssetTrack = self.asset.tracksWithMediaType(AVMediaTypeVideo).first else {
            SVProgressHUD.showErrorWithStatus("Get video track error")
            return
        }
        let videoCompositionTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoCompositionTrack.insertTimeRange(timeRange, ofTrack: videoTrack, atTime: kCMTimeZero)
        } catch {
            SVProgressHUD.showErrorWithStatus("Get videoCompositionTrack error")
            return
        }
        
        // 3.0 - Audio track
        // If let, because there might be no audioTrack
        if let audioTrack = self.asset.tracksWithMediaType(AVMediaTypeAudio).first {
            let audioCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try audioCompositionTrack.insertTimeRange(timeRange, ofTrack: audioTrack, atTime: kCMTimeZero)
            } catch {
                SVProgressHUD.showErrorWithStatus("There is audio track, but cannot insert")
                return
            }
        }
        
        // 3.1 - Create AVMutableVideoCompositionInstruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, durationCMT)
        
        // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        var isVideoAssetPortrait = false
        let videoTransform = videoTrack.preferredTransform
        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
            isVideoAssetPortrait = true;
        }
        if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
            isVideoAssetPortrait = true;
        }
        
        var naturalSize:CGSize;
        if isVideoAssetPortrait == true {
            naturalSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width)
        } else {
            naturalSize = videoTrack.naturalSize
        }
        var transform: CGAffineTransform!
        if trimVideoMode == .FillSquare {
            // Monkey patch
            if isVideoAssetPortrait == true {
                let scale = naturalSize.height / naturalSize.width
                transform = CGAffineTransformMakeScale(scale, 1)
                transform = CGAffineTransformConcat(videoTrack.preferredTransform, transform)
            } else {
                let scale = naturalSize.width / naturalSize.height
                transform = CGAffineTransformMakeScale(1, scale)
            }
        } else if trimVideoMode == .CropSquare {
            guard let playerScrollView = self.playerScrollView else {
                assert(false, "You need to pass a scrollView if you want to crop video to a square")
                return
            }
            let offsetX = playerScrollView.contentOffset.x
//            let offsetY = playerScrollView.contentOffset.y
            if isVideoAssetPortrait == true {
                //瞎写的
                let scale = naturalSize.height / naturalSize.width
                transform = CGAffineTransformMakeScale(scale, 1)
                transform = CGAffineTransformConcat(videoTrack.preferredTransform, transform)
            } else {
                let scale = naturalSize.width / naturalSize.height
                transform = CGAffineTransformMakeScale(scale, scale);
                let translationX = -offsetX * naturalSize.width/playerScrollView.frame.size.width
                let translation = CGAffineTransformMakeTranslation(translationX, 0)
                transform = CGAffineTransformConcat(transform, translation)
            }
        } else if trimVideoMode == .Original {
            
        }
        
        videoLayerInstruction.setTransform(transform, atTime: kCMTimeZero)
        //opacity不应该是1.0吗
        videoLayerInstruction.setOpacity(0.0, atTime: self.asset.duration)
        
        // 3.3 - Add instructions
        mainInstruction.layerInstructions = [videoLayerInstruction]
        
        let mainCompositionInst = AVMutableVideoComposition()
        let squareLength = max(naturalSize.width, naturalSize.height)
        let squareSize = CGSizeMake(squareLength, squareLength)
        mainCompositionInst.renderSize = squareSize
        mainCompositionInst.instructions = [mainInstruction]
        mainCompositionInst.frameDuration = CMTimeMake(1, 30)
        
        if trimVideoMode == .FillSquare {
            self.applyVideoEffects(mainCompositionInst, size: naturalSize)
        } else if trimVideoMode == .CropSquare {
            
        } else if trimVideoMode == .Original {
            
        }
        
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality) else {
            SVProgressHUD.showErrorWithStatus("Create exportSession fail")
            return
        }
        self.exportSession = exportSession
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.videoComposition = mainCompositionInst
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = mainCompositionInst
        
        
        
        let progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(refreshProgress), userInfo: nil, repeats: true)
        
        
        
        exportSession.exportAsynchronouslyWithCompletionHandler {
            let status:AVAssetExportSessionStatus = exportSession.status
            progressTimer.invalidate()
            switch status {
            case .Failed:
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.showErrorWithStatus(exportSession.error!.description)
                    print(exportSession.error!.description)
                })
            case .Cancelled:
                print("Cancel")
            case .Completed:
                print("completed")
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
//                    let movieURL = NSURL.fileURLWithPath(self.tempVideoPath)
//                    let avvc = AVPlayerViewController()
//                    avvc.player = AVPlayer(URL: movieURL)
//                    self.presentViewController(avvc, animated: true, completion: nil)
                })
            default: "Never enter into status"
            }
        }
    }
    
    @objc func refreshProgress() {
        guard let p = self.exportSession?.progress else {
            return
        }
        SVProgressHUD.showProgress(p, status: "Cutting")
    }
    
    
    
   
    
    func applyVideoEffects(composition:AVMutableVideoComposition, size:CGSize) {
        
        let squareLength = max(size.width, size.height)
        
        let backgroundLayer = CALayer()
        backgroundLayer.contents = self.backgroundLayerImage.CGImage
        backgroundLayer.frame = CGRectMake(0, 0, squareLength, squareLength)
        backgroundLayer.masksToBounds = true
        
        let videoLayer = CALayer()
        let w = size.width
        let h = size.height
        let x = size.width>size.height ? 0 : (squareLength-size.width)/2
        let y = size.width>size.height ? (squareLength-size.height)/2  : 0
        videoLayer.frame = CGRectMake(x, y, w, h)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, squareLength, squareLength)
        parentLayer.addSublayer(backgroundLayer)
        parentLayer.addSublayer(videoLayer)
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
    }
    
    
    
}