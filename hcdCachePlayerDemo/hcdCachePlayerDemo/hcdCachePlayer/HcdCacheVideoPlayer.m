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
//  HcdCachePlayer.m
//  hcdCachePlayerDemo
//
//  Created by polesapp-hcd on 16/7/4.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

#import "HcdCacheVideoPlayer.h"
#import "HcdLoaderURLConnection.h"
#import "NSString+MD5.h"
#import "Masonry.h"

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

NSString *const kHCDPlayerStateChangedNotification    = @"HCDPlayerStateChangedNotification";
NSString *const kHCDPlayerProgressChangedNotification = @"HCDPlayerProgressChangedNotification";
NSString *const kHCDPlayerLoadProgressChangedNotification = @"HCDPlayerLoadProgressChangedNotification";

static NSString *const HCDVideoPlayerItemStatusKeyPath = @"status";
static NSString *const HCDVideoPlayerItemLoadedTimeRangesKeyPath = @"loadedTimeRanges";
static NSString *const HCDVideoPlayerItemPlaybackBufferEmptyKeyPath = @"playbackBufferEmpty";
static NSString *const HCDVideoPlayerItemPlaybackLikelyToKeepUpKeyPath = @"playbackLikelyToKeepUp";

@interface HcdCacheVideoPlayer()<HCDLoaderURLConnectionDelegate, UIGestureRecognizerDelegate>
{
    //用来控制上下菜单view隐藏的timer
    NSTimer * _hiddenTimer;
}

@property (nonatomic, assign) HCDPlayerState state;
@property (nonatomic, assign) CGFloat        loadedProgress;
@property (nonatomic, assign) CGFloat        duration;
@property (nonatomic, assign) CGFloat        current;

@property (nonatomic, strong) AVURLAsset     *videoURLAsset;
@property (nonatomic, strong) AVAsset        *videoAsset;
@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerItem   *currentPlayerItem;
@property (nonatomic, strong) AVPlayerLayer  *currentPlayerLayer;
@property (nonatomic, strong) NSObject       *playbackTimeObserver;
@property (nonatomic, assign) BOOL           isPauseByUser;           //是否被用户暂停
@property (nonatomic, assign) BOOL           isLocalVideo;            //是否播放本地文件
@property (nonatomic, assign) BOOL           isFinishLoad;            //是否下载完毕

@property (nonatomic, weak  ) UIView         *showView;
@property (nonatomic, strong) UIView         *touchView;              //事件响应View
@property (nonatomic, weak  ) UIView         *playerSuperView;        //播放界面的父页面

@property (nonatomic, strong) UIView         *toolView;
@property (nonatomic, strong) UILabel        *currentTimeLbl;
@property (nonatomic, strong) UILabel        *totalTimeLbl;
@property (nonatomic, strong) UIProgressView *videoProgressView;      //缓冲进度条
@property (nonatomic, strong) UISlider       *playSlider;             //滑竿
@property (nonatomic, strong) UIButton       *stopButton;             //播放暂停按钮
@property (nonatomic, strong) UIButton       *screenButton;           //全屏按钮
@property (nonatomic, assign) BOOL           isFullScreen;
@property (nonatomic, strong) UIActivityIndicatorView *actIndicator;  //加载视频时的旋转菊花

@property (nonatomic, strong) HcdLoaderURLConnection *resouerLoader;

@end

@implementation HcdCacheVideoPlayer

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static HcdCacheVideoPlayer *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isPauseByUser = YES;
        _loadedProgress = 0;
        _duration = 0;
        _current  = 0;
        _state = HCDPlayerStateStopped;
        _stopInBackground = YES;
    }
    return self;
}

