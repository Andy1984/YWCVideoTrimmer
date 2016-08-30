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
        return firstTrack.naturalSize.width
    }
    
    var height:CGFloat {
        return firstTrack.naturalSize.height
    }
    
    var fps:Float {
        return videoTracks.last!.nominalFrameRate
    }
    
    var rotationAngle: Int {
        let t:CGAffineTransform = firstTrack.preferredTransform
        var angle = -1
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            angle = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            angle = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            angle = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            angle = 180;
        }
        return angle
    }
    
    
    
}