//
//  RealTimeFilterViewController.swift
//  YWCVideoTrimmer
//
//  Created by YunYi1118 on 5/17/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit
import GLKit
import CoreImage
import OpenGLES
import AVFoundation


class RealTimeFilterViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var eaglContext:EAGLContext!
    var videoPreviewView:GLKView!
    var videoPreviewViewBounds = CGRectZero
    var ciContext:CIContext!
    var videoDevice:AVCaptureDevice!
    var captureSession:AVCaptureSession!
    let captureSessionQueue:dispatch_queue_t = dispatch_queue_create("capture_session_queue", nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
        eaglContext = EAGLContext(API: .OpenGLES2)
        videoPreviewView = GLKView()
        videoPreviewView.context = eaglContext
        videoPreviewView.enableSetNeedsDisplay = false
        videoPreviewView.transform =  CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        videoPreviewView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        view.addSubview(videoPreviewView)
        videoPreviewView.bindDrawable()
        videoPreviewViewBounds.size.width = CGFloat(videoPreviewView.drawableWidth)
        videoPreviewViewBounds.size.height = CGFloat(videoPreviewView.drawableHeight)
        ciContext = CIContext(EAGLContext: self.eaglContext, options: [kCIContextWorkingColorSpace:NSNull()])
        guard AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 else {
            print("No device with AVMediaTypeVideo")
            return
        }
        start()
    }
    
    func start() {
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        let position:AVCaptureDevicePosition = .Back
        for device in videoDevices {
            if let d = device as? AVCaptureDevice {
                if d.position == position {
                    videoDevice = d
                    print(videoDevice)
                    break
                }
            } else {
                print("Wrong device type")
            }
        }
        let videoDeviceInput:AVCaptureDeviceInput?
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("videoDevice input is wrong")
            return
        }
        
        
        let preset = AVCaptureSessionPresetHigh
        guard videoDevice.supportsAVCaptureSessionPreset(preset) else {
            print("Capture session preset not supported by video device: \(preset)")
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = preset
        
        let pixelFormatTypeKey = kCVPixelBufferPixelFormatTypeKey as String
        let pixelFormatTypeValue = NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)
        let outputSettings = [pixelFormatTypeKey:pixelFormatTypeValue]
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = outputSettings;
        
        videoDataOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.beginConfiguration()
        
        guard captureSession.canAddOutput(videoDataOutput) else {
            captureSession = nil
            print("Cannot add video data output")
            return;
        }
        
        captureSession.addInput(videoDeviceInput)
        captureSession.addOutput(videoDataOutput)
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        
    }
    
    //AVCaptureVideoDataOutputSampleBufferDelegate method
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("imageBuffer does not exist")
            return;
        }
        let sourceImage = CIImage(CVImageBuffer: imageBuffer, options: nil)
        let sourceExtent = sourceImage.extent
        
        // MARK: Add two filters
        // Image processing
        guard let vignetteFilter = CIFilter(name: "CIVignetteEffect") else {
            print("vignetteFilter == nil")
            return;
        }
        vignetteFilter.setValue(sourceImage, forKey: kCIInputImageKey)
        let extentSize = sourceExtent.size
        let vector = CIVector(x: extentSize.width/2, y: extentSize.height/2)
        vignetteFilter.setValue(vector, forKey: kCIInputCenterKey)
        vignetteFilter.setValue(extentSize.width/2, forKey: kCIInputRadiusKey)
        
        guard var filteredImage = vignetteFilter.outputImage else {
            print("filteredImage == nil")
            return
        }
        guard let effectFilter = CIFilter(name: "CIPhotoEffectInstant") else {
            print("effectFilter == nil")
            return;
        }
        effectFilter.setValue(filteredImage, forKey: kCIInputImageKey)
        
        
        filteredImage = effectFilter.outputImage!
        
        
//        filteredImage = (effectFilter?.outputImage)!
//        guard filteredImage = effectFilter.outputImage! else {
//            
//        }
        
        
        
        // MARK: Finally, display the new image by videoPreviewView:
        let sourceAspect = extentSize.width/extentSize.height
        let previewAspect = videoPreviewViewBounds.size.width/videoPreviewViewBounds.size.height
        // we want to maintain the aspect radio of the screen size, so we clip the video image
        var drawRect = sourceExtent
        if sourceAspect > previewAspect {
            // use full height of the video image, and center crop the width
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
            drawRect.size.width = drawRect.size.height * previewAspect;
        } else {
            // use full width of the video image, and center crop the height
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
            drawRect.size.height = drawRect.size.width / previewAspect;
        }
        //Why twice
        videoPreviewView.bindDrawable()
        
        if eaglContext != EAGLContext.currentContext() {
            if EAGLContext.setCurrentContext(eaglContext) == false {
                print("Refresh eaglContext fail")
            }
        }
        
        // clear eagl view to grey
        glClearColor(0.5, 0.5, 0.5, 1.0);
        glClear(UInt32(GL_COLOR_BUFFER_BIT));
        // set the blend mode to "source over" so that CI will use that
        glEnable(UInt32(GL_BLEND));
        glBlendFunc(UInt32(GL_ONE), UInt32(GL_ONE_MINUS_SRC_ALPHA));
        
        ciContext.drawImage(filteredImage, inRect: videoPreviewViewBounds, fromRect: drawRect)
        
        videoPreviewView.display()
        
        
        
        
        
        
        
    }
    

}
