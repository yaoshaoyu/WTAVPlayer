//
//  WTAVPlayerView.m
//  WTAVPlayerView
//
//  Created by 吕成翘 on 2017/9/11.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTAVPlayerView.h"
#import "WTAVPlayerContorlView.h"
#import "WTAVPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"


@interface WTAVPlayerView ()<WTAVPlayerContorlViewDelegate>

@property (nonatomic, strong) AVURLAsset *urlAsset;                                // 视频连接资源
@property (nonatomic, strong) AVPlayerItem *playerItem;                            // 播放器项目
@property (nonatomic, strong) AVPlayer *player;                                    // 播放器
@property (nonatomic, strong) AVPlayerLayer *playerLayer;                          // 播放器展示层
@property (nonatomic, assign) WTAVPlayerViewState state;                           // 状态
@property (nonatomic, strong) WTAVPlayerContorlView *playerContorlView;            // 播放器控制视图
@property (nonatomic, strong) id timeObserverToken;                                // 播放时间观察者
@property (nonatomic, assign) BOOL isDragged;                                      // 是否正在拖动
@property (nonatomic, strong) CMMotionManager *motionManager;                      // 加速计传感器
@property (nonatomic, strong) MPVolumeView *volumeView;                            // 音量视图
@property (nonatomic, strong) UISlider *volumeViewSlider;                          // 音量滑竿
@property (nonatomic, strong) AFNetworkReachabilityManager *networkManager;        // 网络管理者
@property (nonatomic, assign) AFNetworkReachabilityStatus currentNetworkStatus;    // 当前网络状态

@end


@implementation WTAVPlayerView {
    CGRect _smallScreenFrame;                                     // 小屏尺寸
    CGRect _fullScreenFrame;                                      // 大屏尺寸
    CGFloat _startValue;                                          // 开始触摸的值
    CGFloat _startPlayTime;                                       // 开始触摸的时间
    CGFloat _destinationTime;                                     // 滑动到的目标时间
    WTAVPlayerContorlViewTouchPositionType _touchPositionType;    // 触摸点的位置
    WTAVPlayerContorlViewPanDirection _panDirection;              // 滑动的方向
    CMTime _lastPlaybackTime;                                     // 最后一次播放到的时间点
    BOOL _isCell;                                                 // 是否在cell上
    UIView *_lastSuperView;                                       // 最后所在的父视图
    BOOL _isShowKeyboard;                                         // 是否显示键盘
    UIInterfaceOrientation _lastInterfaceOrientation;             // 最后状态栏的方向
    BOOL _isEnterBackground;                                      // 是否进入后台
    BOOL _isHorizontalVideo;                                      // 是否是横屏视频
}

#pragma mark - LifeCycle
- (void)layoutSubviews {
    [super layoutSubviews];
    
    _playerLayer.frame = self.bounds;
    
    if (CGRectIsEmpty(_smallScreenFrame)) {
        _smallScreenFrame = self.frame;
    }
}

- (void)dealloc {
    
    [_networkManager stopMonitoring];
    [_motionManager stopAccelerometerUpdates];
    [self removeNotification];
    [self removeObserver];
}

#pragma mark - CustomAccessors
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initialization];
        [self setupUI];
        [self setupNetworkReachabilityManager];
    }
    
    return self;
}

- (void)setState:(WTAVPlayerViewState)state {
    _state = state;
    
    switch (state) {
        case WTAVPlayerViewStateUnknown:
            break;
        case WTAVPlayerViewStateBuffering:
            [_playerContorlView changeStateToLoading];
            break;
        case WTAVPlayerViewStateFailed:
            [self changViewToSmallScreen];
            [_playerContorlView changeStateToFailed];
            break;
        case WTAVPlayerViewStatePlaying:
            [_playerContorlView changeStateToNormalWithIsPlay:YES];
            break;
        case WTAVPlayerViewStatePause:
            [_playerContorlView changeStateToNormalWithIsPlay:NO];
            break;
        case WTAVPlayerViewStateStopped:
            //            [_playerContorlView reset];
            break;
        case WTAVPlayerViewStateEnd:
            [self changViewToSmallScreen];
            [_playerContorlView videoPlaybackFinished];
            break;
    }
}

