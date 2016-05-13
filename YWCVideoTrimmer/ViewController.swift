//
//  ViewController.swift
//  YWCVideoTrimmer
//
//  Created by YunYi1118 on 5/12/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit

import MobileCoreServices
import SVProgressHUD
import AVFoundation

import RxCocoa
import RxSwift

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    
    
    
    
    

    @IBAction func pickVideo(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        let movieType: String = kUTTypeMovie as String
        let vidoeType: String = kUTTypeVideo as String
        picker.mediaTypes = [movieType,vidoeType]
        self.presentViewController(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let URL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let asset = AVURLAsset(URL: URL)
        let trimVC = TrimViewController()
        trimVC.asset = asset
        let navi = UINavigationController(rootViewController: trimVC)
        picker.dismissViewControllerAnimated(true) { 
            self.presentViewController(navi, animated: true, completion: nil)
        }
        
        
        
        
    }
    

}

