//
//  ViewController.swift
//  YWCVideoTrimmer
//
//  Created by YunYi1118 on 5/12/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit

import MobileCoreServices
import AVFoundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard let path = NSBundle.mainBundle().pathForResource("launchScreen", ofType: "mp4") else {
//            print("path is nil")
//            return
//        }
//        let URL = NSURL.fileURLWithPath(path)
//        let asset:AVURLAsset = AVURLAsset(URL: URL)
//        let trimVC = TrimViewController()
//        trimVC.asset = asset
//        let navi = UINavigationController(rootViewController: trimVC)
//        presentViewController(navi, animated: true, completion: nil)
        
        let cutVC = VideoTrimViewController()
        let navi = UINavigationController(rootViewController: cutVC)
        self.presentViewController(navi, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func pickVideo(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        let movieType: String = kUTTypeMovie as String
        let vidoeType: String = kUTTypeVideo as String
        picker.mediaTypes = [movieType,vidoeType]
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let URL = info[UIImagePickerControllerMediaURL] as? NSURL {
            let asset = AVURLAsset(URL: URL)
            let trimVC = VideoTrimViewController()
            trimVC.asset = asset
            let navi = UINavigationController(rootViewController: trimVC)
            picker.dismissViewControllerAnimated(true) {
                self.presentViewController(navi, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func realTimeFilter(sender: AnyObject) {
        
        
        
        let vc = RealTimeFilterViewController()
        presentViewController(vc, animated: true, completion: nil)
    }
        
        
        
        
}

