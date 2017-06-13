<p align="center">
  <img src="http://ww1.sinaimg.cn/large/006tNbRwgy1fgfgm49j1yj30az0b5747.jpg" width="220" height="220"/>
</p>

[![Cbangchen](https://img.shields.io/badge/cbangchen-iOS-yellow.svg)](http://cbangchen.com)
[![Version](https://img.shields.io/cocoapods/v/CBPic2ker.svg?style=flat)](http://cocoapods.org/pods/CBPic2ker)
[![License](https://img.shields.io/cocoapods/l/CBPic2ker.svg?style=flat)](http://cocoapods.org/pods/CBPic2ker)
[![Platform](https://img.shields.io/cocoapods/p/CBPic2ker.svg?style=flat)](http://cocoapods.org/pods/CBPic2ker)

## 效果图

<p align="center">
  <img src="PhotoPickerInteraction.gif" width="600" height="400"/>
</p>

## 特性

- 酷 
- 给你丝滑的美 
- 人脸识别

## 版本要求 

- iOS 8.0

## 安装 

CBPic2ker 已经支持了 [CocoaPods](http://cocoapods.org). 只要在你的 Podfile 文件中添加下面的语句即可：

```ruby
pod "CBPic2ker"
```

不要忘记在 `info.plist` 文件中添加描述：

![](http://ww2.sinaimg.cn/large/006tNbRwgy1fghh98s9wqj31g8024t8u.jpg)

## 使用 

### 声明

```Objective-C
#import "CBPic2ker.h"
```

### 调起

```Objective-C
CBPhotoSelecterController *controller = [[CBPhotoSelecterController alloc] initWithDelegate:self];
controller.columnNumber = 4;
controller.maxSlectedImagesCount = 5;
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
[self presentViewController:nav animated:YES completion:nil];
```

### 代理事件

```Objective-C
- (void)photoSelecterController:(CBPhotoSelecterController *)pickerController sourceAsset:(NSArray *)sourceAsset {
	/...
}
- (void)photoSelecterDidCancelWithController:(CBPhotoSelecterController *)pickerController {
   /...
}
```

## 作者

cbangchen, cbangchen007@gmail.com

## 版权声明©️ 

CBPic2ker is available under the MIT license. See the LICENSE file for more info.
