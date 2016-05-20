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
    var player:AVPlayer!
    var videoOutput:AVPlayerItemVideoOutput!
    var displayLink:CADisplayLink!
//    var videoVisionFrame:CGRect!
//    lazy var videoVisualFrame: CGRect = {
//        let w:CGFloat = CGFloat(self.videoPreviewView.drawableWidth)
//        let h:CGFloat = CGFloat(self.videoPreviewView.drawableHeight)
//        return CGRectMake(0, 0, w, h)
//    }()
    lazy var videoVisualFrame: CGRect = {
        let scale:CGFloat = 2
        if self.asset.width > self.asset.height {
            let w = self.videoPreviewView.width
            let h = w * self.asset.width / self.asset.height
            return CGRectMake(0, 0, w * scale, h * scale)
        } else {
            let h:CGFloat = self.videoPreviewView.height
            let w:CGFloat = h * self.asset.width / self.asset.height
            let x:CGFloat = (self.videoPreviewView.width - w) / 2
            let y:CGFloat = 0.0
            return CGRectMake(x * scale, y, w * scale, h * scale)
        }
        
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "export", style: .Plain, target: self, action: #selector(export))
        navigationItem.title = "Preview"
        
        navigationController?.navigationBar.translucent = false
        
        eaglContext = EAGLContext(API: .OpenGLES2)
        let frame = CGRectMake(0, 0, view.width, view.width)
        videoPreviewView = GLKView(frame: frame, context: eaglContext)
        view.addSubview(videoPreviewView)
        videoPreviewView.delegate = self
        videoPreviewView.enableSetNeedsDisplay = false
        videoPreviewView.bindDrawable()
        ciContext = CIContext(EAGLContext: self.eaglContext, options: [kCIContextWorkingColorSpace:NSNull()])
        EAGLContext.setCurrentContext(eaglContext)
        
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
        videoOutput.setDelegate(self, queue: dispatch_get_main_queue())
        player = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
        player.currentItem?.addOutput(videoOutput)
        player.play()
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidRefresh))
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
        
        //Musts bind, or easy to crash when display
        videoPreviewView.bindDrawable()
        if eaglContext != EAGLContext.currentContext() {
            if EAGLContext.setCurrentContext(eaglContext) == false {
                print("Refresh eaglContext fail")
            }
        }
        
        
        // clear eagl view to grey
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(UInt32(GL_COLOR_BUFFER_BIT));
        // set the blend mode to "source over" so that CI will use that
        glEnable(UInt32(GL_BLEND));
        glBlendFunc(UInt32(GL_ONE), UInt32(GL_ONE_MINUS_SRC_ALPHA));
        ciContext.drawImage(sourceImage, inRect: videoVisualFrame, fromRect: sourceExtent)
        videoPreviewView.display()
        
    }
    
    
    
    //隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func back() {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
        displayLink.invalidate()
    }
    
    func export() {
        
    }
    
    //销毁
    deinit {
        print("xiaohui")
    }
    
    //代理方法
    func glkView(view: GLKView, drawInRect rect: CGRect) {
        
        return
        
    }
    
    func outputMediaDataWillChange(sender: AVPlayerItemOutput) {
    }
    
    func outputSequenceWasFlushed(output: AVPlayerItemOutput) {
    }
}
