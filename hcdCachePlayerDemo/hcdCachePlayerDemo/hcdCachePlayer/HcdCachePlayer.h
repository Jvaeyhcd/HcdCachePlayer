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

FOUNDATION_EXPORT const NSString * kHCDPlayerStateChangedNotification;
FOUNDATION_EXPORT const NSString * kHCDPlayerProgressChangedNotification;
FOUNDATION_EXPORT const NSString * kHCDPlayerLoadProgressChangedNotification;

typedef NS_ENUM(NSInteger, HCDPlayerState) {
    HCDPlayerStateBuffering = 1,
    HCDPlayerStatePlaying,
    HCDPlayerStateStopped,
    HCDPlayerStatePause,
};

@interface HcdCachePlayer : NSObject

@property (nonatomic, readonly) HCDPlayerState state;                   //视频Player状态
@property (nonatomic, readonly) CGFloat        loadedProgress;          //缓冲的进度
@property (nonatomic, readonly) CGFloat        duration;                //视频总时间
@property (nonatomic, readonly) CGFloat        current;                 //当前播放时间
@property (nonatomic, readonly) CGFloat        progress;                //播放进度0~1之间
@property (nonatomic, assign  ) BOOL           stopInBackground;        //是否在后台播放，默认YES

+ (instancetype)sharedInstance;
- (void)playWithUrl:(NSString *)url showView:(UIView *)showView;
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

@end
