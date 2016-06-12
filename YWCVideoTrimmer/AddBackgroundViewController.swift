//
//  AddBackgroundViewController.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 6/12/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit

class AddBackgroundViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var images:[UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        for i in 0...6 {
            let name = "pattern_" + "\(i)" + ".jpg"
            let image = UIImage(named: name)
            images.append(image!)
        }
        
        let dismissButton = UIButton()
        view.addSubview(dismissButton)
        dismissButton.setImage(UIImage(named: "dismissButton"), forState: .Normal)
        dismissButton.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(44)
        }
        dismissButton.addTarget(self, action: #selector(dismiss), forControlEvents: .TouchUpInside)
        
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(dismissButton.snp_top)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "AddBackgroundCollectionViewCell")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("AddBackgroundCollectionViewCell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor(patternImage: images[indexPath.row])
        return cell
    }
    
    func present() {
        UIView.animateWithDuration(0.25, animations: {
            self.view.frame = CGRectMake(0, ScreenWidth, ScreenWidth, ScreenHeight - ScreenWidth - 44)
        })
    }
    
    func dismiss() {
        UIView.animateWithDuration(0.25) { 
            self.view.frame = CGRectMake(0, ScreenHeight - 44, ScreenWidth, ScreenHeight - ScreenWidth - 44)
        }
    }
    

}

class AddBackgroundCollectionViewCell: UICollectionViewCell {
    var imageView:UIImageView!
}
