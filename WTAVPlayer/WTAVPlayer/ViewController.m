//
//  ViewController.m
//  WTAVPlayer
//
//  Created by 吕成翘 on 2018/9/13.
//  Copyright © 2018年 Weitac. All rights reserved.
//


#warning 在 info.plist文件中，添加 View controller-based status bar appearance 项并设为 NO。


#import "ViewController.h"
#import "WTTableViewController.h"
#import "WTPushtViewController.h"


@interface ViewController ()

@end


@implementation ViewController

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
    
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pushButton.backgroundColor = [UIColor lightGrayColor];
    [pushButton setTitle:@"pushButton" forState:UIControlStateNormal];
    [pushButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pushButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [pushButton sizeToFit];
    pushButton.frame = CGRectMake(0, 100, pushButton.bounds.size.width, pushButton.bounds.size.height);
    pushButton.center = CGPointMake(self.view.center.x, pushButton.center.y);
    [pushButton addTarget:self action:@selector(pushButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushButton];
    
    UIButton *tableButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tableButton.backgroundColor = [UIColor lightGrayColor];
    [tableButton setTitle:@"tableButton" forState:UIControlStateNormal];
    [tableButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    tableButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [tableButton sizeToFit];
    tableButton.frame = CGRectMake(0, 200, tableButton.bounds.size.width, tableButton.bounds.size.height);
    tableButton.center = CGPointMake(self.view.center.x, tableButton.center.y);
    [tableButton addTarget:self action:@selector(tableButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tableButton];
}

/**
 设置导航栏
 */
- (void)setupNavigationBar {
    
    self.title = @"首页";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - ResponseAction
- (void)pushButtonAction:(UIButton *)sender {
    
    WTPushtViewController *pushtViewController = [WTPushtViewController new];
    [self.navigationController pushViewController:pushtViewController animated:YES];
}

- (void)tableButtonAction:(UIButton *)sender {
    
    WTTableViewController *tableViewController = [WTTableViewController new];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

@end
