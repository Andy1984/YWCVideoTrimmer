//
//  VideoTrimManager.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 6/22/16.
//  Copyright © 2016 MI. All rights reserved.
//

import Foundation
import AVFoundation

class VideoTrimManager {
    
    init(startTime: NSTimeInterval, endTime: NSTimeInterval, outputURL: NSURL, exportSession: AVAssetExportSession) {
        self.startTime = startTime
        self.endTime = endTime
        self.outputURL = outputURL
        self.exportSession = exportSession
    }
    
    var startTime: NSTimeInterval
    var endTime: NSTimeInterval
    var outputURL: NSURL
    var exportSession: AVAssetExportSession!
    
    
    
    
    
    
    func trimVideo() {
        
    }
    
    
    
}