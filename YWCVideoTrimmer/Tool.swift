//
//  Define.swift
//  YWCVideoTrimmer
//
//  Created by YunYi1118 on 5/14/16.
//  Copyright © 2016 MI. All rights reserved.
//

import Foundation
import UIKit

/// 屏幕的宽度
let ScreenWidth = UIScreen.mainScreen().bounds.size.width
/// 屏幕的高度
let ScreenHeight = UIScreen.mainScreen().bounds.size.height
/// WINDOW
let Window = UIApplication.sharedApplication().delegate!.window
let ScreenScale = UIScreen.mainScreen().scale

func createImage(color:UIColor!, size:CGSize!) -> UIImage {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    let context:CGContextRef = UIGraphicsGetCurrentContext()!
    CGContextSetFillColor(context, CGColorGetComponents(color.CGColor))
    CGContextFillRect(context, rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
    
}