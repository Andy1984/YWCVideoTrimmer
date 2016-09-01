//
//  AVAsset+YWC.swift
//  YWCVideoTrimmer
//
//  Created by YunYi1118 on 5/19/16.
//  Copyright © 2016 MI. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAsset {
    
    var seconds:Double {
        return CMTimeGetSeconds(self.duration)
    }
    
    var videoTracks:[AVAssetTrack] {
        return tracksWithMediaType(AVMediaTypeVideo)
    }
    
    var firstTrack: AVAssetTrack {
        return videoTracks.first!
    }
    
    var width:CGFloat {
        
        if isPortraitTransform {
            return firstTrack.naturalSize.height
        }
        
        
        
//        if rotationAngle == 0 || rotationAngle == 180 {
//            return firstTrack.naturalSize.width
//        } else if rotationAngle == 270 || rotationAngle == 90 {
//            return firstTrack.naturalSize.height
//        } else {
//            return -1
//        }
        
        
        
        return 0;
    }
    
    var height:CGFloat {
        
        if isPortraitTransform {
            return firstTrack.naturalSize.width
        }
        
//        if rotationAngle == 0 || rotationAngle == 180 {
//            return firstTrack.naturalSize.height
//        } else if rotationAngle == 270 || rotationAngle == 90 {
//            return firstTrack.naturalSize.width
//        } else {
//            return -1
//        }
        return 0;
    }
    
    var fps:Float {
        return videoTracks.last!.nominalFrameRate
    }
    
//    var rotationAngle: Int {
//        let t:CGAffineTransform = firstTrack.preferredTransform
//        var angle = -1
//        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
//            // Portrait
//            angle = 90;
//        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
//            // PortraitUpsideDown
//            angle = 270;
//        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
//            // LandscapeRight
//            angle = 0;
//        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
//            // LandscapeLeft
//            angle = 180;
//        }
//        return angle
//    }
    
//    static let portraitTransform = CGAffineTransformMake(0, 1, -1, 0, 0, 0)
//    static let portraitUpsideDown = CGAffineTransformMake(0, -1, 1, 0, 0, 0)
    
    /// Portrait
    var isPortraitTransform: Bool {
        return CGAffineTransformEqualToTransform(self.preferredTransform, CGAffineTransformMake(1, 0, 0, 1, 0, 0))
    }
    
}