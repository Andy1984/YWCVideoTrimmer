//
//  VideoCuttingView.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 5/28/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCuttingView: UIView, UIScrollViewDelegate {
    
    var themeColor:UIColor = .lightGrayColor()
    var maxLength:NSTimeInterval = 15.0;
    var minLength:NSTimeInterval = 3.0;
    var trackerColor:UIColor = .whiteColor()
    var borderWidth:CGFloat = 15.0;
    var thumbWidth:CGFloat = 10;
    
    //scrollView是整个可以滑动的
    var scrollView:UIScrollView!
    //contentView是包括刻度的
    var contentView:UIView!
    var showsRulerView:Bool = false
    //frameView是不包括刻度的
    var frameView:UIView!
    var asset:AVAsset!
    var widthPerSecond:CGFloat!
    var topBorder:UIView!
    var bottomBorder:UIView!
    var leftOverlayView:UIView!
    var rightOverlayView:UIView!
    var overlayWidth:CGFloat!
    var leftThumbImage: UIImage?
    var rightThumbImage: UIImage?
    var trackerView:UIView!
    
    init(frame: CGRect, asset:AVAsset) {
        super.init(frame: frame)
        self.asset = asset
    }
    
    init(asset: AVAsset) {
        super.init(frame: CGRectZero)
        self.asset = asset
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    func resetSubviews() {
        clipsToBounds = true
        backgroundColor = .blackColor()
        for view in subviews {
            view.performSelector(#selector(removeFromSuperview))
        }
        //整个scrollView
        self.scrollView = UIScrollView(frame: CGRectMake(0,0,self.width,self.height))
        self.addSubview(self.scrollView)
        self.scrollView.delegate = self
        self.scrollView.showsHorizontalScrollIndicator = false
        
        //contentView是scrollView的内容，好像没必要创建
        self.contentView = UIView(frame: CGRectMake(0,0,self.scrollView.width,self.scrollView.height))
        self.scrollView.contentSize = self.contentView.frame.size
        self.scrollView.addSubview(self.contentView)
        
        //不知道为什么要判断是否存在rulerView
        let ratio:CGFloat = self.showsRulerView ? 0.7 : 1.0
        //frameView的frame是不包括2边的thumb的
        let frameViewFrame = CGRectMake(self.thumbWidth, 0, self.contentView.width - 2*self.thumbWidth, self.contentView.height * ratio)
        self.frameView = UIView(frame: frameViewFrame)
        self.frameView.layer.masksToBounds = true
        self.contentView.addSubview(self.frameView)
        
        self.addFrames()
        
        if self.showsRulerView {
            let rulerFrame = CGRectMake(0, self.contentView.height * 0.7, self.contentView.width, self.contentView.height * 0.3)
            let rulerView = RulerView(frame: rulerFrame, widthPerSecond: self.widthPerSecond, themeColor: self.themeColor)
            self.contentView.addSubview(rulerView)
        }
        // add borders
        self.topBorder = UIView()
        self.topBorder.backgroundColor = self.themeColor
        self.addSubview(self.topBorder)
        
        self.bottomBorder = UIView()
        self.bottomBorder.backgroundColor = self.themeColor
        self.addSubview(bottomBorder)
        // width for left and right overlay views
        self.overlayWidth = self.width - CGFloat(self.minLength) * self.widthPerSecond
        // add left overlay view
        let leftOverlayFrame = CGRectMake(self.thumbWidth - self.overlayWidth, 0, self.overlayWidth, self.frameView.height)
        self.leftOverlayView = UIView(frame: leftOverlayFrame)
//        let leftThumbFrame = CGRectMake(self.overlayWidth - self.thumbWidth, 0, self.thumbWidth, self.frameView.height)
        let leftThumbFrame = CGRectMake(self.overlayWidth - self.thumbWidth, 0, self.thumbWidth, self.frameView.height)
        let leftThumbView: ThumbView
        if self.leftThumbImage != nil {
            leftThumbView = ThumbView(frame: leftThumbFrame, thumbImage: self.leftThumbImage!, right: false)
        } else {
            leftThumbView = ThumbView(frame: leftThumbFrame, color: self.themeColor, right: false)
        }
        
        //这里frame应该是瞎写的
        self.trackerView = UIView(frame: CGRectMake(self.thumbWidth, -5, 3 , self.height + 10))
        self.trackerView.backgroundColor = self.trackerColor
        self.trackerView.layer.masksToBounds = true
        self.trackerView.layer.cornerRadius = 2
        self.addSubview(self.trackerView)
        
        leftThumbView.layer.masksToBounds = true
        self.leftOverlayView.addSubview(leftThumbView)
        self.leftOverlayView.userInteractionEnabled = true
        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveLeftOverlayView))
        //加手势的内容不对
        self.leftOverlayView.addGestureRecognizer(leftPanGestureRecognizer)
        //这算蒙板， 但是不应该整个蒙版都是手势
        self.leftOverlayView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        self.addSubview(self.leftOverlayView)
        
        // add right overlay view
        let rightViewFrameX: CGFloat
        if self.frameView.width < self.width {
            rightViewFrameX = CGRectGetMaxX(self.frameView.frame)
        } else {
            rightViewFrameX = self.width - self.thumbWidth
        }
        self.rightOverlayView = UIView(frame: CGRectMake(rightViewFrameX,0,self.overlayWidth,self.frameView.height))
        let rightThumbView:ThumbView
        if self.rightThumbImage != nil {
            rightThumbView = ThumbView(frame: CGRectMake(0, 0, self.thumbWidth, frameView.height), thumbImage: self.rightThumbImage!, right: true)
        } else {
            rightThumbView = ThumbView(frame: CGRectMake(0, 0, self.thumbWidth, frameView.height), color: self.themeColor, right: true)
        }
        rightThumbView.layer.masksToBounds = true
        rightOverlayView.addSubview(rightThumbView)
        rightOverlayView.userInteractionEnabled = true
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveRightOverlayView))
        rightOverlayView.addGestureRecognizer(rightPanGestureRecognizer)
        rightOverlayView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        self.addSubview(rightOverlayView)
        self.updateBorderFrames()
        
        
        
        
        
        
    }
    
    func notifyDelegate() {
        
    }
    
    func moveLeftOverlayView(gesture:UIPanGestureRecognizer) {
        
    }
    
    func moveRightOverlayView(gesture:UIPanGestureRecognizer) {
        
    }
    
    //不断调整border的长度
    func updateBorderFrames() {
        let height = borderWidth
        topBorder.frame = CGRectMake(CGRectGetMaxX(leftOverlayView.frame), 0, CGRectGetMinX(rightOverlayView.frame)-CGRectGetMinX(leftOverlayView.frame), height)
        bottomBorder.frame = CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), CGRectGetHeight(self.frameView.frame)-height, CGRectGetMinX(self.rightOverlayView.frame)-CGRectGetMaxX(self.leftOverlayView.frame), height)
    }
    
    func addFrames() {
        let imageGenerator = AVAssetImageGenerator(asset: self.asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSizeMake(self.frameView.width * ScreenScale, self.frameView.height * ScreenScale)
        
        var picWidth: CGFloat = 0
        var actualTime: CMTime = kCMTimeZero
        
        let halfWayImage: CGImage!
        do {
            //这一步可能throw error
            halfWayImage = try imageGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: &actualTime)
        } catch {
            print(error)
            return;
        }
        
        let videoScreen = UIImage(CGImage: halfWayImage, scale: ScreenScale, orientation: .Up)
        
        
        
        
        let tmp = UIImageView(image: videoScreen)
        tmp.backgroundColor = .whiteColor()
        var rect = tmp.frame
        rect.size.width = videoScreen.size.width
        tmp.frame = rect
        self.frameView.addSubview(tmp)
        picWidth = tmp.width
        
        let duration = self.asset.seconds
        //screenWidth指的是不算thumbWidth的屏幕宽度
        let screenWidth = self.width - 2 * self.thumbWidth
        
        //好像设置了2次frameView的frame， 应该有一次是多余的
        //这个frameViweWidth 就是scrollView的内容的宽度减去2个thumbWidth， 意义和CGFloat(duration/self.maxLength) * screenWidth一样
        let frameViewFrameWidth = CGFloat(duration/self.maxLength) * screenWidth
        self.frameView.frame = CGRectMake(self.thumbWidth, 0, frameViewFrameWidth, self.frameView.height)
        //这里莫名加了个0.5，和30， 先不加吧
        //30好像是瞎猜2个thumb的宽度
        //0.5不知道是干什么的
        //        let contentViewFrameWidth = self.asset.seconds <= self.maxLength + 0.5 ? screenWidth + 30 : frameViewFrameWidth
        //        let contentViewFrameWidth = self.asset.seconds <= self.maxLength ? screenWidth + 2 * self.thumbWidth:frameViewFrameWidth
        let contentViewFrameWidth: CGFloat
        //视频太短
        if self.asset.seconds <= self.maxLength {
            contentViewFrameWidth = screenWidth + 2 * self.thumbWidth
        } else {
            //足够长
            contentViewFrameWidth = frameViewFrameWidth
        }
        self.contentView.frame = CGRectMake(0, 0, contentViewFrameWidth, self.contentView.height)
        
        self.scrollView.contentSize = self.contentView.frame.size
        
        //Int符合含义， CGFloat方便计算
        let minFramesNeeded: CGFloat = ceil(screenWidth/picWidth)
        let actualFramesNeeded:CGFloat = CGFloat(duration/self.maxLength) * minFramesNeeded
        //每个图片表示的时间长度
        let durationPerFrame:CGFloat = ceil(CGFloat(duration)/actualFramesNeeded)
        self.widthPerSecond = frameViewFrameWidth/CGFloat(duration)
        
        var preferredWidth:CGFloat = 0
        var times:[NSValue] = []
        
        var i: CGFloat = 1
        while i < actualFramesNeeded {
            let time = CMTimeMakeWithSeconds(Double(i * durationPerFrame), 600)
            let timeValue = NSValue(CMTime:time)
            times.append(timeValue)
            
            let tmp = UIImageView(image: videoScreen)
            tmp.tag = Int(i)
            
            var currentFrame = tmp.frame
            currentFrame.origin.x = i * picWidth
            currentFrame.size.width = picWidth
            preferredWidth += currentFrame.width
            
            //这啥， 莫名其妙减6
            if i == actualFramesNeeded - 1 {
                currentFrame.size.width -= 6
            }
            
            tmp.frame = currentFrame
            
            //这里好像没必要进入主线程把
            self.frameView.addSubview(tmp)
            
            
            
            i += 1
        }

        i = 0
        imageGenerator.generateCGImagesAsynchronouslyForTimes(times) { (requestedTime, image, actualTime, result, error) in
            switch result {
            case .Succeeded:
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    i += 1
                    let videoScreen = UIImage(CGImage: image!, scale: ScreenScale, orientation: .Up)
                    if let imageView:UIImageView = self.frameView.viewWithTag(Int(i)) as? UIImageView {
                        imageView.image = videoScreen
                    }
                    print(i)
                    
                })
            case .Failed:
                print(error)
            case .Cancelled:
                print("cancle")
            }
        }
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
