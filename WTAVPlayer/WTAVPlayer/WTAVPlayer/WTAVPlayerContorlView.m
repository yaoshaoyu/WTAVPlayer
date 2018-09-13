//
//  WTAVPlayerContorlView.m
//  WTAVPlayerView
//
//  Created by 吕成翘 on 2017/9/12.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTAVPlayerContorlView.h"
#import "WTAVPlayerGradientColorView.h"
#import "WTAVPlayerFastForwardView.h"
#import "WTAVPlayerBrightnessView.h"
#import "WTAVPlayerButton.h"
#import "WTAVPlayer.h"
#import "Masonry.h"


#define kTopBottomViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]    // 顶部底部背景色


static const CGFloat topAndBottomViewHeight = 40.0;    // 顶部视图和底部视图的高度
static const CGFloat autoHideViewTime = 3.0;           // 自动隐藏视图倒计时的时间


@interface WTAVPlayerContorlView ()

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;        // 加载等待视图
@property (nonatomic, strong) UIButton *controlButton;                     // 控制按钮
@property (nonatomic, strong) WTAVPlayerGradientColorView *topView;                // 顶部视图
@property (nonatomic, strong) WTAVPlayerGradientColorView *bottomView;             // 底部视图
@property (nonatomic, strong) WTAVPlayerButton *zoomButton;                // 缩放按钮
@property (nonatomic, strong) UILabel *playedTimeLabel;                    // 已播时长标签
@property (nonatomic, strong) UILabel *totalTimeLabel;                     // 总时长标签
@property (nonatomic, strong) UISlider *progressSlider;                    // 进度滑竿
@property (nonatomic, strong) UIProgressView *loadingProgress;             // 缓冲进度条
@property (nonatomic, strong) WTAVPlayerButton *backButton;                // 返回按钮
@property (nonatomic, strong) UILabel *titleLabel;                         // 标题标签
@property (nonatomic, strong) UIView *loadFailedView;                      // 加载失败视图
@property (nonatomic, strong) UIView *cellularNetworkView;                 // 蜂窝网络视图
@property (nonatomic, strong) UIView *playbackFinishedView;                // 播放完成视图
@property (nonatomic, strong) WTAVPlayerFastForwardView *fastForwardView;          // 快进视图
@property (nonatomic, strong) WTAVPlayerBrightnessView *brightnessView;    // 亮度视图

@end


@implementation WTAVPlayerContorlView {
    CGPoint _startPoint;                                // 开始触摸的点
    WTAVPlayerContorlViewPanDirection _panDirection;    // 滑动的方向
    BOOL _isEnd;                                        // 是否播放结束
}

#pragma mark - CustomAccessors
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _panDirection = WTAVPlayerContorlViewPanDirectionNone;
        _isEnd = NO;
        
        [self setupUI];
        [self setupGestureRecognizer];
    }
    
    return self;
}

- (void)setTotalDuration:(CGFloat)totalDuration {
    _totalDuration = totalDuration;
    
    _totalTimeLabel.text = [self convertTime:totalDuration];
}

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    
    _titleLabel.text = titleString;
}

#pragma mark - Public
- (void)changeStateToLoading {
    
    _bottomView.hidden = YES;
    _controlButton.hidden = YES;
    [_loadingView startAnimating];
}

- (void)changeStateToNormalWithIsPlay:(BOOL)isPlay {
    
    if (_loadingView.animating) {
        [_loadingView stopAnimating];
    }
    
    if (isPlay) {
        _isEnd = NO;
        _controlButton.selected = NO;
        if (!_bottomView.hidden) {
            [self hideView];
        }
    } else {
        _controlButton.selected = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideViewAction) object:nil];
    }
}

- (void)changeStateToFailed {
    
    _isEnd = YES;
    
    if (_loadingView.animating) {
        [_loadingView stopAnimating];
    }
    
    _controlButton.hidden = YES;
    _bottomView.hidden = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideViewAction) object:nil];
    [self insertSubview:self.loadFailedView atIndex:0];
}

- (void)changeStateToCellularNetwork {
    
    _isEnd = YES;
    
    if (_loadingView.animating) {
        [_loadingView stopAnimating];
    }
    
    _controlButton.hidden = YES;
    _bottomView.hidden = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideViewAction) object:nil];
    [self insertSubview:self.cellularNetworkView atIndex:0];
    
}

