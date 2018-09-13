//
//  WTAVPlayerButton.m
//  IntelligentLinzi
//
//  Created by 吕成翘 on 2017/6/24.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTAVPlayerButton.h"
#import "WTAVPlayer.h"


@implementation WTAVPlayerButton

#pragma mark - Public
+ (instancetype)wt_buttonImageName:(NSString *)imageName target:(id)target action:(SEL)action {
    
    WTAVPlayerButton *button = [self buttonWithType:UIButtonTypeCustom];
    
    if (imageName) {
        [button setBackgroundImage:WTAVPlayerViewImage(imageName) forState:UIControlStateNormal];
    }
    
    if (target && action) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    [button sizeToFit];
    
    return button;
}

+ (instancetype)wt_buttonTitle:(NSString *)title fontSize:(CGFloat)fontSize color:(UIColor *)color target:(id)target action:(SEL)action {
    
    WTAVPlayerButton *button = [self buttonWithType:UIButtonTypeCustom];
    
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    
    if (fontSize) {
        button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    
    if (color) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    if (target && action) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    [button sizeToFit];
    
    return button;
}

+ (instancetype)wt_buttonTitle:(NSString *)title fontSize:(CGFloat)fontSize color:(UIColor *)color imageName:(NSString *)imageName target:(id)target action:(SEL)action {
    
    WTAVPlayerButton *button = [self buttonWithType:UIButtonTypeCustom];
    
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    
    if (fontSize) {
        button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    
    if (color) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    if (imageName) {
        [button setBackgroundImage:WTAVPlayerViewImage(imageName) forState:UIControlStateNormal];
    }
    
    if (target && action) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    [button sizeToFit];
    
    return button;
}

- (UIEdgeInsets)wt_responseAreaWithImageSize:(CGSize)imageSize targetSize:(CGSize)targetSize {
    
    CGFloat standardWidth = targetSize.width;
    CGFloat standardHeight = targetSize.height;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    CGFloat topCompensate = -(standardHeight - imageHeight) * 0.5;
    CGFloat leftCompensate = -(standardWidth - imageWidth) * 0.5;
    CGFloat bottomCompensate = -topCompensate;
    CGFloat rightCompensate = -leftCompensate;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self setImageEdgeInsets:UIEdgeInsetsMake(bottomCompensate, rightCompensate, bottomCompensate, rightCompensate)];
    
    return UIEdgeInsetsMake(topCompensate, leftCompensate, bottomCompensate, rightCompensate);
}

#pragma mark - CustomAccessors
// 调整按钮响应范围
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    
    return CGRectContainsPoint(bounds, point);
}

// 取消点击高亮效果
- (void)setHighlighted:(BOOL)highlighted {
    
}

@end
