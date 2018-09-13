//
//  WTAVPlayerContorlView.h
//  WTAVPlayerView
//
//  Created by 吕成翘 on 2017/9/12.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, WTAVPlayerContorlViewTouchPositionType) {
    WTAVPlayerContorlViewTouchPositionTypeLeft,     // 触碰左边的位置
    WTAVPlayerContorlViewTouchPositionTypeRight,    // 触碰右边的位置
};

typedef NS_ENUM(NSUInteger, WTAVPlayerContorlViewPanDirection) {
    WTAVPlayerContorlViewPanDirectionNone,          // 无
    WTAVPlayerContorlViewPanDirectionHorizontal,    // 水平滑动
    WTAVPlayerContorlViewPanDirectionVertical,      // 垂直滑动
};


@class WTAVPlayerContorlView;


@protocol WTAVPlayerContorlViewDelegate <NSObject>

@optional

/**
 视频播放器控制视图选择了控制按钮

 @param playerContorlView 视频播放器控制视图
 @param controlButton 控制按钮
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedControlButton:(UIButton *)controlButton;

/**
 视频播放器控制视图按下了进度条

 @param playerContorlView 视频播放器控制视图
 @param sender 进度条
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView progressSliderDidTouchDownAction:(UISlider *)sender;

/**
 视频播放器控制视图拖动了进度条
 
 @param playerContorlView 视频播放器控制视图
 @param sender 进度条
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView progressSliderDidValueChangedAction:(UISlider *)sender;

/**
 视频播放器控制视图松开了进度条
 
 @param playerContorlView 视频播放器控制视图
 @param sender 进度条
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView progressSliderDidTouchUpAction:(UISlider *)sender;

/**
 视频播放器控制视图取消了拖动进度条
 
 @param playerContorlView 视频播放器控制视图
 @param sender 进度条
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView progressSliderDidTouchCancelAction:(UISlider *)sender;

/**
 视频播放器控制视图选择了缩放按钮
 
 @param playerContorlView 视频播放器控制视图
 @param zoomButton 缩放按钮
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedZoomButton:(UIButton *)zoomButton;

/**
 视频播放器控制视图开始触摸视图
 
 @param playerContorlView 视频播放器控制视图
 @param positionType 触碰的位置
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didTouchesBeganWithPositionType:(WTAVPlayerContorlViewTouchPositionType)positionType;

/**
 视频播放器控制视图在视图上滑动
 
 @param playerContorlView 视频播放器控制视图
 @param panDirection 滑动的方向
 @param panDistance 滑动的距离
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didTouchesMovedWithPanDirection:(WTAVPlayerContorlViewPanDirection)panDirection panDistance:(CGFloat)panDistance;

/**
 视频播放器控制视图结束触摸视图
 
 @param playerContorlView 视频播放器控制视图
 */
- (void)playerContorlViewdidTouchesEnded:(WTAVPlayerContorlView *)playerContorlView;

/**
 视频播放器控制视图选择了重新播放按钮
 
 @param playerContorlView 视频播放器控制视图
 @param replayButton 重新播放按钮
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedReplayButton:(UIButton *)replayButton;

/**
 视频播放器控制视图选择了继续播放按钮
 
 @param playerContorlView 视频播放器控制视图
 @param continueButton 继续播放按钮
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedContinueButton:(UIButton *)continueButton;

/**
 视频播放器控制视图选择了重新加载按钮
 
 @param playerContorlView 视频播放器控制视图
 @param repeatsButton 重新加载按钮
 */
- (void)playerContorlView:(WTAVPlayerContorlView *)playerContorlView didSelectedRepeatsButton:(UIButton *)repeatsButton;

@end


@interface WTAVPlayerContorlView : UIView

@property (nonatomic, weak) id<WTAVPlayerContorlViewDelegate> delegate;

@property (nonatomic, assign) CGFloat totalDuration;    // 总时长
@property (nonatomic, copy) NSString *titleString;      // 标题标签

/**
 将状态改为加载中
 */
- (void)changeStateToLoading;

/**
 将状态改为正常

 @param isPlay 是否播放，YES为播放，NO为暂停
 */
- (void)changeStateToNormalWithIsPlay:(BOOL)isPlay;

/**
 将状态改为失败
 */
- (void)changeStateToFailed;

/**
 将状态改为蜂窝网
 */
- (void)changeStateToCellularNetwork;

/**
 视频播放结束
 */
- (void)videoPlaybackFinished;

/**
 更新播放时间

 @param time 当前时长
 */
- (void)updatePlayingTime:(CGFloat)time;

/**
 更新缓冲进度

 @param time 缓冲进度
 */
- (void)updateBufferTimew:(CGFloat)time;

/**
 隐藏顶部视图

 @param isHide 是否隐藏
 */
- (void)hideTopView:(BOOL)isHide;

/**
 控制视图是否隐藏

 @return 是否隐藏
 */
- (BOOL)controlViewIsHidden;

/**
 改变屏幕的大小

 @param isFull 是否是全屏
 */
- (void)changeViewSizeWithIsFull:(BOOL)isFull;

/**
 更新进度视图

 @param targetTime 目标时间，如果时间小于0则隐藏
 @param isFastForward 是否是快进
 */
- (void)updateForwardViewTargetTime:(CGFloat)targetTime isFastForward:(BOOL)isFastForward;

@end
