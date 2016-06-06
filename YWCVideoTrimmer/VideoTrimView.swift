//
//  TrimView.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 5/28/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import RxSwift

protocol YWCVideoTrimViewDelegate: class {
    func changePositionOfVideoTrimView(trimView:VideoTrimView, startTime:CGFloat, endTime:CGFloat)
}

class VideoTrimView: UIView, UIScrollViewDelegate {
    
    //必须由外部传值
    var asset:AVAsset!
    var player:AVPlayer?
    
    var leftThumbImage: UIImage?
    var rightThumbImage: UIImage?
    
    //Tracker
    var trackerView:UIView!
    var trackerColor:UIColor = .whiteColor()
    
    
    var extraTriggerScope:CGFloat = 25
    
    //如果使用rulerView， 最右边出现刻度数字不全的情况
    var rightExtend:CGFloat = 100
    
    var themeColor:UIColor = .lightGrayColor()
    var maxLength:NSTimeInterval = 15.0;
    var minLength:NSTimeInterval = 3.0;
    
    var borderWidth:CGFloat = 2.0;
    var thumbWidth:CGFloat = 10;
    
    
    
    
    weak var delegate:YWCVideoTrimViewDelegate?
    //scrollView是整个可以滑动的
    var scrollView:UIScrollView!
    //contentView是包括刻度的
    var contentView:UIView!
    var showsRulerView:Bool = false
    //frameView是不包括刻度的
    var frameView:UIView!
    
    
    var leftDimView:UIView!
    var rightDimView:UIView!
    
    
    var rightThumbView: ThumbView!
    var leftThumbView: ThumbView!
    var leftInvisiblePanView: UIView!
    var rightInvisiblePanView: UIView!
    var widthPerSecond:CGFloat!
    var topBorder:UIView!
    var bottomBorder:UIView!
    
    var overlayWidth:CGFloat!
    //这里的start表示初始
    var leftStartPoint:CGPoint!
    var rightStartPoint:CGPoint!
    
    //应该是NSTimeInterval比较合适
    var startTime:CGFloat = 0
    var endTime:CGFloat = 0
    
    //With tracker
    init(frame:CGRect, player:AVPlayer) {
        super.init(frame: frame)
        self.player = player
        self.asset = player.currentItem?.asset
    }
    
    //Without tracker
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
    
