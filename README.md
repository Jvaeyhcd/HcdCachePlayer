# HcdCachePlayer

[![Version](https://img.shields.io/cocoapods/v/HcdCachePlayer.svg?style=flat)](http://cocoapods.org/pods/HcdCachePlayer)
[![License](https://img.shields.io/github/license/Jvaeyhcd/HcdCachePlayer.svg)](http://cocoapods.org/pods/HcdCachePlayer)
[![Platform](https://img.shields.io/cocoapods/p/HcdCachePlayer.svg)](http://cocoapods.org/pods/HcdCachePlayer)
[![Tag](https://img.shields.io/github/tag/Jvaeyhcd/HcdCachePlayer.svg
)](http://cocoapods.org/pods/HcdCachePlayer)
[![Travis CI](https://api.travis-ci.org/Jvaeyhcd/HcdCachePlayer.svg?branch=master)](https://travis-ci.org/Jvaeyhcd/HcdCachePlayer)
[![Author](https://img.shields.io/badge/author-Jvaeyhcd-f07c3d.svg)](http://www.jvaeyhcd.cc)
<!-- [![GitHub stars](https://img.shields.io/github/stars/Jvaeyhcd/HcdCachePlayer.svg?style=social&label=Star&maxAge=2592000)](https://github.com/Jvaeyhcd/HcdCachePlayer) -->

HcdCacheVideoPlayer实现了边下边播在线视频，并且能将在线视频缓存在本地，支持左右滑动手势来调整视频播放进度，上下滑动手势调节音量大小，并且支持全屏播放。此控件使用了[Masonry](https://github.com/SnapKit/Masonry)自动布局来实现全屏播放时的界面布局。

![Demo](https://raw.githubusercontent.com/Jvaeyhcd/HcdCachePlayer/master/screen.gif)

## 特性
* 使用AVPlayer开发，带缓存效果，对于同一个视频不用每次都去请求网络
* 支持横、竖屏切换
* 支持在视频上左右滑动调节播放进度
* 视频右边上下滑动调节音量
* 视频左边上下滑动调节亮度

## 安装

### 原始方法

可以可手动下载解压，然后将hcdCachePlayer文件夹拖入您的项目中，需要使用到MobileCoreServices.framework和AVFoundation.framework这两个库。

### CocoaPods

采用CocoaPods方法安装，在您的Podfile文件中添加
``` bash
pod 'HcdCachePlayer'
```

然后使用如下命令安装
``` bash
pod install --verbose --no-repo-update
```
或者更新
``` bash
pod update --verbose --no-repo-update
```

## 用法
在需要使用播放器的页面
``` objc
#import "HcdCacheVideoPlayer.h"
```
然后创建一个View用于放置视频即可
``` objc
HcdCacheVideoPlayer *play = [HcdCacheVideoPlayer sharedInstance];
UIView *videoView = [[UIView alloc] init];
videoView.frame = CGRectMake(0, 64, kScreenWidth, kScreenWidth * 0.5625);
[self.view addSubview:videoView];

NSURL *url = [NSURL URLWithString:@""];//您要播放的url地址

[play playWithUrl:[NSURL URLWithString:self.videoUrlStr]
         showView:videoView
     andSuperView:self.view
        withCache:YES];
```

## TODO

使用AVPlayer封装带缓存的音乐播放器。
如果您觉得对您有所帮助您可以star一下，如果您在使用过程中发现什么bug欢迎Issues我。

第一次使用Cocoapods制作，所以写了一片文章做了个笔记：
[《CocoaPods的制作过程》](http://www.jvaeyhcd.cc/2016/07/08/CocoaPods%E7%9A%84%E5%88%B6%E4%BD%9C%E8%BF%87%E7%A8%8B/)
