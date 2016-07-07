HcdCachePlayer
----

带缓存的播放器，使用AVPlayer封装开发。

### 简单介绍

HcdCacheVideoPlayer实现了边下边播在线视频，并且能将在线视频缓存在本地，支持左右滑动手势来调整视频播放进度，上下滑动手势调节音量大小，并且支持全屏播放。

### 用法
在需要使用播放器的页面
``` objc
#import "HcdCacheVideoPlayer.h"
```
然后创建一个View用于放置视频即可
``` objc
HcdCacheVideoPlayer *play = [HcdCacheVideoPlayer sharedInstance];
UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 0.5625)];
[self.view addSubview:videoView];

[play playWithUrl:[NSURL URLWithString:@"http://7xsnx0.com2.z0.glb.qiniucdn.com/14651947751451.mp4"] showView:videoView andSuperView:self.view];
```

### TODO

使用AVPlayer封装带缓存的音乐播放器。
