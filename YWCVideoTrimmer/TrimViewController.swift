//
//  TrimViewController.swift
//  YWCVideoTrimmer
//
//  Created by YunYi1118 on 5/12/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit

class TrimViewController: UIViewController, GLKViewDelegate {
    var asset:AVURLAsset!
    let glkView:GLKView! = GLKView()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "export", style: .Plain, target: self, action: #selector(export))
        navigationItem.title = "Preview"
        
        glkView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.width)
        view.addSubview(glkView)
        glkView.delegate = self
        
        
    }
    
    //代理方法
    func glkView(view: GLKView, drawInRect rect: CGRect) {
        
    }
    
    //隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func back() {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func export() {
        
    }
    
    //销毁
    deinit {
        
    }
}
