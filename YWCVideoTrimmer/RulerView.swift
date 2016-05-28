//
//  RulerView.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 5/28/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit

class RulerView: UIView {
    
    var widthPerSecond:CGFloat = 25
    var themeColor:UIColor = .lightGrayColor()
    
    init(frame: CGRect, widthPerSecond:CGFloat, themeColor:UIColor) {
        super.init(frame: frame)
        self.widthPerSecond = widthPerSecond
        self.themeColor = themeColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let leftMargin:CGFloat = 10.0
        let topMargin:CGFloat = 0.0
        let height:CGFloat = self.frame.height
        let width:CGFloat = self.frame.width
        let minorTickSpace:CGFloat = self.widthPerSecond
        let multiple:Int = 5
        let majorTickLength:CGFloat = 12.0
        let minorTickLength:CGFloat = 7.0
        
        let baseY:CGFloat = topMargin + height
        let minorY:CGFloat = baseY - minorTickLength
        let majorY:CGFloat = baseY - majorTickLength
        
        var step = 0
        
        var x = leftMargin
        while x <= (leftMargin + width) {
            
            CGContextMoveToPoint(context, x, baseY)
            CGContextSetFillColor(context, CGColorGetComponents(self.themeColor.CGColor))
            if step % multiple == 0 {
                CGContextFillRect(context, CGRectMake(x, majorY, 1.75, majorTickLength))
                let font:UIFont = UIFont.systemFontOfSize(11)
                let textColor:UIColor = self.themeColor
                let stringAttrs = [NSFontAttributeName:font,
                                   NSForegroundColorAttributeName:textColor]
                let minutes: Int = step / 60
                let seconds: Int = step % 60
                let attrStr: NSAttributedString
                if minutes > 0 {
                    attrStr = NSAttributedString(string: String(format: "%ld:%02ld",minutes,seconds), attributes: stringAttrs)
                } else {
                    attrStr = NSAttributedString(string: String(format: ":%02ld",minutes,seconds), attributes: stringAttrs)
                }
                attrStr.drawAtPoint(CGPoint(x: x-7, y: majorY-15))
            } else {
                CGContextFillRect(context, CGRectMake(x, minorY, 1.0, minorTickLength))
            }
            step += 1
            x += minorTickSpace
        }
    }
    
}
