//
//  TrimViewController.swift
//  YWCVideoTrimmer
//
//  Created by YunYi1118 on 5/12/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit

class TrimViewController: UIViewController, GLKViewDelegate, AVPlayerItemOutputPullDelegate {
    var asset:AVURLAsset!
    var videoPreviewView:GLKView!
    var ciContext:CIContext!
    var eaglContext:EAGLContext!
    lazy var player:AVPlayer = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
    var videoOutput:AVPlayerItemVideoOutput!
//    var videoVisionFrame:CGRect!
    lazy var videoVisualFrame: CGRect = {
        
        
        
        return CGRectZero
        
    }()
    
    func outputMediaDataWillChange(sender: AVPlayerItemOutput) {
    }
    
    func outputSequenceWasFlushed(output: AVPlayerItemOutput) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "export", style: .Plain, target: self, action: #selector(export))
        navigationItem.title = "Preview"
        
        extendedLayoutIncludesOpaqueBars = true
        
        eaglContext = EAGLContext(API: .OpenGLES2)
        let frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.width)
        videoPreviewView = GLKView(frame: frame, context: eaglContext)
        view.addSubview(videoPreviewView)
        videoPreviewView.delegate = self
        videoPreviewView.enableSetNeedsDisplay = false
        videoPreviewView.bindDrawable()
        ciContext = CIContext(EAGLContext: self.eaglContext, options: [kCIContextWorkingColorSpace:NSNull()])
        EAGLContext.setCurrentContext(eaglContext)
        
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
        player.currentItem?.addOutput(videoOutput)
        player.play()
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidRefresh))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func displayLinkDidRefresh(link: CADisplayLink) {
    
        let itemTime = videoOutput.itemTimeForHostTime(CACurrentMediaTime())
        guard itemTime != kCMTimeZero else {
            print("itemTime is zero")
            return
        }
        guard videoOutput.hasNewPixelBufferForItemTime(itemTime) else {
            print(videoOutput)
            print(itemTime)
            return;
        }
        
        
        let pixelBuffer:CVPixelBuffer = videoOutput.copyPixelBufferForItemTime(itemTime, itemTimeForDisplay: nil)!
        let sourceImage:CIImage = CIImage(CVPixelBuffer: pixelBuffer)
        let sourceExtent = sourceImage.extent
        
        
        if eaglContext != EAGLContext.currentContext() {
            if EAGLContext.setCurrentContext(eaglContext) == false {
                print("Refresh eaglContext fail")
            }
        }
        
        
        // clear eagl view to grey
        glClearColor(0.5, 0.5, 0.5, 1.0);
        ciContext.drawImage(sourceImage, inRect: videoPreviewView.bounds, fromRect: sourceExtent)
        videoPreviewView.display()
        
    }
    
    
    //代理方法
    func glkView(view: GLKView, drawInRect rect: CGRect) {
        
        return
        
    }
    
    //隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func back() {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func export() {
        
    }
    
    //销毁
    deinit {
        
    }
}