- (void)playWithVideoUrl:(NSURL *)url showView:(UIView *)showView andSuperView:(UIView *)superView
{
    
    [self.player pause];
    [self releasePlayer];
    self.isPauseByUser = NO;
    self.loadedProgress = 0;
    self.duration = 0;
    self.current  = 0;
    
    _showView = showView;
    _showView.backgroundColor = [UIColor blueColor];
    _playerSuperView = superView;
    
    NSString *str = [url absoluteString];
    //如果是ios  < 7 或者是本地资源，直接播放
    if ([str hasPrefix:@"https"] || [str hasPrefix:@"http"]) {
        
        self.resouerLoader          = [[HcdLoaderURLConnection alloc] init];
        self.resouerLoader.delegate = self;
        NSURL *playUrl              = [self.resouerLoader getSchemeVideoURL:url];
        self.videoURLAsset          = [AVURLAsset URLAssetWithURL:playUrl options:nil];
        [_videoURLAsset.resourceLoader setDelegate:self.resouerLoader queue:dispatch_get_main_queue()];
        self.currentPlayerItem      = [AVPlayerItem playerItemWithAsset:_videoURLAsset];
        
        _isLocalVideo = NO;
    } else {
        self.videoAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:_videoAsset];
        _isLocalVideo = YES;
    }
    
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
    }
    self.currentPlayerLayer       = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.currentPlayerLayer.frame = CGRectMake(0, 44, showView.bounds.size.width, showView.bounds.size.height - 44);
    self.currentPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [showView.layer addSublayer:self.currentPlayerLayer];
    
    [self.currentPlayerItem addObserver:self forKeyPath:HCDVideoPlayerItemStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:HCDVideoPlayerItemLoadedTimeRangesKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:HCDVideoPlayerItemPlaybackBufferEmptyKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:HCDVideoPlayerItemPlaybackLikelyToKeepUpKeyPath options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.currentPlayerItem];
    
    if ([url.scheme isEqualToString:@"file"]) {
        // 如果已经在HCDPlayerStatePlaying，则直接发通知，否则设置状态
        if (self.state == HCDPlayerStatePlaying) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHCDPlayerStateChangedNotification object:nil];
        } else {
            self.state = HCDPlayerStatePlaying;
        }
        
    } else {
        // 如果已经在HCDPlayerStateBuffering，则直接发通知，否则设置状态
        if (self.state == HCDPlayerStateBuffering) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHCDPlayerStateChangedNotification object:nil];
        } else {
            self.state = HCDPlayerStateBuffering;
        }
    }
    
    [self setVideoToolView];
}


- (void)playWithUrl:(NSURL *)url showView:(UIView *)showView andSuperView:(UIView *)superView {
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    NSURL *playUrl = [components URL];
    NSString *md5File = [NSString stringWithFormat:@"%@.mp4", [[playUrl absoluteString] stringToMD5]];
    
    //这里自己写需要保存数据的路径
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *cachePath =  [document stringByAppendingPathComponent:md5File];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        NSURL *localURL = [NSURL fileURLWithPath:cachePath];
        [self playWithVideoUrl:localURL showView:showView andSuperView:superView];
    } else {
        [self playWithVideoUrl:url showView:showView andSuperView:superView];
    }
}

- (void)fullScreen {
    //如果全屏下
    if (_isFullScreen) {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
    [self toolViewOutHidden];
}

- (void)halfScreen {
    
}

- (void)seekToTime:(CGFloat)seconds {
    if (self.state == HCDPlayerStateStopped) {
        return;
    }
    
    seconds = MAX(0, seconds);
    seconds = MIN(seconds, self.duration);
    
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        self.isPauseByUser = NO;
        [self.player play];
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            self.state = HCDPlayerStateBuffering;
            [self.actIndicator startAnimating];
            self.actIndicator.hidden = NO;
//            [[XCHudHelper sharedInstance] showHudOnView:_showView caption:nil image:nil acitivity:YES autoHideTime:0];
        }
        
    }];
}

#pragma mark - observer

- (void)appDidEnterBackground
{
    if (self.stopInBackground) {
        [self pause];
        self.state = HCDPlayerStatePause;
        self.isPauseByUser = NO;
    }
}
- (void)appDidEnterPlayGround
{
    if (!self.isPauseByUser) {
        [self resume];
        self.state = HCDPlayerStatePlaying;
    }
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification
{
//    [self stop];
    //重新播放
    
    self.state = HCDPlayerStateFinish;
    [_stopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"icon_play_hl"] forState:UIControlStateHighlighted];
}