- (void)setCurrentNetworkStatus:(AFNetworkReachabilityStatus)currentNetworkStatus {
    
    switch (currentNetworkStatus) {
        case AFNetworkReachabilityStatusUnknown:
            NSLog(@"AFNetworkReachabilityStatusUnknown");
            break;
        case AFNetworkReachabilityStatusNotReachable:
            NSLog(@"AFNetworkReachabilityStatusNotReachable");
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            NSLog(@"AFNetworkReachabilityStatusReachableViaWWAN");
            _lastPlaybackTime = _playerItem.currentTime;
            self.state = WTAVPlayerViewStateStopped;
            [self reset];
            [self setupUI];
            [_playerContorlView changeStateToCellularNetwork];
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            NSLog(@"AFNetworkReachabilityStatusReachableViaWiFi");
            if (_currentNetworkStatus == AFNetworkReachabilityStatusReachableViaWWAN &&
                _state == WTAVPlayerViewStateStopped) {
                [self.playerContorlView removeFromSuperview];
                [self setupUI];
                [self setupPlayer];
                [self setupObserver];
                [self setupNotification];
            }
            break;
    }
    
    _currentNetworkStatus = currentNetworkStatus;
}

- (void)setIsInBackground:(BOOL)isInBackground {
    _isInBackground = isInBackground;
    
    _isEnterBackground = isInBackground;
}

#pragma mark - Public
+ (instancetype)sharedPlayerView {
    
    static WTAVPlayerView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WTAVPlayerView alloc] init];
    });
    
    return instance;
}

- (void)playWithPlayerModel:(WTAVPlayerModel *)playerModel {
    
    _isCell = YES;
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    self.frame = playerModel.superView.bounds;
    [playerModel.superView addSubview:self];
    _playerContorlView.frame = self.bounds;
    
    if (_urlString.length > 0) {
        [self reset];
        [self setupUI];
    } else {
        [self setupMotionManager];
        [self setupVolumeControl];
    }
    
    _urlString = playerModel.urlString;
    _lastPlaybackTime = CMTimeMakeWithSeconds(playerModel.seekTime, 1);
    _playerModel = playerModel;
    
    [playerModel.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    if (_currentNetworkStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self setupPlayer];
        [self setupObserver];
        [self setupNotification];
    }
}

- (void)playWithURLString:(NSString *)urlString {
    
    [self playWithURLString:urlString seekTime:0];
}

- (void)playWithURLString:(NSString *)urlString seekTime:(NSInteger)seekTime {
    
    if (_urlString.length > 0) {
        [self reset];
        [self setupUI];
    } else {
        [self setupMotionManager];
        [self setupVolumeControl];
    }
    
    _urlString = urlString;
    _lastPlaybackTime = CMTimeMakeWithSeconds(seekTime, 1);
    
    if (_currentNetworkStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self setupPlayer];
        [self setupObserver];
        [self setupNotification];
        [self layoutSubviews];
    }
}

- (void)play {
    
    [_player play];
    self.state = WTAVPlayerViewStatePlaying;
}

- (void)pause {
    
    [_player pause];
    self.state = WTAVPlayerViewStatePause;
}

#pragma mark - Private

/**
 初始化成员变量
 */
- (void)initialization {
    
    _isDragged = NO;
    _fullScreenFrame = [UIScreen mainScreen].bounds;
    _lastPlaybackTime = kCMTimeZero;
    _isCell = NO;
    _isShowKeyboard = NO;
    _lastInterfaceOrientation = UIInterfaceOrientationPortrait;
    _isEnterBackground = NO;
}

/**
 设置界面
 */
- (void)setupUI {
    
    self.backgroundColor = [UIColor blackColor];
    
    _playerContorlView = [[WTAVPlayerContorlView alloc] initWithFrame:self.bounds];
    _playerContorlView.delegate = self;
    _playerContorlView.titleString = _titleString;
    [self addSubview:_playerContorlView];
}

/**
 设置网络状态管理者
 */
- (void)setupNetworkReachabilityManager {
    
    _networkManager = [AFNetworkReachabilityManager sharedManager];
    [_networkManager startMonitoring];
    
    __weak __typeof(self)weakSelf = self;
    [_networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.currentNetworkStatus = status;
    }];
}