    //UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        notifyDelegate()
    }
    
    let disposeBag = DisposeBag()
    func resetSubviews() {
        
        clipsToBounds = true
        backgroundColor = .blackColor()
        for view in subviews {
            view.performSelector(#selector(removeFromSuperview))
        }
        if leftInvisiblePanView != nil {
            leftInvisiblePanView.removeFromSuperview()
        }
        if rightInvisiblePanView != nil {
            rightInvisiblePanView.removeFromSuperview()
        }
        
        
        //整个scrollView
        scrollView = UIScrollView(frame: CGRectMake(0,0,width,height))
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
        //contentView是scrollView的内容
        contentView = UIView(frame: CGRectMake(0,0,scrollView.width,scrollView.height))
        scrollView.contentSize = contentView.frame.size
        scrollView.addSubview(contentView)
        
        //不知道为什么要判断是否存在rulerView
        let ratio:CGFloat = showsRulerView ? 0.7 : 1.0
        //frameView的frame是不包括2边的thumb的
        let frameViewFrame = CGRectMake(thumbWidth, 0, contentView.width - 2*thumbWidth, contentView.height * ratio)
        frameView = UIView(frame: frameViewFrame)
        frameView.layer.masksToBounds = true
        contentView.addSubview(frameView)
        
        addFrames()
        
        if showsRulerView {
            let rulerFrame = CGRectMake(0, contentView.height * 0.7, contentView.width, contentView.height * 0.3)
            let rulerView = RulerView(frame: rulerFrame, widthPerSecond: widthPerSecond, themeColor: themeColor, leftMargin: self.thumbWidth)
            contentView.addSubview(rulerView)
        }
        // add borders
        topBorder = UIView()
        topBorder.backgroundColor = themeColor
        addSubview(topBorder)
        
        bottomBorder = UIView()
        bottomBorder.backgroundColor = themeColor
        addSubview(bottomBorder)
        // width for left and right overlay views
        overlayWidth = width - CGFloat(minLength) * widthPerSecond
        // add left overlay view
        let leftOverlayFrame = CGRectMake(thumbWidth - overlayWidth, 0, overlayWidth, frameView.height)
        leftDimView = UIView(frame: leftOverlayFrame)
        let leftThumbFrame = CGRectMake(overlayWidth - thumbWidth, 0, thumbWidth, frameView.height)
        
        if leftThumbImage != nil {
            leftThumbView = ThumbView(frame: leftThumbFrame, thumbImage: leftThumbImage!, isRightSide: false)
        } else {
            leftThumbView = ThumbView(frame: leftThumbFrame, color: themeColor, isRightSide: false)
        }
        
        //这里frame应该是瞎写的
        trackerView = UIView(frame: CGRectMake(thumbWidth, borderWidth, 3 , frameViewFrame.height - borderWidth * 2))
        if self.player == nil {
            trackerView.hidden = true
        }
        trackerView.backgroundColor = trackerColor
        trackerView.layer.masksToBounds = true
        trackerView.layer.cornerRadius = 2
        addSubview(trackerView)
        
        leftThumbView.layer.masksToBounds = true
        leftDimView.addSubview(leftThumbView)
        leftDimView.userInteractionEnabled = false
        //这算蒙板， 但是不应该整个蒙版都是手势
        leftDimView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        addSubview(leftDimView)
        
        // add right overlay view
        let rightViewFrameX: CGFloat
        if frameView.width < width {
            rightViewFrameX = CGRectGetMaxX(frameView.frame)
        } else {
            rightViewFrameX = width - thumbWidth
        }
        rightDimView = UIView(frame: CGRectMake(rightViewFrameX,0,overlayWidth,frameView.height))
        
        if rightThumbImage != nil {
            rightThumbView = ThumbView(frame: CGRectMake(0, 0, thumbWidth, frameView.height), thumbImage: rightThumbImage!, isRightSide: true)
        } else {
            rightThumbView = ThumbView(frame: CGRectMake(0, 0, thumbWidth, frameView.height), color: themeColor, isRightSide: true)
        }
        rightThumbView.layer.masksToBounds = true
        rightDimView.addSubview(rightThumbView)
        rightDimView.userInteractionEnabled = false
        rightDimView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        addSubview(rightDimView)
        updateBorderFrames()
        
        
        enlargeTriggerScope(extraTriggerScope)
        realTimeSyncronizeTrackerView()
        
        
        
        
        
        
    }
    
    
    
    func enlargeTriggerScope(scope:CGFloat) {
        leftInvisiblePanView = UIView()
        self.superview!.addSubview(leftInvisiblePanView)
        leftInvisiblePanView.snp_remakeConstraints { (make) in
            make.edges.equalTo(leftThumbView).inset(-scope)
        }
        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveLeftThumbView))
        leftInvisiblePanView!.addGestureRecognizer(leftPanGestureRecognizer)
        
        rightInvisiblePanView = UIView()
        self.superview!.addSubview(rightInvisiblePanView)
        rightInvisiblePanView.snp_remakeConstraints { (make) in
            make.edges.equalTo(rightThumbView).inset(-scope)
        }
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveRightThumbView))
        rightInvisiblePanView!.addGestureRecognizer(rightPanGestureRecognizer)
    }

    
    
    
    func notifyDelegate() {
        let start:CGFloat = CGRectGetMaxX(leftDimView.frame) / widthPerSecond + (scrollView.contentOffset.x - thumbWidth) / widthPerSecond;
        if trackerView.hidden == true &&  start != startTime{
            trackerMoveToTime(start)
        }
        startTime = start
        endTime = CGRectGetMinX(rightDimView.frame) / widthPerSecond + (scrollView.contentOffset.x - thumbWidth) / widthPerSecond;
        delegate?.changePositionOfVideoTrimView(self, startTime: startTime, endTime: endTime)
    }
    
    func trackerMoveToTime(time:CGFloat) {
        trackerView.frame.origin.x = time * widthPerSecond + thumbWidth - scrollView.contentOffset.x
    }
    
    
    func moveLeftThumbView(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            leftStartPoint = gesture.locationInView(self)
        case .Changed:
            let point = gesture.locationInView(self)
            let deltaX = point.x - leftStartPoint.x
            var center = leftDimView.center
            center.x += deltaX
            var newLeftViewMidX = center.x
            
            let maxWidth =  CGRectGetMinX(rightDimView.frame) - (CGFloat(minLength) * widthPerSecond);
            let newLeftViewMinX = newLeftViewMidX - overlayWidth/2
            if newLeftViewMinX < thumbWidth - overlayWidth {
                newLeftViewMidX = thumbWidth - overlayWidth + overlayWidth/2
            } else if newLeftViewMinX + overlayWidth > maxWidth {
                newLeftViewMidX = maxWidth - overlayWidth / 2
            }
            leftDimView.center = CGPointMake(newLeftViewMidX, leftDimView.center.y)
            leftStartPoint = point
            updateBorderFrames()
            notifyDelegate()
        default: break
        }
    }
    
    func moveRightThumbView(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            rightStartPoint = gesture.locationInView(self)
        case .Changed:
            let point = gesture.locationInView(self)
            let deltaX = point.x - rightStartPoint.x
            var center = rightDimView.center
            center.x += deltaX
            var newRightViewMidX = center.x
            
            let minX = CGRectGetMaxX(leftDimView.frame) + CGFloat(minLength) * widthPerSecond
            let maxX = asset.seconds <= maxLength ? CGRectGetMaxX(frameView.frame) : CGRectGetWidth(frame) - thumbWidth
            if (newRightViewMidX - overlayWidth/2 < minX) {
                newRightViewMidX = minX + overlayWidth/2;
            } else if (newRightViewMidX - overlayWidth/2 > maxX) {
                newRightViewMidX = maxX + overlayWidth/2;
            }
            
            rightDimView.center = CGPointMake(newRightViewMidX, rightDimView.center.y)
            rightStartPoint = point
            updateBorderFrames()
            notifyDelegate()
        default:break
        }
    }
    
    //不断调整border的长度
    func updateBorderFrames() {
        let height = borderWidth
        topBorder.frame = CGRectMake(CGRectGetMaxX(leftDimView.frame), 0, CGRectGetMinX(rightDimView.frame)-CGRectGetMaxX(leftDimView.frame), height)
        bottomBorder.frame = CGRectMake(CGRectGetMaxX(leftDimView.frame), CGRectGetHeight(frameView.frame)-height, CGRectGetMinX(rightDimView.frame)-CGRectGetMaxX(leftDimView.frame), height)
    }
    
    func addFrames() {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSizeMake(frameView.width * ScreenScale, frameView.height * ScreenScale)
        
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
        frameView.addSubview(tmp)
        picWidth = tmp.width
        
        let duration = asset.seconds
        //screenWidth指的是不算thumbWidth的屏幕宽度
        let screenWidth = self.width - 2 * thumbWidth
        
        //好像设置了2次frameView的frame， 应该有一次是多余的
        //frameViewFrameWidth， 先计算有几个屏 * 屏的宽度
        let frameViewFrameWidth = CGFloat(duration/maxLength) * screenWidth
        frameView.frame = CGRectMake(thumbWidth, 0, frameViewFrameWidth, frameView.height)
        let contentViewFrameWidth: CGFloat
        //视频太短
        if asset.seconds <= maxLength {
            contentViewFrameWidth = screenWidth + 2 * thumbWidth
        } else {
            //足够长
            contentViewFrameWidth = frameViewFrameWidth + 2 * thumbWidth
        }
        contentView.frame = CGRectMake(0, 0, contentViewFrameWidth, contentView.height)
        
        scrollView.contentSize = contentView.frame.size
        contentView.frame.size.width += rightExtend
        
        //Int符合含义， CGFloat方便计算
        let minFramesNeeded: CGFloat = ceil(screenWidth/picWidth)
        let actualFramesNeeded:CGFloat = CGFloat(duration/maxLength) * minFramesNeeded
        //每个图片表示的时间长度
        let durationPerFrame:CGFloat = ceil(CGFloat(duration)/actualFramesNeeded)
        widthPerSecond = frameViewFrameWidth/CGFloat(duration)
        
        var preferredWidth:CGFloat = 0
        var times:[NSValue] = []
        
        var i: CGFloat = 1
        //这里是算没个imageView的frame
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
            frameView.addSubview(tmp)
            
            
            
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
                })
            case .Failed:
                print(error)
            case .Cancelled:
                print("cancle")
            }
        }
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: TrackerView
    func realTimeSyncronizeTrackerView() {
        observer = self.player?.addPeriodicTimeObserverForInterval(CMTimeMake(1,30), queue: dispatch_get_main_queue(), usingBlock: { [weak self] (time) in
            self!.trackerView.frame.origin.x = CGFloat(CMTimeGetSeconds(time)) * self!.widthPerSecond + self!.thumbWidth - self!.scrollView.contentOffset.x
            if self?.player?.rate == 0 {
                self?.trackerView.hidden = true
            } else {
                self?.trackerView.hidden = false
            }
            
            })
    }
    var observer:AnyObject!//PeriodicTimeObserver
    deinit {
        self.player?.removeTimeObserver(observer)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
