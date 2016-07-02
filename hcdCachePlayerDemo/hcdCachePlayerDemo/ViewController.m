//
//  ViewController.m
//  hcdCachePlayerDemo
//
//  Created by polesapp-hcd on 16/7/1.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

#import "ViewController.h"
#import "HcdAudioPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"hcdCachePlayerDemo";
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton *playSoundBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 80, 40)];
    [playSoundBtn setTitle:@"播放声音" forState:UIControlStateNormal];
    [playSoundBtn addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
    playSoundBtn.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:playSoundBtn];
}

- (void)playSound {
    [HcdAudioPlayer sharedInstance].isRepeat = YES;
    [[HcdAudioPlayer sharedInstance] manageAudioWithUrlPath:@"http://7xsnx0.com2.z0.glb.qiniucdn.com/14649451543248.mp3" playOrPause:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
