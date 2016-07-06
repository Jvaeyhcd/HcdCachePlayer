//
//  HcdPlayerView.m
//  hcdCachePlayerDemo
//
//  Created by polesapp-hcd on 16/7/6.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

#import "HcdPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation HcdPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
