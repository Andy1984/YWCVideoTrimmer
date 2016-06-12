//
//  YWCSegmentedControl.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 6/12/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit
import HMSegmentedControl

class YWCSegmentedControl: HMSegmentedControl {

    var current = 0
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        current = self.selectedSegmentIndex
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if current == self.selectedSegmentIndex {
            self.sendActionsForControlEvents(.ValueChanged)
            self.indexChangeBlock?(current)
        }
    }
}
