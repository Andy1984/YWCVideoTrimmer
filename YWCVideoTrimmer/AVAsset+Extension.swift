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
    
    var width:CGFloat {
        guard let tracks:[AVAssetTrack] = tracksWithMediaType(AVMediaTypeVideo) else {
            print("获取视频width失败,远程视频, 可能会出现成功获取asset, 但是asset.tracks为空数组的情况")
            return ScreenWidth
        }
        guard let track = tracks.first else {
            print("tracks.first == nil")
            return ScreenWidth
        }

        
        if CGAffineTransformEqualToTransform(track.preferredTransform, CGAffineTransformIdentity) {
            return track.naturalSize.width
        } else {
            return track.naturalSize.height
        }
    }
    
    var height:CGFloat {
        guard let tracks:[AVAssetTrack] = tracksWithMediaType(AVMediaTypeVideo) else {
            print("获取视频width失败,远程视频, 可能会出现成功获取asset, 但是asset.tracks为空数组的情况")
            return ScreenWidth
        }
        guard let track = tracks.first else {
            print("tracks.first == nil")
            return ScreenWidth
        }
        
        if CGAffineTransformEqualToTransform(track.preferredTransform, CGAffineTransformIdentity) {
            return track.naturalSize.height
        } else {
            return track.naturalSize.width
        }
    }
    
    var fps:Float {
        guard let videoTracks:[AVAssetTrack] = tracksWithMediaType(AVMediaTypeVideo) else {
            print("cannot get videoTracks")
            return 20
        }
        guard let lastTrack = videoTracks.last else {
            print("lesser than one track")
            return 20
        }
        return lastTrack.nominalFrameRate
    }
    
    var isPortrait:Bool {
        if width > height {
            return false;
        } else {
            return true;
        }
    }
    
    
    
}