/**
 设置播放器
 */
- (void)setupPlayer {
    
    NSURL *url = [NSURL URLWithString:_urlString];
    _urlAsset = [AVURLAsset assetWithURL:url];
    _playerItem = [AVPlayerItem playerItemWithAsset:_urlAsset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer insertSublayer:_playerLayer atIndex:0];
}

/**
 设置观察者
 */
- (void)setupObserver {
    
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self)weakSelf = self;
    _timeObserverToken = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.01, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf.isDragged) {
            CGFloat currentTime = CMTimeGetSeconds(strongSelf.playerItem.currentTime);
            [strongSelf.playerContorlView updatePlayingTime:currentTime];
            
            CGFloat totalDuration = CMTimeGetSeconds(strongSelf.player.currentItem.asset.duration);
            strongSelf.playerContorlView.totalDuration = totalDuration;
        }
    }];
}

/**
 设置通知
 */
- (void)setupNotification {
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

/**
 设置加速计传感器
 */
- (void)setupMotionManager {
    
    _motionManager = [CMMotionManager new];
    if (!_motionManager.isAccelerometerAvailable) {
        return;
    }
    [_motionManager startAccelerometerUpdates];
}

/**
 设置音量控制器
 */
- (void)setupVolumeControl {
    
    MPVolumeView *volumeView = [MPVolumeView new];
    volumeView.frame = self.bounds;
    [volumeView sizeToFit];
    
    for (UIView *view in volumeView.subviews) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

/**
 旋转视图
 
 @param pi 旋转角度
 @param frame 旋转完成后的大小
 @param orientation 旋转完成后status的方向
 */
- (void)viewTransformRotate:(CGFloat)pi frame:(CGRect)frame statusBarOrientation:(UIInterfaceOrientation)orientation {
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
        
        self.transform = CGAffineTransformRotate(self.transform, pi);
        if (!CGRectIsNull(frame)) {
            self.frame = frame;
            _playerContorlView.frame = self.bounds;
        }
        
    } completion:^(BOOL finished) {
        
        if (orientation != UIInterfaceOrientationPortrait
            && [_playerContorlView controlViewIsHidden]
            && _state != WTAVPlayerViewStateEnd) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        } else {
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
        
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    }];
}

/**
 转为小屏播放
 */
- (void)changViewToSmallScreen {
    
    [_playerContorlView changeViewSizeWithIsFull:NO];
    
    if ([_delegate respondsToSelector:@selector(playerView:didSelectedZoomButtonWithIsEnlarge:)]) {
        [_delegate playerView:self didSelectedZoomButtonWithIsEnlarge:NO];
    }
    
    if (!_isHorizontalVideo) {
        if (self.frame.size.height > self.frame.size.width) {
            [_playerContorlView hideTopView:YES];
            [self viewTransformToTargetFrame:_smallScreenFrame];
            [self afterChangeViewFrameToSmall];
        }
        
        return;
    }
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        [_playerContorlView hideTopView:YES];
        [self viewTransformRotate:-M_PI_2 frame:_smallScreenFrame statusBarOrientation:UIInterfaceOrientationPortrait];
        [self afterChangeViewFrameToSmall];
        
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        
        [_playerContorlView hideTopView:YES];
        [self viewTransformRotate:M_PI_2 frame:_smallScreenFrame statusBarOrientation:UIInterfaceOrientationPortrait];
        [self afterChangeViewFrameToSmall];
        
    }
}

/**
 移除观察者
 */
