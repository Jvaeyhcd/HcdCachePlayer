//
//  MainViewController.m
//  hcdCachePlayerDemo
//
//  Created by polesapp-hcd on 16/7/12.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

#import "MainViewController.h"
#import "VideoListViewController.h"
#import "VideoTitleListViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupChildControllers];
    
}

- (void)setupChildControllers {
    VideoListViewController *videoListVC = [[VideoListViewController alloc] init];
    UINavigationController *videoListVCNav = [[UINavigationController alloc] initWithRootViewController:videoListVC];
    videoListVC.view.backgroundColor = [UIColor whiteColor];
    
    VideoTitleListViewController *videoTitleListVC = [[VideoTitleListViewController alloc] init];
    UINavigationController *videoTitleListVCNav = [[UINavigationController alloc] initWithRootViewController:videoTitleListVC];
    videoTitleListVC.view.backgroundColor = [UIColor whiteColor];
    
    [self addChildViewController:videoTitleListVCNav];
    [self addChildViewController:videoListVCNav];
    
    videoListVCNav.tabBarItem.title = @"列表";
    videoListVCNav.tabBarItem.image = [UIImage imageNamed:@"tabbar_discover_highlighted"];
    
    videoTitleListVCNav.tabBarItem.title = @"主页";
    videoTitleListVCNav.tabBarItem.image = [UIImage imageNamed:@"tabbar_home_highlighted"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 关闭设备自动旋转, 然后手动监测设备旋转方向来旋转avplayerView
-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

@end

@implementation UINavigationController (Rotation)

- (BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
@end
