//
//  WTAVPlayerGradientColorView.m
//  WTAVPlayerDemo
//
//  Created by 吕成翘 on 2017/10/30.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTAVPlayerGradientColorView.h"
#import "WTAVPlayer.h"


@interface WTAVPlayerGradientColorView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end



@implementation WTAVPlayerGradientColorView {
    UIColor *_startColor;                       // 起始颜色
    UIColor *_endColor;                         // 结束颜色
    WTAVPlayerGradientColorViewStyle _style;    // 渐变方式
}

#pragma mark - CustomAccessors
- (instancetype)initWithFrame:(CGRect)frame startColor:(UIColor *)startColor endColor:(UIColor *)endColor style:(WTAVPlayerGradientColorViewStyle)style {
    
    if (self = [super initWithFrame:frame]) {
        _startColor = startColor;
        _endColor = endColor;
        _style = style;
        
        [self setupUI];
    }
    
    return self;
}

- (void)layoutSubviews {
    
    [_gradientLayer removeFromSuperlayer];
    
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.bounds;
    
    switch (_style) {
        case WTAVPlayerGradientColorViewStyleDownToTop:
            _gradientLayer.startPoint = CGPointMake(0, 1);
            _gradientLayer.endPoint = CGPointMake(0, 0);
            break;
            
        case WTAVPlayerGradientColorViewStyleTopToDown:
            _gradientLayer.startPoint = CGPointMake(0, 0);
            _gradientLayer.endPoint = CGPointMake(0, 1);
            break;
            
        case WTAVPlayerGradientColorViewStyleLeftToRight:
            _gradientLayer.startPoint = CGPointMake(0, 0);
            _gradientLayer.endPoint = CGPointMake(1, 0);
            break;
            
        case WTAVPlayerGradientColorViewStyleRightToLeft:
            _gradientLayer.startPoint = CGPointMake(1, 0);
            _gradientLayer.endPoint = CGPointMake(0, 0);
            break;
            
        default:
            _gradientLayer.startPoint = CGPointMake(0, 0);
            _gradientLayer.endPoint = CGPointMake(1, 1);
            break;
    }
    
    _gradientLayer.colors = @[
                              (__bridge id)[_startColor CGColor],
                              (__bridge id)[_endColor CGColor]
                              ];
    
    [self.layer insertSublayer:_gradientLayer atIndex:0];
}

#pragma mark - Private
/**
 设置界面
 */
- (void)setupUI {
    
    self.backgroundColor = [UIColor clearColor];
}

@end