- (void)videoPlaybackFinished {
    
    _isEnd = YES;
    
    _controlButton.hidden = YES;
    _bottomView.hidden = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideViewAction) object:nil];
    [self insertSubview:self.playbackFinishedView atIndex:0];
}

- (void)updatePlayingTime:(CGFloat)time {
    
    CGFloat percent = time / _totalDuration;
    [_progressSlider setValue:percent animated:YES];
    _playedTimeLabel.text = [self convertTime:time];
}

- (void)updateBufferTimew:(CGFloat)time {
    
    CGFloat percent = time / _totalDuration;
    [_loadingProgress setProgress:(float)percent animated:YES];
}

- (void)hideTopView:(BOOL)isHide {
    
    if (isHide) {
        _topView.hidden = YES;
    } else {
        _topView.hidden = NO;
    }
}

- (BOOL)controlViewIsHidden {
    
    return _bottomView.hidden;
}

- (void)changeViewSizeWithIsFull:(BOOL)isFull {
    
    _zoomButton.selected = isFull;
}

- (void)updateForwardViewTargetTime:(CGFloat)targetTime isFastForward:(BOOL)isFastForward {
    
    if (targetTime < 0) {
        _fastForwardView.hidden = YES;
        return;
    } else {
        _fastForwardView.hidden = NO;
        _fastForwardView.isFastForward = isFastForward;
        _fastForwardView.totalTime = _totalDuration;
        _fastForwardView.targetTime = targetTime;
    }
}

#pragma mark - TouchesHandle
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (![_delegate respondsToSelector:@selector(playerContorlView:didTouchesBeganWithPositionType:)]) {
        return;
    }
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    _startPoint = currentPoint;
    
    if (_startPoint.x <= self.bounds.size.width * 0.5) {
        [_delegate playerContorlView:self didTouchesBeganWithPositionType:WTAVPlayerContorlViewTouchPositionTypeLeft];
    } else {
        [_delegate playerContorlView:self didTouchesBeganWithPositionType:WTAVPlayerContorlViewTouchPositionTypeRight];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (![_delegate respondsToSelector:@selector(playerContorlView:didTouchesMovedWithPanDirection:panDistance:)]) {
        return;
    }
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    CGPoint panPoint = CGPointMake(currentPoint.x - _startPoint.x, currentPoint.y - _startPoint.y);
    
    if (_panDirection == WTAVPlayerContorlViewPanDirectionNone) {
        if (ABS(panPoint.x) > 30) {
            _panDirection = WTAVPlayerContorlViewPanDirectionHorizontal;
        } else if (ABS(panPoint.y) > 30) {
            _panDirection = WTAVPlayerContorlViewPanDirectionVertical;
        }
    }
    
    switch (_panDirection) {
            
        case WTAVPlayerContorlViewPanDirectionNone: {
            return;
        }
            break;
            
        case WTAVPlayerContorlViewPanDirectionVertical: {
            [_delegate playerContorlView:self didTouchesMovedWithPanDirection:WTAVPlayerContorlViewPanDirectionVertical panDistance:panPoint.y];
        }
            break;
            
        case WTAVPlayerContorlViewPanDirectionHorizontal: {
            [_delegate playerContorlView:self didTouchesMovedWithPanDirection:WTAVPlayerContorlViewPanDirectionHorizontal panDistance:panPoint.x];
        }
            break;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        return;
    }
    
    if (_panDirection == WTAVPlayerContorlViewPanDirectionHorizontal) {
        if ([_delegate respondsToSelector:@selector(playerContorlViewdidTouchesEnded:)]) {
            [_delegate playerContorlViewdidTouchesEnded:self];
        }
        
        _fastForwardView.hidden = YES;
    }
    
    _panDirection = WTAVPlayerContorlViewPanDirectionNone;
}

#pragma mark - Private
/**
 设置界面
 */