//在监听播放器状态中处理比较准确
- (void)playerItemPlaybackStalled:(NSNotification *)notification
{
    // 这里网络不好的时候，就会进入，不做处理，会在playbackBufferEmpty里面缓存之后重新播放
    NSLog(@"buffing-----buffing");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([HCDVideoPlayerItemStatusKeyPath isEqualToString:keyPath]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            
            _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(toolViewHidden) userInfo:nil repeats:NO];
            [self monitoringPlayback:playerItem];// 给播放器添加计时器
            
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self stop];
        }
        
    } else if ([HCDVideoPlayerItemLoadedTimeRangesKeyPath isEqualToString:keyPath]) {  //监听播放器的下载进度
        
        [self calculateDownloadProgress:playerItem];
        
    } else if ([HCDVideoPlayerItemPlaybackBufferEmptyKeyPath isEqualToString:keyPath]) { //监听播放器在缓冲数据的状态
//        [[XCHudHelper sharedInstance] showHudOnView:_showView caption:nil image:nil acitivity:YES autoHideTime:0];
        [self.actIndicator startAnimating];
        self.actIndicator.hidden = NO;
        if (playerItem.isPlaybackBufferEmpty) {
            self.state = HCDPlayerStateBuffering;
            [self bufferingSomeSecond];
        }
    } else if ([HCDVideoPlayerItemPlaybackLikelyToKeepUpKeyPath isEqualToString:keyPath]) {
        NSLog(@"HCDVideoPlayerItemPlaybackLikelyToKeepUpKeyPath");
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem
{
    
    self.duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
    [self.player play];
    [self updateTotolTime:self.duration];
    [self setPlaySliderValue:self.duration];
    
    __weak __typeof(self)weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        CGFloat current = playerItem.currentTime.value / playerItem.currentTime.timescale;
        [strongSelf updateCurrentTime:current];
        [strongSelf updateVideoSlider:current];
        if (strongSelf.isPauseByUser == NO) {
            strongSelf.state = HCDPlayerStatePlaying;
        }
        
        // 不相等的时候才更新，并发通知，否则seek时会继续跳动
        if (strongSelf.current != current) {
            strongSelf.current = current;
            if (strongSelf.current > strongSelf.duration) {
                strongSelf.duration = strongSelf.current;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kHCDPlayerProgressChangedNotification object:nil];
        }
        
    }];
    
}

- (void)unmonitoringPlayback:(AVPlayerItem *)playerItem {
    if (self.playbackTimeObserver != nil) {
        [self.player removeTimeObserver:self.playbackTimeObserver];
        self.playbackTimeObserver = nil;
    }
}

- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem
{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    self.loadedProgress = timeInterval / totalDuration;
    [self.videoProgressView setProgress:timeInterval / totalDuration animated:YES];
}
- (void)bufferingSomeSecond
{
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    static BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self.player play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
    });
}

- (void)setLoadedProgress:(CGFloat)loadedProgress
{
    if (_loadedProgress == loadedProgress) {
        return;
    }
    
    _loadedProgress = loadedProgress;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHCDPlayerLoadProgressChangedNotification object:nil];
}

- (void)setState:(HCDPlayerState)state
{
    if (state != HCDPlayerStateBuffering) {
//        [[XCHudHelper sharedInstance] hideHud];
        [self.actIndicator stopAnimating];
        self.actIndicator.hidden = YES;
    }
    
    if (_state == state) {
        return;
    }
    
    _state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHCDPlayerStateChangedNotification object:nil];
    
}

#pragma mark - 界面控件初始化

- (UIView *)toolView {
    
    if (!_toolView) {
        _toolView = [[UIView alloc]init];
        _toolView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    }
    return _toolView;
}

- (UIView *)touchView {
    if (!_touchView) {
        _touchView = [[UIView alloc] init];
        _touchView.backgroundColor = [UIColor clearColor];
    }
    return _touchView;
}

