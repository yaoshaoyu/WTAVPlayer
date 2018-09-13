//
//  WTPushtViewController.m
//  WTAVPlayerDemo
//
//  Created by 吕成翘 on 2017/10/11.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTPushtViewController.h"
#import "WTAVPlayerView.h"


@interface WTPushtViewController ()

@property (nonatomic, strong) WTAVPlayerView *playerView;

@end


@implementation WTPushtViewController

#pragma mark - CustomAccessors
- (BOOL)shouldAutorotate {
    
    return NO;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNavigationBar];
}

#pragma mark - Private
/**
 设置界面
 */
- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    WTAVPlayerView *AVPlayerView = [[WTAVPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 16 * 9)];
    [self.view addSubview:AVPlayerView];
    _playerView = AVPlayerView;


    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //    NSString *videoURLString = @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
        NSString *videoURLString = @"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4";
        [_playerView playWithURLString:videoURLString];
    });
}

/**
 设置导航栏
 */
- (void)setupNavigationBar {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:17];
    backButton.frame = CGRectMake(15, 20, 44, 44);
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

#pragma mark - ResponseAction
- (void)backButtonAction {
    
    [_playerView reset];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
