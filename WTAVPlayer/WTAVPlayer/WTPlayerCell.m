//
//  WTPlayerCell.m
//  WTAVPlayerView
//
//  Created by 吕成翘 on 2017/10/9.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTPlayerCell.h"
#import "Masonry.h"


@interface WTPlayerCell ()

@property (nonatomic, strong) UIImageView *playImageView;

@end


@implementation WTPlayerCell

#pragma mark - CustomAccessors
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupUI];
        [self setupGestureRecognizer];
    }
    
    return self;
}

#pragma mark - Private
/**
 设置界面
 */
- (void)setupUI {
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"此处为标题";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    [titleLabel sizeToFit];
    [self.contentView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"635942-14593722fe3f0695"]];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    _playImageView = imageView;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(([UIScreen mainScreen].bounds.size.width - 15 * 2) / 16 * 9);
        make.top.equalTo(titleLabel.mas_bottom).offset(15);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.top.equalTo(imageView.mas_bottom).offset(15);
        make.left.bottom.right.equalTo(self.contentView);
    }];
}

/**
 设置手势
 */
- (void)setupGestureRecognizer {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [_playImageView addGestureRecognizer:tap];
}

#pragma mark - ResponseAction
- (void)tapAction {
    
    if ([_delegate respondsToSelector:@selector(playerCell:didSelectedImageView:)]) {
        [_delegate playerCell:self didSelectedImageView:_playImageView];
    }
}

@end