- (void)removeObserver {
    
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    
    if (_player) {
        [_player removeTimeObserver:_timeObserverToken];
    }
    
    if (_playerModel.tableView) {
        [_playerModel.tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

/**
 移除通知
 */
- (void)removeNotification {
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 复位
 */
- (void)reset {
    
    if ([_delegate respondsToSelector:@selector(playerView:didPlayFinishWithTime:)] && _player) {
        [_delegate playerView:self didPlayFinishWithTime:(NSInteger)CMTimeGetSeconds(_playerItem.currentTime)];
    }
    
    [self.playerContorlView removeFromSuperview];
    [self removeNotification];
    [self removeObserver];
    [_player pause];
    [_playerLayer removeFromSuperlayer];
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    _playerLayer = nil;
    _playerItem = nil;
    self.transform = CGAffineTransformIdentity;
    self.frame = _smallScreenFrame;
    [self initialization];
    
    if (_playerModel) {
        _playerModel = nil;
    }
}

/**
 在转换屏幕为全屏之前
 */
- (void)beforeChangeViewFrameToFullScreen {
    
    CGRect targetFrame;
    if (_isCell) {
        targetFrame = [_playerModel.superView.superview convertRect:_playerModel.superView.frame toView:[UIApplication sharedApplication].keyWindow];
        
    } else {
        _lastSuperView = self.superview;
        targetFrame = [self.superview convertRect:self.frame toView:[UIApplication sharedApplication].keyWindow];
    }
    [self removeFromSuperview];
    self.frame = targetFrame;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

/**
 在转换屏幕为小屏之后
 */
- (void)afterChangeViewFrameToSmall {
    
    if (_isCell) {
        [self removeFromSuperview];
        self.frame = _playerModel.superView.bounds;
        [_playerModel.superView addSubview:self];
    } else {
        [self removeFromSuperview];
        self.frame = _smallScreenFrame;
        [_lastSuperView insertSubview:self atIndex:0];
    }
}

/**
 判断视频是否为横屏
 */
- (BOOL)videoIsHorizontal {
    
    CGSize videoSize = _playerLayer.videoRect.size;
    return videoSize.width > videoSize.height;
}

/**
 改变视图大小
 
 @param targetFrame 改变完成后的大小
 */
- (void)viewTransformToTargetFrame:(CGRect)targetFrame {
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
        
        if (!CGRectIsNull(targetFrame)) {
            self.frame = targetFrame;
            _playerContorlView.frame = self.bounds;
        }
        
    } completion:^(BOOL finished) {
        
        [UIApplication sharedApplication].statusBarHidden = NO;
        
    }];
}

#pragma mark - ObserverAction
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        
        switch (status) {
            case AVPlayerItemStatusReadyToPlay: {
                if (CMTimeGetSeconds(_lastPlaybackTime) > 0) {
                    [_player seekToTime:_lastPlaybackTime];
                }
                [_player play];
                self.state = WTAVPlayerViewStatePlaying;
                _isHorizontalVideo = [self videoIsHorizontal];
            }
                break;
            case AVPlayerItemStatusFailed: {
                self.state = WTAVPlayerViewStateFailed;
                if (CMTimeGetSeconds(_playerItem.currentTime) > 0) {
                    _lastPlaybackTime = _playerItem.currentTime;
                }
            }
                break;
            case AVPlayerItemStatusUnknown: {
                self.state = WTAVPlayerViewStateUnknown;
            }
                break;
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray<NSValue *> *loadedTimeRanges = _playerItem.loadedTimeRanges;
        CMTimeRange timeRange = loadedTimeRanges.firstObject.CMTimeRangeValue;
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval bufferSecounds = startSeconds + durationSeconds;
        [_playerContorlView updateBufferTimew:bufferSecounds];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
        if (_playerItem.playbackBufferEmpty &&
            self.state != WTAVPlayerViewStateBuffering) {
            self.state = WTAVPlayerViewStateBuffering;
        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        if (_playerItem.playbackLikelyToKeepUp &&
            self.state == WTAVPlayerViewStateBuffering) {
            self.state = WTAVPlayerViewStatePlaying;
        }
        
    }
    
    if (object == _playerModel.tableView &&
        [keyPath isEqualToString:@"contentOffset"]) {
        
        if (self.frame.size.width > [UIScreen mainScreen].bounds.size.width) {
            return;
        }
        
        UITableViewCell *currentCell = [_playerModel.tableView cellForRowAtIndexPath:_playerModel.indexPath];
        NSArray<UITableViewCell *> *visibleCells = _playerModel.tableView.visibleCells;
        if (![visibleCells containsObject:currentCell] && _player) {
            [self reset];
            [self removeFromSuperview];
        }
    }
}

#pragma mark - NotificationAction
- (void)deviceOrientationDidChange:(NSNotification *)note {
    
    if (_state == WTAVPlayerViewStateEnd
        || _state == WTAVPlayerViewStateFailed
        || _isShowKeyboard
        || _isEnterBackground
        || !_isHorizontalVideo) {
        return;
    }
    
    UIDeviceOrientation orientenation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    switch (orientenation) {
        case UIDeviceOrientationLandscapeLeft: {
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                if ([_delegate respondsToSelector:@selector(playerView:didSelectedZoomButtonWithIsEnlarge:)]) {
                    [_delegate playerView:self didSelectedZoomButtonWithIsEnlarge:NO];
                }
                [self viewTransformRotate:M_PI frame:CGRectNull statusBarOrientation:UIInterfaceOrientationLandscapeRight];
            } else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
                if ([_delegate respondsToSelector:@selector(playerView:didSelectedZoomButtonWithIsEnlarge:)]) {
                    [_delegate playerView:self didSelectedZoomButtonWithIsEnlarge:YES];
                }
                [self beforeChangeViewFrameToFullScreen];
                [self viewTransformRotate:M_PI_2 frame:_fullScreenFrame statusBarOrientation:UIInterfaceOrientationLandscapeRight];
                [_playerContorlView changeViewSizeWithIsFull:YES];
            }
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                if ([_delegate respondsToSelector:@selector(playerView:didSelectedZoomButtonWithIsEnlarge:)]) {
                    [_delegate playerView:self didSelectedZoomButtonWithIsEnlarge:NO];
                }
                [self viewTransformRotate:M_PI frame:CGRectNull statusBarOrientation:UIInterfaceOrientationLandscapeLeft];
            } else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
                if ([_delegate respondsToSelector:@selector(playerView:didSelectedZoomButtonWithIsEnlarge:)]) {
                    [_delegate playerView:self didSelectedZoomButtonWithIsEnlarge:YES];
                }
                [self beforeChangeViewFrameToFullScreen];
                [self viewTransformRotate:-M_PI_2 frame:_fullScreenFrame statusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                [_playerContorlView changeViewSizeWithIsFull:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)itemDidPlayToEndTime:(NSNotification *)note {
    
    self.state = WTAVPlayerViewStateEnd;
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    _isShowKeyboard = NO;
}

- (void)keyboardWillBeShow:(NSNotification *)notification {
    
    _isShowKeyboard = YES;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    _lastInterfaceOrientation = interfaceOrientation;
    _isEnterBackground = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
    [[UIApplication sharedApplication] setStatusBarOrientation:_lastInterfaceOrientation];
    _isEnterBackground = NO;
}

#pragma mark - WTAVPlayerContorlViewDelegate
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedControlButton:(UIButton *)controlButton {
    
    if (controlButton.selected &&
        self.state == WTAVPlayerViewStatePause) {
        [self play];
    } else if (!controlButton.selected &&
               self.state == WTAVPlayerViewStatePlaying) {
        [self pause];
    }
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView progressSliderDidTouchDownAction:(UISlider *)sender {
    
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView progressSliderDidValueChangedAction:(UISlider *)sender {
    
    _isDragged = YES;
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView progressSliderDidTouchUpAction:(UISlider *)sender {
    
    _isDragged = NO;
    
    CGFloat totalDuration = CMTimeGetSeconds(_playerItem.duration);
    CGFloat targetTimeVaule = totalDuration * sender.value;
    CMTime  targetTime = CMTimeMakeWithSeconds(targetTimeVaule, 1);
    [_playerItem seekToTime:targetTime];
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView progressSliderDidTouchCancelAction:(UISlider *)sender {
    
    _isDragged = NO;
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedZoomButton:(UIButton *)zoomButton {
    
    if ([_delegate respondsToSelector:@selector(playerView:didSelectedZoomButtonWithIsEnlarge:)]) {
        [_delegate playerView:self didSelectedZoomButtonWithIsEnlarge:zoomButton.selected];
    }
    
    if (!_isHorizontalVideo) {
        if (zoomButton.isSelected) {
            [_playerContorlView hideTopView:NO];
            [self beforeChangeViewFrameToFullScreen];
            [self viewTransformToTargetFrame:_fullScreenFrame];
        } else {
            [_playerContorlView hideTopView:YES];
            [self viewTransformToTargetFrame:_smallScreenFrame];
            [self afterChangeViewFrameToSmall];
        }
        
        return;
    }
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        
        [_playerContorlView hideTopView:NO];
        [self beforeChangeViewFrameToFullScreen];
        
        CMAcceleration acceleration = _motionManager.accelerometerData.acceleration;
        CGFloat xACC = acceleration.x;
        if (xACC <= 0) {
            [self viewTransformRotate:M_PI_2 frame:_fullScreenFrame statusBarOrientation:UIInterfaceOrientationLandscapeRight];
        } else if (xACC > 0) {
            [self viewTransformRotate:-M_PI_2 frame:_fullScreenFrame statusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        }
        
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        [_playerContorlView hideTopView:YES];
        [self viewTransformRotate:-M_PI_2 frame:_smallScreenFrame statusBarOrientation:UIInterfaceOrientationPortrait];
        [self afterChangeViewFrameToSmall];
        
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        
        [_playerContorlView hideTopView:YES];
        [self viewTransformRotate:M_PI_2 frame:_smallScreenFrame statusBarOrientation:UIInterfaceOrientationPortrait];
        [self afterChangeViewFrameToSmall];
        
    }
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didTouchesBeganWithPositionType:(WTAVPlayerContorlViewTouchPositionType)positionType {
    
    _touchPositionType = positionType;
    _startPlayTime = CMTimeGetSeconds(_playerItem.currentTime);;
    
    switch (positionType) {
            
        case WTAVPlayerContorlViewTouchPositionTypeLeft:
            _startValue = [UIScreen mainScreen].brightness;
            break;
            
        case WTAVPlayerContorlViewTouchPositionTypeRight:
            _startValue = _volumeViewSlider.value;
            break;
    }
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didTouchesMovedWithPanDirection:(WTAVPlayerContorlViewPanDirection)panDirection panDistance:(CGFloat)panDistance {
    
    _panDirection = panDirection;
    
    switch (panDirection) {
            
        case WTAVPlayerContorlViewPanDirectionVertical: {
            CGFloat changeValue = panDistance / 30.0 / 10;
            switch (_touchPositionType) {
                    
                case WTAVPlayerContorlViewTouchPositionTypeLeft: {
                    [[UIScreen mainScreen] setBrightness:_startValue - changeValue];
                }
                    break;
                    
                case WTAVPlayerContorlViewTouchPositionTypeRight: {
                    [_volumeViewSlider setValue:_startValue - changeValue animated:YES];
                    
                    if (_startValue - changeValue - self.volumeViewSlider.value >= 0.1) {
                        [_volumeViewSlider setValue:0.1 animated:NO];
                        [_volumeViewSlider setValue:_startValue - changeValue animated:YES];
                    }
                }
                    break;
            }
        }
            break;
            
        case WTAVPlayerContorlViewPanDirectionHorizontal: {
            CGFloat panTime = panDistance / 3;
            CGFloat totalDuration = CMTimeGetSeconds(_playerItem.duration);
            _destinationTime = _startPlayTime + panTime;
            if (_destinationTime < 0) {
                _destinationTime = 0;
            } else if (_destinationTime > totalDuration) {
                _destinationTime = totalDuration;
            }
            
            [_playerContorlView updateForwardViewTargetTime:_destinationTime isFastForward:_destinationTime > _startPlayTime];
        }
            break;
            
        case WTAVPlayerContorlViewPanDirectionNone: {
            
        }
            break;
    }
}

- (void)playerContorlViewdidTouchesEnded:(WTAVPlayerContorlView *)playerContorlView {
    
    if (_panDirection == WTAVPlayerContorlViewPanDirectionHorizontal) {
        CMTime targetTime = CMTimeMakeWithSeconds(_destinationTime, 1);
        [_playerItem seekToTime:targetTime];
    }
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedReplayButton:(UIButton *)replayButton {
    
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
    self.state = WTAVPlayerViewStatePlaying;
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedContinueButton:(UIButton *)continueButton {
    
    [self.playerContorlView removeFromSuperview];
    [self setupUI];
    [self setupPlayer];
    [self setupObserver];
    [self setupNotification];
}

- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedRepeatsButton:(UIButton *)repeatsButton {
    
    [self reset];
    [self setupUI];
    [self setupPlayer];
    [self setupObserver];
    [self setupNotification];
}

@end
