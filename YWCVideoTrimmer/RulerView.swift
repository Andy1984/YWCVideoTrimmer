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
    var leftMargin:CGFloat = 0
    
    init(frame: CGRect, widthPerSecond:CGFloat, themeColor:UIColor, leftMargin:CGFloat) {
        super.init(frame: frame)
        self.widthPerSecond = widthPerSecond
        self.themeColor = themeColor
        self.leftMargin = leftMargin
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let topMargin:CGFloat = 0.0
        let height:CGFloat = self.frame.height
        let width:CGFloat = self.frame.width
        //小格的宽度
        let minorTickSpace:CGFloat = self.widthPerSecond
        //每5个， 一个大针
        let multiple:Int = 5
        //大格的长度
        let majorTickLength:CGFloat = 12.0
        //小格的长度
        let minorTickLength:CGFloat = 7.0
        
        let baseY:CGFloat = topMargin + height
        let minorY:CGFloat = baseY - minorTickLength
        let majorY:CGFloat = baseY - majorTickLength
        
        var step = 0
        
        var x = leftMargin
        while x <= (leftMargin + width) {
            
            CGContextMoveToPoint(context, x, baseY)
            CGContextSetFillColor(context, CGColorGetComponents(self.themeColor.CGColor))
            //如果到了大格
            if step % multiple == 0 {
                //画长线
                CGContextFillRect(context, CGRectMake(x, majorY, 1.75, majorTickLength))
                //画时间文字
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
                    attrStr = NSAttributedString(string: String(format: ":%02ld",seconds), attributes: stringAttrs)
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
