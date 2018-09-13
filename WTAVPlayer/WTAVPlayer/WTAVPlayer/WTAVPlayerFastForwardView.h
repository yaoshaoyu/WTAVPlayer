//
//  WTAVPlayerFastForwardView.h
//  WTAVPlayerDemo
//
//  Created by 吕成翘 on 2017/10/30.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WTAVPlayerFastForwardView : UIView

@property (nonatomic, assign) BOOL isFastForward;           // 是否是快进
@property (nonatomic, assign) NSTimeInterval totalTime;     // 视频总长
@property (nonatomic, assign) NSTimeInterval targetTime;    // 目标时间点

@end
