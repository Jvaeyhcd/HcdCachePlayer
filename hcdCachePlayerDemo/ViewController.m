//
//  ViewController.m
//  hcdCachePlayerDemo
//
//  Created by polesapp-hcd on 16/7/1.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

#import "ViewController.h"
#import "HcdCachePlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"hcdCachePlayerDemo";
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton *playSoundBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 450, 80, 40)];
    [playSoundBtn setTitle:@"播放声音" forState:UIControlStateNormal];
    [playSoundBtn addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
    playSoundBtn.backgroundColor = [UIColor greenColor];
    playSoundBtn.hidden = YES;
    
    HcdCacheVideoPlayer *play = [HcdCacheVideoPlayer sharedInstance];
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 0.5625)];
    [self.view addSubview:videoView];
    
    [play playWithUrl:[NSURL URLWithString:@"http://baobab.wdjcdn.com/14564977406580.mp4"] showView:videoView andSuperView:self.view];
    
    NSLog(@"%f", [HcdCacheVideoPlayer allVideoCacheSize]);
    
    [self.view addSubview:playSoundBtn];
}

- (void)playSound {
    [HcdAudioPlayer sharedInstance].isRepeat = YES;
    [[HcdAudioPlayer sharedInstance] manageAudioWithUrlPath:@"http://7xsnx0.com2.z0.glb.qiniucdn.com/14649451543248.mp3" playOrPause:YES];
}

#pragma mark - 关闭设备自动旋转, 然后手动监测设备旋转方向来旋转avplayerView
-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{

    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
