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
import RxCocoa
import RxSwift

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let path = NSBundle.mainBundle().pathForResource("launchScreen", ofType: "mp4") else {
            print("path is nil")
            return
        }
        let URL = NSURL.fileURLWithPath(path)
        let asset:AVURLAsset = AVURLAsset(URL: URL)
        let trimVC = TrimViewController()
        trimVC.asset = asset
        let navi = UINavigationController(rootViewController: trimVC)
        presentViewController(navi, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func pickVideo(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        let movieType: String = kUTTypeMovie as String
        let vidoeType: String = kUTTypeVideo as String
        picker.mediaTypes = [movieType,vidoeType]
        presentViewController(picker, animated: true, completion: nil)
        picker.rx_didFinishPickingMediaWithInfo
            .subscribe{ [weak self] (event) in
                if let URL = event.element?[UIImagePickerControllerReferenceURL] as? NSURL {
                    let asset = AVURLAsset(URL: URL)
                    let trimVC = TrimViewController()
                    trimVC.asset = asset
                    let navi = UINavigationController(rootViewController: trimVC)
                    picker.dismissViewControllerAnimated(true) {
                        self!.presentViewController(navi, animated: true, completion: nil)
                    }
                }
            }.addDisposableTo(disposeBag)
        
    }
        
        
    @IBAction func realTimeFilter(sender: AnyObject) {
        let vc = RealTimeFilterViewController()
        presentViewController(vc, animated: true, completion: nil)
    }
        
        
        
        
}

