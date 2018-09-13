//
//  WTAVPlayerModel.h
//  WTAVPlayerView
//
//  Created by 吕成翘 on 2017/10/9.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WTAVPlayerModel : NSObject

@property (nonatomic, copy) NSString *urlString;         // 视频连接地址字符串
@property (nonatomic, strong) UITableView *tableView;    // cell所属列表视图
@property (nonatomic, strong) NSIndexPath *indexPath;    // cell所属索引
@property (nonatomic, strong) UIView *superView;         // 视频播放视图的父视图
@property (nonatomic, assign) NSInteger seekTime;        // 开始播放的时间

@end
