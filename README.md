# YWCVideoTrimmer
--
Mimic video trimming of Miaopai. 

### Usage of `VideoTrimView`

```
trimView = VideoTrimView(frame: frame, player: self.player)
self.view.addSubview(trimView)
trimView.trackerColor = .whiteColor()
if self.asset.seconds > 30 {
trimView.maxLength = 30
} else {
trimView.maxLength = self.asset.seconds
}
trimView.extraVerticalScope = 25
trimView.resetSubviews()

trimView.delegate = self
```


### Usage of `VideoTrimManager`
##### Simple trim video with the original aspect ratio
```

let manager = VideoTrimManager()
self.manager = manager
manager.timeRange = timeRange
manager.asset = self.asset
manager.outputURL = NSURL.fileURLWithPath(self.tempVideoPath)
manager.completionHandler = completionHandler
manager.unexpectedStatus = { info in
    SVProgressHUD.showErrorWithStatus(info)
}
manager.trimOriginalAspectRatio()
func refreshProgress() {
    guard let p = self.manager.exportSession?.progress else {
        return
    }
    SVProgressHUD.showProgress(p)
}
```
##### Trim video, and crop the video to a square
```
let manager = VideoTrimManager()
self.manager = manager
manager.playerScrollView = self.playerScrollView
manager.timeRange = timeRange
manager.asset = self.asset
manager.outputURL = NSURL.fileURLWithPath(self.tempVideoPath)
manager.completionHandler = completionHandler
manager.unexpectedStatus = { info in
    SVProgressHUD.showErrorWithStatus(info)
}
manager.trimCropSquare()
```
##### Trim video, and add background to the 16:9 video to make it square
```
let manager = VideoTrimManager()
self.manager = manager
manager.timeRange = timeRange
manager.asset = self.asset
manager.outputURL = NSURL.fileURLWithPath(self.tempVideoPath)
manager.completionHandler = completionHandler
manager.backgroundLayerImage = self.backgroundLayerImage
manager.unexpectedStatus = { info in
    SVProgressHUD.showErrorWithStatus(info)
}
manager.trimFillSquare()
```
##### If you need progress
```
let progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(refreshProgress), userInfo: nil, repeats: true)
func refreshProgress() {
    guard let p = self.manager.exportSession?.progress else {
        return
    }
    SVProgressHUD.showProgress(p)
}
```

