//
//  WTAVPlayerBrightnessView.m
//  WTAVPlayerDemo
//
//  Created by 吕成翘 on 2017/10/30.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTAVPlayerBrightnessView.h"
#import "WTAVPlayer.h"


@interface WTAVPlayerBrightnessView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;    // 背景图片视图
@property (nonatomic, strong) UILabel *titleLabel;                 // 标题标签
@property (nonatomic, strong) UIView *longView;                    // 长条视图

@end


@implementation WTAVPlayerBrightnessView {
    NSArray<UIImageView *> *_longViewCells;              // 长视图单元数组
    UIInterfaceOrientation _lastInterfaceOrientation;    // 最后一次状态栏朝向
}


#pragma mark - LifeCycle
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
}

#pragma mark - Public
+ (instancetype)sharedBrightnessView {
    
    static WTAVPlayerBrightnessView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WTAVPlayerBrightnessView new];
    });
    return instance;
}

#pragma mark - CustomAccessro
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _lastInterfaceOrientation = UIInterfaceOrientationPortrait;
        
        [self setupUI];
        [self setupLongViewCells];
        [self updateLongView:[UIScreen mainScreen].brightness];
        [self setupObserver];
        [self setupNotification];
    }
    
    return self;
}

#pragma mark - Private
/**
 设置界面
 */
- (void)setupUI {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 0, 155, 155);
    self.center = CGPointMake(screenSize.width * 0.5, screenSize.height * 0.5);
    self.layer.cornerRadius  = 10;
    self.layer.masksToBounds = YES;
    self.alpha = 0.0;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolbar.alpha = 0.97;
    [self addSubview:toolbar];
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 76)];
    _backgroundImageView.image = WTAVPlayerViewImage(@"WTAVPlayerView_player_brightness");
    _backgroundImageView.center = CGPointMake(155 * 0.5, 155 * 0.5);
    [self addSubview:_backgroundImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"亮度";
    [self addSubview:_titleLabel];
    
    _longView = [[UIView alloc] initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
    _longView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
    [self addSubview:_longView];
}

/**
 设置长视图单元
 */
- (void)setupLongViewCells {
    
    NSMutableArray<UIImageView *> *arrayM = [NSMutableArray arrayWithCapacity:16];
    
    CGFloat cellWidth = (self.longView.bounds.size.width - 17) / 16;
    CGFloat cellHeight = 5;
    CGFloat cellY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat cellX = i * (cellWidth + 1) + 1;
        UIImageView *cellImageView = [UIImageView new];
        cellImageView.backgroundColor = [UIColor whiteColor];
        cellImageView.frame = CGRectMake(cellX, cellY, cellWidth, cellHeight);
        [_longView addSubview:cellImageView];
        [arrayM addObject:cellImageView];
    }
    
    _longViewCells = [arrayM copy];
}

/**
 更新长视图
 
 @param brightness    // 亮度
 */
- (void)updateLongView:(CGFloat)brightness {
    
    CGFloat stage = 1 / 15.0;
    NSInteger level = brightness / stage;
    
    for (int i = 0; i < _longViewCells.count; i++) {
        UIImageView *cellImageView = _longViewCells[i];
        if (i <= level) {
            cellImageView.hidden = NO;
        } else {
            cellImageView.hidden = YES;
        }
    }
}


/**
 设置观察者
 */
- (void)setupObserver {
    
    [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
}

/**
 设置通知
 */
- (void)setupNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientation:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

/**
 展示亮度视图
 */
- (void)showBrightnessView {
    
    if (!self.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
        
    }
    
    if (self.alpha < 1) {
        self.alpha = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.alpha > 0) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.alpha = 0;
                }];
            }
        });
    }
}

#pragma mark - ObserverAction
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"brightness"]) {
        NSNumber *brightnessNumber = change[NSKeyValueChangeNewKey];
        CGFloat brightness = brightnessNumber.floatValue;
        [self showBrightnessView];
        [self updateLongView:brightness];
    }
}

#pragma mark - NotificationAction
- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)note {
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            self.transform = CGAffineTransformIdentity;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            if (_lastInterfaceOrientation == UIInterfaceOrientationPortrait) {
                self.transform = CGAffineTransformRotate(self.transform, -M_PI_2);
            } else if (_lastInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                self.transform = CGAffineTransformRotate(self.transform, M_PI);
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            if (_lastInterfaceOrientation == UIInterfaceOrientationPortrait) {
                self.transform = CGAffineTransformRotate(self.transform, M_PI_2);
            } else if (_lastInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                self.transform = CGAffineTransformRotate(self.transform, -M_PI);
            }
            break;
        default:
            break;
    }
    
    _lastInterfaceOrientation = interfaceOrientation;
}

@end