- (UILabel *)currentTimeLbl {
    
    if (!_currentTimeLbl) {
        _currentTimeLbl = [[UILabel alloc]init];
        _currentTimeLbl.textColor = [UIColor whiteColor];
        _currentTimeLbl.font = [UIFont systemFontOfSize:10.0];
        _currentTimeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLbl;
}

- (UILabel *)totalTimeLbl {
    
    if (!_totalTimeLbl) {
        _totalTimeLbl = [[UILabel alloc]init];
        _totalTimeLbl.textColor = [UIColor whiteColor];
        _totalTimeLbl.font = [UIFont systemFontOfSize:10.0];
        _totalTimeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLbl;
}

- (UIProgressView *)videoProgressView {
    
    if (!_videoProgressView) {
        _videoProgressView = [[UIProgressView alloc]init];
        _videoProgressView.progressTintColor = [UIColor whiteColor];  //填充部分颜色
        _videoProgressView.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0.18];   // 未填充部分颜色
        _videoProgressView.layer.cornerRadius = 1.5;
        _videoProgressView.layer.masksToBounds = YES;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.5);
        _videoProgressView.transform = transform;
    }
    return _videoProgressView;
}

- (UISlider *)playSlider {
    if (!_playSlider) {
        _playSlider = [[UISlider alloc] init];
        [_playSlider setThumbImage:[UIImage imageNamed:@"icon_progress"] forState:UIControlStateNormal];
        _playSlider.minimumTrackTintColor = [UIColor clearColor];
        _playSlider.maximumTrackTintColor = [UIColor clearColor];
        [_playSlider addTarget:self action:@selector(playSliderChange:) forControlEvents:UIControlEventValueChanged]; //拖动滑竿更新时间
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchUpInside];  //松手,滑块拖动停止
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchCancel];
    }
    
    return _playSlider;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopButton addTarget:self action:@selector(resumeOrPause) forControlEvents:UIControlEventTouchUpInside];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
    }
    return _stopButton;
}

- (UIButton *)screenButton {
    if (!_screenButton) {
        _screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenButton addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
        [_screenButton setImage:[UIImage imageNamed:@"icon_full"] forState:UIControlStateNormal];
        [_screenButton setImage:[UIImage imageNamed:@"icon_full"] forState:UIControlStateHighlighted];
    }
    return _screenButton;
}

- (UIActivityIndicatorView *)actIndicator {
    if (!_actIndicator) {
        _actIndicator = [[UIActivityIndicatorView alloc]init];
    }
    return _actIndicator;
}

#pragma mark - 设置进度条、暂停、全屏等组件

- (void)setVideoToolView {
    
    _showView.userInteractionEnabled = YES;
    
    self.toolView.frame = CGRectMake(0, CGRectGetHeight(_showView.frame) - 44, CGRectGetWidth(_showView.frame), 44);
    [_showView addSubview:self.toolView];
    
    self.currentTimeLbl.frame = CGRectMake(44, 0, 52, 44);
    [self.toolView addSubview:self.currentTimeLbl];
    
    self.totalTimeLbl.frame = CGRectMake(CGRectGetWidth(self.toolView.frame) - 52 - 44, 0, 52, 44);
    [self.toolView addSubview:self.totalTimeLbl];
    
    self.stopButton.frame = CGRectMake(0, 0, 44, 44);
    [self.toolView addSubview:self.stopButton];
    
    self.screenButton.frame = CGRectMake(CGRectGetWidth(self.toolView.frame) - 44, 0, 44, 44);
    [self.toolView addSubview:self.screenButton];
    
    CGFloat playSliderWidth = CGRectGetWidth(self.toolView.frame) - 2 * CGRectGetMaxX(self.currentTimeLbl.frame);
    self.videoProgressView.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLbl.frame), 21, playSliderWidth, 20);
    [self.toolView addSubview:self.videoProgressView];
    
    self.playSlider.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLbl.frame), 0, playSliderWidth, 44);
    [self.toolView addSubview:self.playSlider];
    
    self.actIndicator.frame = CGRectMake((CGRectGetWidth(_showView.frame) - 37) / 2, (CGRectGetHeight(_showView.frame) - 37) / 2, 37, 37);
    [_showView addSubview:self.actIndicator];
    
    self.touchView.frame = CGRectMake(0, 0, CGRectGetWidth(_showView.frame), CGRectGetHeight(_showView.frame) - 44);
    [_showView addSubview:self.touchView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//    tap.numberOfTapsRequired = 2;
//    tap.numberOfTouchesRequired = 1;
    tap.delegate = self;
    [self.touchView addGestureRecognizer:tap];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    //点击一次
    if (tap.numberOfTapsRequired == 1) {
        if (self.toolView.hidden) {
            [self toolViewOutHidden];
        } else {
            [self toolViewHidden];
        }
    } else if(tap.numberOfTapsRequired == 2){
        [self resumeOrPause];
    }
}



