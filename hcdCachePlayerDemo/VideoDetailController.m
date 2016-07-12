//
//  ViewController.m
//  hcdCachePlayerDemo
//
//  Created by polesapp-hcd on 16/7/1.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

#import "VideoDetailController.h"
#import "HcdCachePlayer.h"

@interface VideoDetailController ()

@end

@implementation VideoDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"hcdCachePlayerDemo";
    // Do any additional setup after loading the view, typically from a nib.
    
    
    HcdCacheVideoPlayer *play = [HcdCacheVideoPlayer sharedInstance];
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 0.5625)];
    [self.view addSubview:videoView];
    
    [play playWithUrl:[NSURL URLWithString:self.videoUrlStr] showView:videoView andSuperView:self.view];
    
    NSLog(@"%f", [HcdCacheVideoPlayer allVideoCacheSize]);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[HcdCacheVideoPlayer sharedInstance] stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
