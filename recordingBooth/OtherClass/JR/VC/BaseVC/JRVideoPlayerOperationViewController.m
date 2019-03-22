//
//  JRVideoPlayerOperationViewController.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/21.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoPlayerOperationViewController.h"

@interface JRVideoPlayerOperationViewController ()

@property (nonatomic, weak) UIButton *cancelBtn;

@property (nonatomic, weak) UIButton *completeBtn;

@end

@implementation JRVideoPlayerOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _createVideoPlayerCustomView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat topMargin = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame);
    if (@available(iOS 11.0, *)) {
        topMargin = self.view.safeAreaInsets.top;
    }
    topMargin += 10.f;
    
    CGRect rectBtn = (CGRect){20.f, topMargin, 40.f, 20.f};
    self.cancelBtn.frame = rectBtn;
    
    CGRect rect1 = (CGRect){CGRectGetWidth(self.view.frame) - 40.f - 20.f, topMargin, 40.f, 20.f};
    self.completeBtn.frame = rect1;
    
}

#pragma mark - Private Methods
- (void)_createVideoPlayerCustomView
{
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setTitle:@"取消" forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(_cancelAction)
     forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.3]];
    [self.view addSubview:button];
    self.cancelBtn = button;
    
    UIButton *button1 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button1 setTitle:@"完成" forState:(UIControlStateNormal)];
    [button1 setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.3]];
    [button1 addTarget:self action:@selector(_completeAction)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    self.completeBtn = button1;
}

- (void)_cancelAction
{
    if ([self.operationDelegate respondsToSelector:@selector(dissminssVideoPlayerViewController:)]) {
        [self.operationDelegate dissminssVideoPlayerViewController:self];
    }
}

- (void)_completeAction
{
    [self completeButtonAction];
    if ([self.operationDelegate respondsToSelector:@selector(didFinishOperation:asset:)]) {
        [self.operationDelegate didFinishOperation:self asset:self.asset];
    }
}

- (void)completeButtonAction
{
    
}

@end
