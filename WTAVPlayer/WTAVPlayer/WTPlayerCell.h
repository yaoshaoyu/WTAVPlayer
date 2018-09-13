//
//  WTPlayerCell.h
//  WTAVPlayerView
//
//  Created by 吕成翘 on 2017/10/9.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WTPlayerCell;


@protocol WTPlayerCellDelegate <NSObject>

- (void)playerCell:(WTPlayerCell *)playerCell didSelectedImageView:(UIImageView *)imageView;

@end


@interface WTPlayerCell : UITableViewCell

@property (nonatomic, weak) id<WTPlayerCellDelegate> delegate;

@end