#pragma mark - 控制条隐藏

- (void)toolViewHidden {
    self.toolView.hidden = YES;
    if (_isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [_hiddenTimer invalidate];
}

#pragma mark - 控制条退出隐藏

- (void)toolViewOutHidden {
    self.toolView.hidden = NO;
    
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    if (!_hiddenTimer.valid) {
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(toolViewHidden) userInfo:nil repeats:NO];
    }else{
        [_hiddenTimer invalidate];
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(toolViewHidden) userInfo:nil repeats:NO];
    }
}

#pragma mark - 事件响应

//手指结束拖动，播放器从当前点开始播放，开启滑竿的时间走动
- (void)playSliderChangeEnd:(UISlider *)slider
{
    [self seekToTime:slider.value];
    [self updateCurrentTime:slider.value];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
}

//手指正在拖动，播放器继续播放，但是停止滑竿的时间走动
- (void)playSliderChange:(UISlider *)slider
{
    [self updateCurrentTime:slider.value];
}

#pragma mark - 控件拖动
- (void)setPlaySliderValue:(CGFloat)time
{
    _playSlider.minimumValue = 0.0;
    _playSlider.maximumValue = (NSInteger)time;
}

- (void)updateCurrentTime:(CGFloat)time
{
    long videocurrent = ceil(time);
    
    NSString *str = nil;
    if (videocurrent < 3600) {
        str =  [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
    } else {
        str =  [NSString stringWithFormat:@"%02li:%02li:%02li",lround(floor(videocurrent/3600.f)),lround(floor(videocurrent%3600)/60.f),lround(floor(videocurrent/1.f))%60];
    }
    
    self.currentTimeLbl.text = str;
}

- (void)updateTotolTime:(CGFloat)time
{
    long videoLenth = ceil(time);
    NSString *strtotol = nil;
    if (videoLenth < 3600) {
        strtotol =  [NSString stringWithFormat:@"%02li:%02li",lround(floor(videoLenth/60.f)),lround(floor(videoLenth/1.f))%60];
    } else {
        strtotol =  [NSString stringWithFormat:@"%02li:%02li:%02li",lround(floor(videoLenth/3600.f)),lround(floor(videoLenth%3600)/60.f),lround(floor(videoLenth/1.f))%60];
    }
    
    self.totalTimeLbl.text = strtotol;
}


- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.playSlider setValue:currentSecond animated:YES];
}

- (void)resumeOrPause
{
    if (!self.currentPlayerItem) {
        return;
    }
    if (self.state == HCDPlayerStatePlaying) {
        [_stopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_play_hl"] forState:UIControlStateHighlighted];
        [self.player pause];
        self.state = HCDPlayerStatePause;
    } else if (self.state == HCDPlayerStatePause) {
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
        [self.player play];
        self.state = HCDPlayerStatePlaying;
    } else if (self.state == HCDPlayerStateFinish) {
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
        [self seekToTime:0.0];
        self.state = HCDPlayerStatePlaying;
    }
    self.isPauseByUser = YES;
}

- (void)resume
{
    if (!self.currentPlayerItem) {
        return;
    }
    
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
    self.isPauseByUser = NO;
    [self.player play];
}

- (void)pause
{
    if (!self.currentPlayerItem) {
        return;
    }
    [_stopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"icon_play_hl"] forState:UIControlStateHighlighted];
    self.isPauseByUser = YES;
    self.state = HCDPlayerStatePause;
    [self.player pause];
}