- (void)setupUI {
    
    self.backgroundColor = [UIColor clearColor];
    
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self addSubview:_loadingView];
    [_loadingView startAnimating];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    
    _controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _controlButton.hidden = YES;
    [_controlButton setImage:WTAVPlayerViewImage(@"WTAVPlayerView_player_pause") forState:UIControlStateNormal];
    [_controlButton setImage:WTAVPlayerViewImage(@"WTAVPlayerView_player_play") forState:UIControlStateSelected];
    [_controlButton addTarget:self action:@selector(controlButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_controlButton];
    
    [_controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.center.equalTo(self);
    }];
    
    
    _bottomView = [[WTAVPlayerGradientColorView alloc] initWithFrame:CGRectZero startColor:kTopBottomViewBackgroundColor endColor:[UIColor clearColor] style:WTAVPlayerGradientColorViewStyleDownToTop];
    _bottomView.hidden = YES;
    [self addSubview:_bottomView];
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(topAndBottomViewHeight);
    }];
    
    
    _zoomButton = [WTAVPlayerButton buttonWithType:UIButtonTypeCustom];
    [_zoomButton setImage:WTAVPlayerViewImage(@"WTAVPlayerView_player_zoom_enlarge") forState:UIControlStateNormal];
    [_zoomButton setImage:WTAVPlayerViewImage(@"WTAVPlayerView_player_zoom_reduce") forState:UIControlStateSelected];
    [_zoomButton addTarget:self action:@selector(zoomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_zoomButton];
    
    [_zoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.right.equalTo(_bottomView).offset(-15);
        make.centerY.equalTo(_bottomView);
    }];
    
    
    _playedTimeLabel = [UILabel new];
    _playedTimeLabel.textColor = [UIColor whiteColor];
    _playedTimeLabel.textAlignment = NSTextAlignmentCenter;
    _playedTimeLabel.backgroundColor = [UIColor clearColor];
    _playedTimeLabel.font = [UIFont systemFontOfSize:11.0];
    _playedTimeLabel.text = @"00:00:00";
    [_playedTimeLabel sizeToFit];
    [_bottomView addSubview:_playedTimeLabel];
    
    [_playedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 22));
        make.left.equalTo(_bottomView).offset(15);
        make.centerY.equalTo(_bottomView);
    }];
    
    
    _totalTimeLabel = [UILabel new];
    _totalTimeLabel.textColor = [UIColor whiteColor];
    _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    _totalTimeLabel.backgroundColor = [UIColor clearColor];
    _totalTimeLabel.font = [UIFont systemFontOfSize:11.0];
    _totalTimeLabel.text = @"00:00:00";
    [_totalTimeLabel sizeToFit];
    [_bottomView addSubview:_totalTimeLabel];
    
    [_totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 22));
        make.right.equalTo(_zoomButton.mas_left).offset(-15);
        make.centerY.equalTo(_bottomView);
    }];
    
    
    _progressSlider = [UISlider new];
    _progressSlider.value = 0.0;
    _progressSlider.maximumTrackTintColor = [UIColor clearColor];
    _progressSlider.minimumTrackTintColor = [UIColor colorWithRed:246.0 / 255.0 green:75.0 / 255.0 blue:50.0 / 255.0 alpha:1.0];
    [_progressSlider setThumbImage:WTAVPlayerViewImage(@"WTAVPlayerView_player_thumb") forState:UIControlStateNormal];
    [_progressSlider addTarget:self action:@selector(progressSliderTouchDownAction:) forControlEvents:UIControlEventTouchDown];
    [_progressSlider addTarget:self action:@selector(progressSliderTouchCancelAction:) forControlEvents:UIControlEventTouchCancel];
    [_progressSlider addTarget:self action:@selector(progressSliderTouchUpOutsideAction:) forControlEvents:UIControlEventTouchUpOutside];
    [_progressSlider addTarget:self action:@selector(progressSliderTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    [_progressSlider addTarget:self action:@selector(progressSliderValueChangedAction:)  forControlEvents:UIControlEventValueChanged];
    [_bottomView addSubview:_progressSlider];
    
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_playedTimeLabel.mas_right).offset(15);
        make.right.equalTo(_totalTimeLabel.mas_left).offset(-15);
        make.centerY.equalTo(_bottomView);
    }];
    
    
    _loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _loadingProgress.progressTintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    _loadingProgress.trackTintColor = [UIColor lightGrayColor];
    _loadingProgress.progress = 0.0;
    [_bottomView insertSubview:_loadingProgress belowSubview:_progressSlider];
    
    [_loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_progressSlider);
        make.centerY.equalTo(_progressSlider).offset(1);
        make.left.right.equalTo(_progressSlider);
    }];
    
    
    _topView = [[WTAVPlayerGradientColorView alloc] initWithFrame:CGRectZero startColor:kTopBottomViewBackgroundColor endColor:[UIColor clearColor] style:WTAVPlayerGradientColorViewStyleTopToDown];
    _topView.hidden = YES;
    [self addSubview:_topView];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(topAndBottomViewHeight + 20);
    }];
    
    
    _backButton = [WTAVPlayerButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:WTAVPlayerViewImage(@"WTAVPlayerView_player_return") forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_backButton];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(11, 21));
        make.left.equalTo(_topView).offset(15);
        make.centerY.equalTo(_topView).offset(10);
    }];
    
    
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:17.0];
    _titleLabel.text = @"标题";
    _titleLabel.numberOfLines = 1;
    [_titleLabel sizeToFit];
    [_topView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backButton.mas_right).offset(15);
        make.right.equalTo(_topView).offset(-15);
        make.centerY.equalTo(_backButton);
    }];
    
    
    _fastForwardView = [WTAVPlayerFastForwardView new];
    _fastForwardView.hidden = YES;
    [self addSubview:_fastForwardView];
    
    [_fastForwardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(125, 80));
        make.center.equalTo(self);
    }];
    
    
    _brightnessView = [WTAVPlayerBrightnessView sharedBrightnessView];
}

