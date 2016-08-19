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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    

        
        
        
}

