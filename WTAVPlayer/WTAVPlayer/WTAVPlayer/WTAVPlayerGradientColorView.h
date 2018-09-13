//
//  WTAVPlayerGradientColorView.h
//  WTAVPlayerDemo
//
//  Created by 吕成翘 on 2017/10/30.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, WTAVPlayerGradientColorViewStyle) {
    WTAVPlayerGradientColorViewStyleTopToDown,      // 渐变从上到下
    WTAVPlayerGradientColorViewStyleDownToTop,      // 渐变从下到上
    WTAVPlayerGradientColorViewStyleLeftToRight,    // 渐变从左到右
    WTAVPlayerGradientColorViewStyleRightToLeft,    // 渐变从右到左
};


@interface WTAVPlayerGradientColorView : UIView

/**
 初始化渐变色视图
 
 @param frame 视图的位置和大小
 @param startColor 起始颜色
 @param endColor 结束颜色
 @param style 渐变方式
 @return 渐变色视图
 */
- (instancetype)initWithFrame:(CGRect)frame
                   startColor:(UIColor *)startColor
                     endColor:(UIColor *)endColor
                        style:(WTAVPlayerGradientColorViewStyle)style;

@end
