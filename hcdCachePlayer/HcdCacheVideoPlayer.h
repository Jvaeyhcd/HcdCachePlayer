//
//  ____    ___   _        ___  _____  ____  ____  ____
// |    \  /   \ | T      /  _]/ ___/ /    T|    \|    \
// |  o  )Y     Y| |     /  [_(   \_ Y  o  ||  o  )  o  )
// |   _/ |  O  || l___ Y    _]\__  T|     ||   _/|   _/
// |  |   |     ||     T|   [_ /  \ ||  _  ||  |  |  |
// |  |   l     !|     ||     T\    ||  |  ||  |  |  |
// l__j    \___/ l_____jl_____j \___jl__j__jl__j  l__j
//
//
//	Powered by Polesapp.com
//
//
//  HcdCachePlayer.h
//  hcdCachePlayerDemo
//
//  Created by polesapp-hcd on 16/7/4.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

FOUNDATION_EXPORT NSString *const kHCDPlayerStateChangedNotification;
FOUNDATION_EXPORT NSString *const kHCDPlayerProgressChangedNotification;
FOUNDATION_EXPORT NSString *const kHCDPlayerLoadProgressChangedNotification;

typedef NS_ENUM(NSInteger, HCDPlayerState) {
    HCDPlayerStateBuffering = 1,    //正在缓存
    HCDPlayerStatePlaying,          //正在播放
    HCDPlayerStateStopped,          //播放结束
    HCDPlayerStatePause,            //暂停播放
    HCDPlayerStateFinish,           //播放完成
};

@interface HcdCacheVideoPlayer : NSObject

@property (nonatomic, readonly) HCDPlayerState state;                   //视频Player状态
@property (nonatomic, readonly) CGFloat        loadedProgress;          //缓冲的进度
@property (nonatomic, readonly) CGFloat        duration;                //视频总时间
@property (nonatomic, readonly) CGFloat        current;                 //当前播放时间
@property (nonatomic, readonly) CGFloat        progress;                //播放进度0~1之间
@property (nonatomic, assign  ) BOOL           stopInBackground;        //是否在后台播放，默认YES

+ (instancetype)sharedInstance;

/**
 *  播放服务器的视频，先判断本地是否有缓存文件，缓存文件名为连接的url经过md5加密后生成的字符串
 *
 *  @param url      视频地址
 *  @param showView 显示的View
 */
- (void)playWithUrl:(NSURL *)url showView:(UIView *)showView andSuperView:(UIView *)superView;

/**
 *  指定到某一事件点开始播放
 *
 *  @param seconds 时间点
 */
- (void)seekToTime:(CGFloat)seconds;

/**
 * 恢复播放
 */
- (void)resume;

/**
 *  暂停播放
 */
- (void)pause;

/**
 *  停止播放
 */
- (void)stop;

/**
 *  全屏
 */
- (void)fullScreen;

/**
 *  半屏幕
 */
- (void)halfScreen;

/**
 *  清除所有本地缓存视频文件
 */
+ (void)clearAllVideoCache;

/**
 *  计算所有视频缓存大小
 *
 *  @return 视频缓存大小
 */
+ (double)allVideoCacheSize;

@end
