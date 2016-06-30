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
//        for i in 0...6 {
//            let name = "pattern_" + "\(i)" + ".jpg"
//            let image = UIImage(named: name)
//            images.append(image!)
//        }
        
        let black = createImage(UIColor.blackColor(), size: CGSizeMake(750, 750))
        let white = createImage(UIColor.whiteColor(), size: CGSizeMake(750, 750))
        images.append(black)
        images.append(white)
        
        let manager = NSFileManager.defaultManager()
        let imagesPath = NSBundle.mainBundle().pathForResource("AddBackground", ofType: nil)
        let imageNames = try! manager.contentsOfDirectoryAtPath(imagesPath!)
        imageNames.forEach { name in
            let image = UIImage(contentsOfFile: imagesPath! + "/" + name)
            images.append(image!)
        }
        
        let dismissButton = UIButton()
        view.addSubview(dismissButton)
        dismissButton.setImage(UIImage(named: "dismissButton"), forState: .Normal)
        dismissButton.setImage(UIImage(named: "dismissButton"), forState: .Highlighted)
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
        collectionView.registerClass(AddBackgroundCollectionViewCell.self, forCellWithReuseIdentifier: "AddBackgroundCollectionViewCell")
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
        let cell:AddBackgroundCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("AddBackgroundCollectionViewCell", forIndexPath: indexPath) as! AddBackgroundCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        //Just for the white one
        if indexPath.row == 1 {
            cell.grayBorder.hidden = false
        } else {
            cell.grayBorder.hidden = true
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
    //Just for the white one
    var grayBorder:UIView!
    var selectedBorder:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: self.bounds)
        addSubview(imageView)
        
        grayBorder = UIView(frame: self.bounds)
        addSubview(grayBorder)
        grayBorder.layer.borderWidth = 2
        grayBorder.layer.borderColor = UIColor.grayColor().CGColor
        grayBorder.hidden = true
        
        selectedBorder = UIView(frame: self.bounds)
        addSubview(selectedBorder)
        selectedBorder.layer.borderWidth = 2
        selectedBorder.layer.borderColor = UIColor(red: 254.0/255, green: 204.0/255, blue: 82.0/255, alpha: 1.0).CGColor
        selectedBorder.hidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var selected: Bool {
        didSet {
            selectedBorder.hidden = !selected
        }
    }
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                
                let damping:CGFloat = 1
                let scale:CGFloat = 0.9
                let duration:NSTimeInterval = 0.3
                var n:NSTimeInterval = 0
                UIView.animateWithDuration(duration, delay: n * duration, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: .LayoutSubviews, animations: {
                    self.transform = CGAffineTransformMakeScale(scale, scale)
                    n += 1
                    }, completion: { (_) in
                        
                })
                
                UIView.animateWithDuration(duration, delay: n * duration, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: .LayoutSubviews, animations: {
                    self.transform = CGAffineTransformMakeScale(scale+0.05, scale+0.05)
                    n += 1
                    }, completion: { (_) in
                        
                })
                
                UIView.animateWithDuration(duration, delay: n * duration, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: .LayoutSubviews, animations: {
                    self.transform = CGAffineTransformMakeScale(scale, scale)
                    n += 1
                    }, completion: { (_) in
                        
                })
                
                UIView.animateWithDuration(duration, delay: n * duration, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: .LayoutSubviews, animations: {
                    self.transform = CGAffineTransformIdentity
                    n += 1
                    }, completion: { (_) in
                        
                })
            }
            
            
            
            
        }
    }
}
