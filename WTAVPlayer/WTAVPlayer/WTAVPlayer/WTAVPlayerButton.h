//
//  WTAVPlayerButton.h
//  IntelligentLinzi
//
//  Created by 吕成翘 on 2017/6/24.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WTAVPlayerButton : UIButton

/**
 创建图像按钮

 @param imageName 按钮图片名字
 @param target 按钮目标
 @param action 按钮响应
 @return 按钮
 */
+ (instancetype)wt_buttonImageName:(NSString *)imageName
                            target:(id)target
                            action:(SEL)action;

/**
 创建文本按钮

 @param title 按钮标题
 @param fontSize 按钮字体
 @param color 按钮颜色
 @param target 按钮目标
 @param action 按钮响应
 @return 按钮
 */
+ (instancetype)wt_buttonTitle:(NSString *)title
                      fontSize:(CGFloat)fontSize
                         color:(UIColor *)color
                        target:(id)target
                        action:(SEL)action;

/**
 创建带背景图的文本按钮

 @param title 按钮标题
 @param fontSize 按钮字体
 @param color 按钮颜色
 @param imageName 按钮背景图名字
 @param target 按钮目标
 @param action 按钮响应
 @return 按钮
 */
+ (instancetype)wt_buttonTitle:(NSString *)title
                      fontSize:(CGFloat)fontSize
                         color:(UIColor *)color
                     imageName:(NSString *)imageName
                        target:(id)target
                        action:(SEL)action;

/**
 计算补偿

 @param imageSize 图片尺寸
 @param targetSize 目标尺寸
 @return 补偿边距
 */
- (UIEdgeInsets)wt_responseAreaWithImageSize:(CGSize)imageSize
                                  targetSize:(CGSize)targetSize;

@end
