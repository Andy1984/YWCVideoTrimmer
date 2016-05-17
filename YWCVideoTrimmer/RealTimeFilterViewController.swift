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
        videoPreviewView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        videoPreviewView.context = eaglContext
        videoPreviewView.enableSetNeedsDisplay = false
        videoPreviewView.transform =  CGAffineTransformMakeRotation(CGFloat(M_PI_2))
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
    

}