/**
 设置手势
 */
- (void)setupGestureRecognizer {
    
    UITapGestureRecognizer *screenSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenSingleTapAction:)];
    screenSingleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:screenSingleTap];
}

/**
 隐藏视图
 */
- (void)hideView {
    
    if (_controlButton.selected) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideViewAction) object:nil];
    [self performSelector:@selector(autoHideViewAction) withObject:nil afterDelay:autoHideViewTime];
}

/**
 * 把秒转换成格式化时间
 **/
- (NSString *)convertTime:(CGFloat)second{
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSString *newTime = [formatter stringFromDate:date];
    
    return newTime;
}

#pragma mark - ResponseAction
- (void)controlButtonAction:(UIButton *)sender {
    NSLog(@"点击了控制按钮");
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:didSelectedControlButton:)]) {
        [_delegate playerContorlView:self didSelectedControlButton:sender];
    }
}

- (void)zoomButtonAction:(UIButton *)sender {
    NSLog(@"点击了缩放按钮");
    
    sender.selected = !sender.selected;
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:didSelectedZoomButton:)]) {
        [_delegate playerContorlView:self didSelectedZoomButton:sender];
    }
}

- (void)progressSliderTouchDownAction:(UISlider *)sender {
    NSLog(@"按下了进度条按钮");
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideViewAction) object:nil];
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:progressSliderDidTouchDownAction:)]) {
        [_delegate playerContorlView:self progressSliderDidTouchDownAction:sender];
    }
}

- (void)progressSliderValueChangedAction:(UISlider *)sender {
    NSLog(@"进度条正在被拖动");
    
    CGFloat targetTime = _totalDuration * sender.value;
    _playedTimeLabel.text = [self convertTime:targetTime];
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:progressSliderDidValueChangedAction:)]) {
        [_delegate playerContorlView:self progressSliderDidValueChangedAction:sender];
    }
}

- (void)progressSliderTouchCancelAction:(UISlider *)sender {
    NSLog(@"进度条点击事件取消");
    
    [self hideView];
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:progressSliderDidTouchCancelAction:)]) {
        [_delegate playerContorlView:self progressSliderDidTouchCancelAction:sender];
    }
}

- (void)progressSliderTouchUpOutsideAction:(UISlider *)sender {
    NSLog(@"进度条按钮按下后在按钮外抬手");
    
    [self hideView];
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:progressSliderDidTouchCancelAction:)]) {
        [_delegate playerContorlView:self progressSliderDidTouchCancelAction:sender];
    }
}

- (void)progressSliderTouchUpInsideAction:(UISlider *)sender {
    NSLog(@"进度条按钮按下后在按钮内抬手");
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:progressSliderDidTouchUpAction:)]) {
        [_delegate playerContorlView:self progressSliderDidTouchUpAction:sender];
    }
}

- (void)backButtonAction:(UIButton *)sender {
    NSLog(@"点击了返回按钮");
    
    [self zoomButtonAction:_zoomButton];
}

- (void)screenSingleTapAction:(UITapGestureRecognizer *)recognizer {
    NSLog(@"单击了屏幕");
    
    if (_isEnd) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideViewAction) object:nil];
    
    if (!_bottomView.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            
            _bottomView.hidden = YES;
            _controlButton.hidden = YES;
            
            if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
                _topView.hidden = YES;
            }
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            
            _bottomView.hidden = NO;
            _controlButton.hidden = NO;
            
            if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
                _topView.hidden = NO;
            }
        } completion:^(BOOL finished) {
            [self hideView];
        }];
    }
}

