//
//  WTAVPlayerFastForwardView.m
//  WTAVPlayerDemo
//
//  Created by 吕成翘 on 2017/10/30.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTAVPlayerFastForwardView.h"
#import "WTAVPlayer.h"
#import "Masonry.h"


@interface WTAVPlayerFastForwardView ()

@property (nonatomic, strong) UIImageView *imageView;          // 图片视图
@property (nonatomic, strong) UILabel *timeLabel;              // 时间标签
@property (nonatomic, strong) UIProgressView *progressView;    // 进度视图

@end


@implementation WTAVPlayerFastForwardView

#pragma mark - CustomAccessors
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setTargetTime:(NSTimeInterval)targetTime {
    _targetTime = targetTime;
    
    if (_isFastForward) {
        [_imageView setImage:WTAVPlayerViewImage(@"WTAVPlayerView_player_fast_forward")];
    } else {
        [_imageView setImage:WTAVPlayerViewImage(@"WTAVPlayerView_player_fast_backward")];
    }
    
    [_progressView setProgress:targetTime / _totalTime animated:YES];
    
    NSString *targetTimeString = [self convertTime:_targetTime];
    NSString *totalTimeString = [self convertTime:_totalTime];
    NSString *contentString = [NSString stringWithFormat:@"%@/%@",targetTimeString, totalTimeString];
    _timeLabel.text = contentString;
}

#pragma mark - Private
/**
 设置界面
 */
- (void)setupUI {
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    
    _imageView = [UIImageView new];
    [self addSubview:_imageView];
    
    _timeLabel = [UILabel new];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont systemFontOfSize:14.0];
    [_timeLabel sizeToFit];
    [self addSubview:_timeLabel];
    
    _progressView = [UIProgressView new];
    _progressView.trackTintColor = [UIColor whiteColor];
    _progressView.progressTintColor = [UIColor colorWithRed:246.0 / 255.0 green:75.0 / 255.0 blue:50.0 / 255.0 alpha:1.0];
    [self addSubview:_progressView];
}

- (void)setupConstraints {
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.top.equalTo(self).offset(5);
        make.centerX.equalTo(self);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imageView.mas_bottom).offset(2);
        make.centerX.equalTo(self);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_bottom).offset(10);
        make.left.equalTo(self).offset(12);
        make.right.equalTo(self).offset(-12);
    }];
}

/**
 把秒转换成格式化时间
 **/
- (NSString *)convertTime:(CGFloat)second {
    
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

@end
