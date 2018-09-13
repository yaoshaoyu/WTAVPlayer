//
//  WTAVPlayerView.h
//  WTAVPlayerView
//
//  Created by 吕成翘 on 2017/9/11.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTAVPlayerModel.h"


@class WTAVPlayerView;


typedef NS_ENUM(NSUInteger, WTAVPlayerViewState) {
    WTAVPlayerViewStateUnknown,      // 未知
    WTAVPlayerViewStateFailed,       // 失败
    WTAVPlayerViewStateBuffering,    // 缓冲中
    WTAVPlayerViewStatePlaying,      // 播放中
    WTAVPlayerViewStatePause,        // 暂停
    WTAVPlayerViewStateStopped,      // 停止
    WTAVPlayerViewStateEnd,          // 完成
};


@protocol WTAVPlayerViewDelegate <NSObject>

@optional
/**
 播放视图播放完成

 @param playerView 播放视图
 @param time 完成时时间
 */
- (void)playerView:(WTAVPlayerView *)playerView didPlayFinishWithTime:(NSInteger)time;

/**
 播放视图点击了全屏按钮

 @param playerView 播放视图
 @param isEnlage 是否是放大
 */
- (void)playerView:(WTAVPlayerView *)playerView didSelectedZoomButtonWithIsEnlarge:(BOOL)isEnlage;

@end


@interface WTAVPlayerView : UIView

@property (nonatomic, weak) id<WTAVPlayerViewDelegate> delegate;

@property (nonatomic, copy, readonly) NSString *urlString;            // 视频连接字符串
@property (nonatomic, assign, readonly) WTAVPlayerViewState state;    // 状态
@property (nonatomic, strong) WTAVPlayerModel *playerModel;           // 播放器模型

@property (nonatomic, copy) NSString *titleString;    // 视频标题
@property (nonatomic, assign) BOOL isInBackground;    // 是否在后台

/**
 播放指定视频链接

 @param urlString 视频链接字符串
 */
- (void)playWithURLString:(NSString *)urlString;

/**
 播放指定视频连接从指定时间开始

 @param urlString 视频链接字符串
 @param seekTime 开始播放的时间
 */
- (void)playWithURLString:(NSString *)urlString seekTime:(NSInteger)seekTime;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 复位
 */
- (void)reset;

// MARK: - 在TableView上播放用以下方法

/**
 获取视频播放器单例
 
 @return 视频播放器单例
 */
+ (instancetype)sharedPlayerView;

/**
 播放指定视频链接
 
 @param playerModel 视频模型
 */
- (void)playWithPlayerModel:(WTAVPlayerModel *)playerModel;

@end
