//
//  ThumbView.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 5/28/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit

class ThumbView: UIView {
    
    var right:Bool?
    var thumbImage:UIImage?
    
    var color:UIColor?
    init(frame:CGRect, color:UIColor, right:Bool) {
        super.init(frame: frame)
        self.color = color
        self.right = right
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
    override func drawRect(rect: CGRect) {
        
        guard self.thumbImage != nil else {
            self.thumbImage!.drawInRect(rect)
            return
        }
        self.drawRoundedRectangle()
        self.drawOrnament()
    }
    
    func drawOrnament() {
        let rect = CGRectMake(CGRectGetWidth(self.bounds)/2.5, CGRectGetMinY(self.bounds)+CGRectGetHeight(self.bounds)/4, 1.5, CGRectGetHeight(self.bounds)/2)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSizeMake(1, 1))
        path.closePath()
        UIColor(white: 1, alpha: 0.5).setFill()
        path.fill()
    }
    
    func drawRoundedRectangle() {
        let roundedRectanglePath:UIBezierPath!
        if right == false {
            roundedRectanglePath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.BottomLeft], cornerRadii: CGSizeMake(3, 3))
        } else {
            roundedRectanglePath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.TopRight, UIRectCorner.BottomRight], cornerRadii: CGSizeMake(3, 3))
        }
        roundedRectanglePath.closePath()
        self.color?.setFill()
        roundedRectanglePath.fill()
    }
    
    
    

}
