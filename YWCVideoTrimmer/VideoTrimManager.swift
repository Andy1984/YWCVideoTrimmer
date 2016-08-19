//
//  VideoTrimManager.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 6/22/16.
//  Copyright © 2016 MI. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VideoTrimManager {
    
    var asset: AVAsset!
    var timeRange: CMTimeRange!
    var outputURL: NSURL!
    var exportSession: AVAssetExportSession?
    lazy var backgroundLayerImage: UIImage = UIImage(named: "pattern_0.jpg")!
    weak var playerScrollView: UIScrollView?
    var presetName: String = AVAssetExportPresetHighestQuality
    var outputFileType: String = AVFileTypeQuickTimeMovie
    typealias ExportHandler = ((AVAssetExportSession!) -> Void)
    var completionHandler:ExportHandler = { _ in}
    var unexpectedStatus:((String) -> Void) = {info in print(info)}
    
    func trimOriginalAspectRatio() {
        let exportSession = AVAssetExportSession(asset: self.asset, presetName: self.presetName)
        exportSession?.outputURL = outputURL
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
        exportSession?.timeRange = timeRange
        exportSession?.exportAsynchronouslyWithCompletionHandler({
            self.completionHandler(exportSession)
        })
    }
    
    func trimFillSquare() {
        // Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        // 3 - Video track
        // Guard let, because there must be videoTrack, or it is not a video
        guard let videoTrack: AVAssetTrack = self.asset.tracksWithMediaType(AVMediaTypeVideo).first else {
            //            SVProgressHUD.showErrorWithStatus("Get video track error")
            unexpectedStatus("Get video track error")
            print("unexpectedStatus:  " + #file + String(#line))
            return
        }
        let videoCompositionTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoCompositionTrack.insertTimeRange(timeRange, ofTrack: videoTrack, atTime: kCMTimeZero)
        } catch {
            unexpectedStatus("Get videoCompositionTrack error")
            print("unexpectedStatus:  " + #file + String(#line))
            return
        }
        
        // 3.0 - Audio track
        // If let, because there might be no audioTrack
        if let audioTrack = self.asset.tracksWithMediaType(AVMediaTypeAudio).first {
            let audioCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try audioCompositionTrack.insertTimeRange(timeRange, ofTrack: audioTrack, atTime: kCMTimeZero)
            } catch {
                unexpectedStatus("There is audio track, but cannot insert")
                print("unexpectedStatus:  " + #file + String(#line))
                return
            }
        }
        
        // 3.1 - Create AVMutableVideoCompositionInstruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, timeRange.duration)
        
        // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        
        let naturalSize = videoTrack.naturalSize;
        
        var transform: CGAffineTransform!
        // Monkey patch
        if asset.isPortrait == true {
            let scale = naturalSize.height / naturalSize.width;
            transform = CGAffineTransformMakeScale(scale, 1);
        } else {
            let scale = naturalSize.width / naturalSize.height
            transform = CGAffineTransformMakeScale(1, scale)
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
        self.applyVideoEffects(mainCompositionInst, size: naturalSize)
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality) else {
            unexpectedStatus("Create exportSession fail")
            print("unexpectedStatus:  " + #file + String(#line))
            return
        }
        self.exportSession = exportSession
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.videoComposition = mainCompositionInst
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronouslyWithCompletionHandler {
            self.completionHandler(exportSession)
        }
    }
    
    func trimCropSquare() {
        // Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        // 3 - Video track
        // Guard let, because there must be videoTrack, or it is not a video
        guard let videoTrack: AVAssetTrack = self.asset.tracksWithMediaType(AVMediaTypeVideo).first else {
            unexpectedStatus("Get video track error")
            print("unexpectedStatus:  " + #file + String(#line))
            return
        }
        let videoCompositionTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoCompositionTrack.insertTimeRange(timeRange, ofTrack: videoTrack, atTime: kCMTimeZero)
        } catch {
            unexpectedStatus("Get videoCompositionTrack error")
            print("unexpectedStatus:  " + #file + String(#line))
            return
        }
        
        // 3.0 - Audio track
        // If let, because there might be no audioTrack
        if let audioTrack = self.asset.tracksWithMediaType(AVMediaTypeAudio).first {
            let audioCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try audioCompositionTrack.insertTimeRange(timeRange, ofTrack: audioTrack, atTime: kCMTimeZero)
            } catch {
                unexpectedStatus("There is audio track, but cannot insert")
                print("unexpectedStatus:  " + #file + String(#line))
                return
            }
        }
        
        // 3.1 - Create AVMutableVideoCompositionInstruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, timeRange.duration)
        
        // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        var isVideoAssetPortrait = false
//        let videoTransform = videoTrack.preferredTransform
//        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
//            isVideoAssetPortrait = true;
//        }
//        if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
//            isVideoAssetPortrait = true;
//        }
        let naturalSize:CGSize = videoTrack.naturalSize
        if naturalSize.width < naturalSize.height {
            isVideoAssetPortrait = true;
        }
//        var naturalSize:CGSize;
//        if isVideoAssetPortrait == true {
//            naturalSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width)
//        } else {
//            naturalSize = videoTrack.naturalSize
//        }
        var transform: CGAffineTransform!
        guard let playerScrollView = self.playerScrollView else {
            assert(false, "You need to pass a scrollView if you want to crop video to a square")
            return
        }
        let offsetX = playerScrollView.contentOffset.x
        let offsetY = playerScrollView.contentOffset.y
        if isVideoAssetPortrait == true {
            //瞎写的
            let scale = naturalSize.height / naturalSize.width
            transform = CGAffineTransformMakeScale(scale, scale)
            let translationY = -offsetY * naturalSize.height / playerScrollView.frame.size.height
            let translation = CGAffineTransformMakeTranslation(0, translationY)
            transform = CGAffineTransformConcat(transform, translation)
        } else {
            let scale = naturalSize.width / naturalSize.height
            transform = CGAffineTransformMakeScale(scale, scale);
            let translationX = -offsetX * naturalSize.width/playerScrollView.frame.size.width
            let translation = CGAffineTransformMakeTranslation(translationX, 0)
            transform = CGAffineTransformConcat(transform, translation)
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
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality) else {
            unexpectedStatus("Create exportSession fail")
            print("unexpectedStatus:  " + #file + String(#line))
            return
        }
        self.exportSession = exportSession
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.videoComposition = mainCompositionInst
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronouslyWithCompletionHandler {
            self.completionHandler(exportSession)
        }
        
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