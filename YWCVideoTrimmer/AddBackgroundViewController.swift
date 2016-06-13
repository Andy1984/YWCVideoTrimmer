//
//  AddBackgroundViewController.swift
//  YWCVideoTrimmer
//
//  Created by YangWeicheng on 6/12/16.
//  Copyright © 2016 MI. All rights reserved.
//

import UIKit

class AddBackgroundViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    var didSelectBackground:(UIImage -> Void) = {_ in }
    var images:[UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bounds = CGRectMake(0 , 0, ScreenWidth, ScreenHeight - ScreenWidth - 44)
        self.view.backgroundColor = UIColor.whiteColor()
        for i in 0...6 {
            let name = "pattern_" + "\(i)" + ".jpg"
            let image = UIImage(named: name)
            images.append(image!)
        }
        
        let dismissButton = UIButton()
        view.addSubview(dismissButton)
        dismissButton.setImage(UIImage(named: "dismissButton"), forState: .Normal)
        dismissButton.setImage(UIImage(named: "dismissButton"), forState: .Normal)
        dismissButton.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(44)
        }
        dismissButton.addTarget(self, action: #selector(dismiss), forControlEvents: .TouchUpInside)
        
        let flowLayout = UICollectionViewFlowLayout()
        let cellLength:CGFloat = 70
        flowLayout.itemSize = CGSizeMake(cellLength,cellLength)
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0)
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.height.equalTo(cellLength)
            make.centerY.equalTo(self.view.snp_centerY).offset(-22)

        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "AddBackgroundCollectionViewCell")
        collectionView.backgroundColor = .clearColor()
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.didSelectBackground(images[indexPath.row])
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("AddBackgroundCollectionViewCell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor(patternImage: images[indexPath.row])
        if indexPath.row == 1 {
            cell.layer.borderColor = UIColor.lightGrayColor().CGColor
            cell.layer.borderWidth = 2
        } else {
            cell.layer.borderWidth = 0
        }
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