- (void)autoHideViewAction {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _bottomView.hidden = YES;
        _controlButton.hidden = YES;
        
        if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            _topView.hidden = YES;
        }
    }];
}

- (void)repeatsButtonAction:(WTAVPlayerButton *)sender {
    NSLog(@"点击了重新加载按钮");
    
    [self.loadFailedView removeFromSuperview];
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:didSelectedRepeatsButton:)]) {
        [_delegate playerContorlView:self didSelectedRepeatsButton:sender];
    }
}

- (void)continueButtonAction:(WTAVPlayerButton *)sender {
    NSLog(@"点击了继续播放按钮");
    
    [self.cellularNetworkView removeFromSuperview];
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:didSelectedContinueButton:)]) {
        [_delegate playerContorlView:self didSelectedContinueButton:sender];
    }
}

- (void)replayButtonAction:(WTAVPlayerButton *)sender {
    NSLog(@"点击了重新播放按钮");
    
    [self.playbackFinishedView removeFromSuperview];
    
    if ([_delegate respondsToSelector:@selector(playerContorlView:didSelectedReplayButton:)]) {
        [_delegate playerContorlView:self didSelectedReplayButton:sender];
    }
}

#pragma mark - LazyLoad
- (UIView *)loadFailedView {
    
    if (!_loadFailedView) {
        _loadFailedView = [[UIView alloc] initWithFrame:self.bounds];
        _loadFailedView.backgroundColor = [UIColor blackColor];
        
        
        UILabel *tipLabel = [UILabel new];
        tipLabel.text = @"视频加载失败";
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = [UIColor whiteColor];
        [tipLabel sizeToFit];
        [_loadFailedView addSubview:tipLabel];
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_loadFailedView);
            make.top.equalTo(_loadFailedView).offset(60);
        }];
        
        
        WTAVPlayerButton *repeatsButton = [WTAVPlayerButton wt_buttonTitle:@"点击重试" fontSize:14 color:[UIColor whiteColor] imageName:@"WTAVPlayerView_player_button" target:self action:@selector(repeatsButtonAction:)];
        [_loadFailedView addSubview:repeatsButton];
        
        [repeatsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_loadFailedView);
            make.top.equalTo(tipLabel.mas_bottom).offset(15);
        }];
    }
    
    return _loadFailedView;
}

- (UIView *)cellularNetworkView {
    
    if (!_cellularNetworkView) {
        _cellularNetworkView = [[UIView alloc] initWithFrame:self.bounds];
        _cellularNetworkView.backgroundColor = [UIColor blackColor];
        
        
        UILabel *tipLabel = [UILabel new];
        tipLabel.text = @"正在使用非Wifi网络，播放将产生流量费用";
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = [UIColor whiteColor];
        [tipLabel sizeToFit];
        [_cellularNetworkView addSubview:tipLabel];
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_cellularNetworkView);
            make.top.equalTo(_cellularNetworkView).offset(60);
        }];
        
        
        WTAVPlayerButton *continueButton = [WTAVPlayerButton wt_buttonTitle:@"继续播放" fontSize:14 color:[UIColor whiteColor] imageName:@"WTAVPlayerView_player_button" target:self action:@selector(continueButtonAction:)];
        [_cellularNetworkView addSubview:continueButton];
        
        [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_cellularNetworkView);
            make.top.equalTo(tipLabel.mas_bottom).offset(15);
        }];
    }
    
    return _cellularNetworkView;
}

- (UIView *)playbackFinishedView {
    
    if (!_playbackFinishedView) {
        _playbackFinishedView = [[UIView alloc] initWithFrame:self.bounds];
        _playbackFinishedView.backgroundColor = [UIColor blackColor];
        
        
        UILabel *tipLabel = [UILabel new];
        tipLabel.text = @"视频播放结束";
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = [UIColor whiteColor];
        [tipLabel sizeToFit];
        [_playbackFinishedView addSubview:tipLabel];
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_playbackFinishedView);
            make.top.equalTo(_playbackFinishedView).offset(60);
        }];
        
        
        WTAVPlayerButton *replayButton = [WTAVPlayerButton wt_buttonTitle:@"重新播放" fontSize:14 color:[UIColor whiteColor] imageName:@"WTAVPlayerView_player_button" target:self action:@selector(replayButtonAction:)];
        [_playbackFinishedView addSubview:replayButton];
        
        [replayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_playbackFinishedView);
            make.top.equalTo(tipLabel.mas_bottom).offset(15);
        }];
    }
    
    return _playbackFinishedView;
}

@end
