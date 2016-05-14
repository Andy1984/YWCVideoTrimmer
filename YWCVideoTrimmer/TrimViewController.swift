//
//  TrimViewController.swift
//  YWCVideoTrimmer
//
//  Created by YunYi1118 on 5/12/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit
import AVFoundation

class TrimViewController: UIViewController {
    var asset:AVURLAsset!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(dismiss))
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func dismiss() -> Void {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        
    }
}
