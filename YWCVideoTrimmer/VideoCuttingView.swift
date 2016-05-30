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
    var maxLength:CGFloat = 15.0;
    var minLength:CGFloat = 3.0;
    var trackerColor:UIColor = .whiteColor()
    var borderWidth:CGFloat = 1.0;
    var thumbWidth:CGFloat = 10;
    
    var scrollView:UIScrollView = UIScrollView()
    var contentView:UIView = UIView()
    var showsRulerView:Bool = false
    var frameView:UIView = UIView()
    var asset:AVAsset!
    
    init(frame: CGRect, asset:AVAsset) {
        super.init(frame: frame)
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
        
        
    }
    
    func addFrames() {
        let imageGenerator = AVAssetImageGenerator(asset: self.asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSizeMake(self.frameView.width * ScreenScale, self.frameView.height * ScreenScale)
        
        var picWidth: CGFloat = 0
        var actualTime: CMTime = kCMTimeZero
//         halfWayImage: CGImageRef
        do {
            let halfWayImage = try imageGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: &actualTime)
            //这一步可能throw error
            let videoScreen: UIImage = UIImage(CGImage: halfWayImage, scale: ScreenScale, orientation: .Up)
            
            
            
            
            let tmp = UIImageView(image: videoScreen)
            var rect = tmp.frame
            rect.size.width = videoScreen.size.width
            tmp.frame = rect
            self.frameView.addSubview(tmp)
            picWidth = tmp.width
            
        } catch {
            
        }
        
        let duration = self.asset.seconds
        let screenWidth = self.width - 2 * self.thumbWidth
        var actualFramesNeeded = 0
        
    }
    
    
    
    
    
    
    

}