- (void)stop
{
    self.isPauseByUser = YES;
    self.loadedProgress = 0;
    self.duration = 0;
    self.current  = 0;
    self.state = HCDPlayerStateStopped;
    [self.player pause];
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHCDPlayerProgressChangedNotification object:nil];
}

- (CGFloat)progress
{
    if (self.duration > 0) {
        return self.current / self.duration;
    }
    
    return 0;
}

#pragma mark - private

- (void)releasePlayer {
    if (!self.currentPlayerItem) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.currentPlayerItem removeObserver:self forKeyPath:HCDVideoPlayerItemStatusKeyPath];
    [self.currentPlayerItem removeObserver:self forKeyPath:HCDVideoPlayerItemLoadedTimeRangesKeyPath];
    [self.currentPlayerItem removeObserver:self forKeyPath:HCDVideoPlayerItemPlaybackBufferEmptyKeyPath];
    [self.currentPlayerItem removeObserver:self forKeyPath:HCDVideoPlayerItemPlaybackLikelyToKeepUpKeyPath];
    [self.player removeTimeObserver:self.playbackTimeObserver];
    self.playbackTimeObserver = nil;
    self.currentPlayerItem = nil;
}

#pragma mark - HCDLoaderURLConnectionDelegate

- (void)didFinishLoadingWithTask:(HcdVideoRequestTask *)task
{
    _isFinishLoad = task.isFinishLoad;
}

//网络中断：-1005
//无网络连接：-1009
//请求超时：-1001
//服务器内部错误：-1004
//找不到服务器：-1003

- (void)didFailLoadingWithTask:(HcdVideoRequestTask *)task withError:(NSInteger )errorCode
{
    NSString *str = nil;
    switch (errorCode) {
        case -1001:
            str = @"请求超时";
            break;
        case -1003:
        case -1004:
            str = @"服务器错误";
            break;
        case -1005:
            str = @"网络中断";
            break;
        case -1009:
            str = @"无网络连接";
            break;
            
        default:
            str = [NSString stringWithFormat:@"%@", @"(_errorCode)"];
            break;
    }
    
    NSLog(@"%@", str);
//    [XCHudHelper showMessage:str];
    
}

#pragma mark - 全屏旋转处理

- (void)toOrientation:(UIInterfaceOrientation)orientation {
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == orientation) {
        return;
    }
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        [self.showView removeFromSuperview];
        [self.playerSuperView addSubview:self.showView];
        __weak HcdCacheVideoPlayer * weakSelf = self;
        [self.showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.playerSuperView).with.offset(60);
            make.left.equalTo(weakSelf.playerSuperView);
            make.right.equalTo(weakSelf.playerSuperView);
            //添加竖屏时的限制, 这条也是固定的, 因为: _videoHeight 是float* 类型, 我可以通过它, 动态改视频播放器的高度;
            make.height.equalTo(@280);
        }];
    } else {
        if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            [self.showView removeFromSuperview];
            [[[UIApplication sharedApplication].delegate window] addSubview:self.showView];
            [self.showView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(kScreenHeight));
                make.height.equalTo(@(kScreenWidth));
                make.center.equalTo([[UIApplication sharedApplication].delegate window]);
            }];
        }
    }
    
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:YES];
    [UIView beginAnimations:nil context:nil];
    //旋转视频播放的view和显示亮度的view
    self.showView.transform = [self getOrientation];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
}

//根据状态条旋转的方向来旋转 avplayerView
-(CGAffineTransform)getOrientation{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationPortrait) {
        [self toPortraitUpdate];
        return CGAffineTransformIdentity;
    }else if (orientation == UIInterfaceOrientationLandscapeLeft){
        [self toLandscapeUpdate];
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation == UIInterfaceOrientationLandscapeRight){
        [self toLandscapeUpdate];
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

-(void)toPortraitUpdate{
    _isFullScreen = NO;
    self.toolView.hidden = YES;
    //处理状态条
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

-(void)toLandscapeUpdate{
    _isFullScreen = YES;
    
    //处理状态条
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (self.toolView.hidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

@end
