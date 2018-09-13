//
//  WTTableViewController.m
//  WTAVPlayerDemo
//
//  Created by 吕成翘 on 2017/10/11.
//  Copyright © 2017年 Weitac. All rights reserved.
//

#import "WTTableViewController.h"
#import "WTAVPlayerView.h"
#import "WTPlayerCell.h"


static NSString *const cellID = @"cellID";    // 复用标识


@interface WTTableViewController ()<UITableViewDataSource, WTPlayerCellDelegate, WTAVPlayerViewDelegate>

@property (nonatomic, strong) WTAVPlayerView *playerView;
@property (nonatomic, strong) UITableView *tableView;

@end


@implementation WTTableViewController {
    NSArray<NSNumber *> *_seekTimeList;    // 播放时间点数组
}

#pragma mark - CustomAccessors
- (BOOL)shouldAutorotate {
    
    return NO;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNavigationBar];
}

#pragma mark - Private
/**
 加载数据
 */
- (void)loadData {
    
    NSNumber *number = [NSNumber numberWithInteger:0];
    _seekTimeList = @[number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number];
}

/**
 设置界面
 */
- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 100;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[WTPlayerCell class] forCellReuseIdentifier:cellID];
    [self.view addSubview:tableView];
    _tableView = tableView;
}

/**
 设置导航栏
 */
- (void)setupNavigationBar {
    
    self.title = @"列表控制器";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - ResponseAction
- (void)backButtonAction {
    
    [_playerView reset];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _seekTimeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WTPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - WTPlayerCellDelegate
- (void)playerCell:(WTPlayerCell *)playerCell didSelectedImageView:(UIImageView *)imageView {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:playerCell];
    
    WTAVPlayerView *playerView = [WTAVPlayerView sharedPlayerView];
    playerView.delegate = self;
    WTAVPlayerModel *model = [WTAVPlayerModel new];
    model.urlString = @"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4";
    model.tableView = _tableView;
    model.indexPath = indexPath;
    model.superView = imageView;
    model.seekTime = _seekTimeList[indexPath.row].integerValue;
    [playerView playWithPlayerModel:model];
    _playerView = playerView;
}

#pragma mark - WTAVPlayerViewDelegate
- (void)playerView:(WTAVPlayerView *)playerView didPlayFinishWithTime:(NSInteger)time {
    
    NSMutableArray<NSNumber *> *arrayM = [NSMutableArray arrayWithArray:_seekTimeList];
    arrayM[playerView.playerModel.indexPath.row] = [NSNumber numberWithInteger:time];
    _seekTimeList = [arrayM copy];
}

@end
