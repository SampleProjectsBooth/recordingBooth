//
//  JRClipVideoEditingViewController.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRClipVideoEditingViewController.h"
#import "LFVideoPlayerLayerView.h"
#import "LFVideoTrimmerView.h"
#import "JRVideoClipInfo.h"
#import "JRHorizontalCollectioView.h"
#import "JRVideoPreviewViewController.h"
#import "JRVideoEditingOperationController.h"

@interface JRClipVideoEditingViewController () <LFVideoTrimmerViewDelegate, JRHorizontalCollectioViewDelegate>

@property (nonatomic, weak) LFVideoTrimmerView *aVideoTrimmerView;

@property (nonatomic, weak) UIView *backgroundTrimmerView;

@property (nonatomic, assign) double totalDuration;
/** 开始播放时间 */
@property (nonatomic, assign) double startTime;
/** 结束播放时间 */
@property (nonatomic, assign) double endTime;

@property (nonatomic, strong) NSMutableArray *videoClipInfos;

@property (nonatomic, strong) NSMutableArray *ranges;

@property (nonatomic, weak) UIButton *clipBtn;

@property (nonatomic, weak) JRHorizontalCollectioView *collectionView;

@property (nonatomic, assign) BOOL noTag;

@property (nonatomic, assign) NSRange currentRange;

@end

@implementation JRClipVideoEditingViewController

- (instancetype)initWithVideoAsset:(AVAsset *)videoAsset placeholderImage:(nullable UIImage *)placeholderImage
{
    self = [self initWithPlaceholderImage:placeholderImage];
    if (self) {
        self.asset = videoAsset;
        self.totalDuration = CMTimeGetSeconds(videoAsset.duration);
    } return self;
}

- (instancetype)initWithPlaceholderImage:(UIImage *)placeholderImage
{
    self = [super initWithPlaceholderImage:placeholderImage];
    if (self) {
        self.minClippingDuration = 1.0;
        self.endTime = 0;
        self.startTime = 0;
        self.videoClipInfos = @[].mutableCopy;
        self.ranges = @[].mutableCopy;
    } return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self _createPlayerView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat bottom = 50.f;
    if (@available(iOS 11.0, *)) {
        bottom += self.view.safeAreaInsets.bottom;
    }
    CGRect rect = self.aVideoTrimmerView.frame;
    rect.origin.y = CGRectGetHeight(self.view.bounds) - bottom - CGRectGetHeight(rect);
    self.aVideoTrimmerView.frame = rect;
    
    CGRect bFrame = self.backgroundTrimmerView.frame;
    bFrame.origin.y = rect.origin.y-5.f;
    bFrame.origin.x = rect.origin.x-5.f;
    self.backgroundTrimmerView.frame = bFrame;
    
    CGRect c = self.clipBtn.frame;
    c.origin.y = CGRectGetMaxY(rect) + 10.f;
    c.origin.x = CGRectGetWidth(self.view.frame) - CGRectGetWidth(c) - 20.f;
    self.clipBtn.frame = c;

    CGRect fra = self.collectionView.frame;
    fra.origin.y = CGRectGetMinY(rect) - self.collectionView.height - 10.f;
    self.collectionView.frame = fra;
    
    [self.view bringSubviewToFront:self.collectionView];
    [self.view bringSubviewToFront:self.aVideoTrimmerView];
    [self.view bringSubviewToFront:self.clipBtn];

}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self pause];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self play];
}

- (void)dealloc
{
    [self.aVideoTrimmerView removeFromSuperview];
    self.aVideoTrimmerView = nil;
}

#pragma mark - Setter And Getter
- (void)setMinClippingDuration:(double)minClippingDuration
{
    if (self.totalDuration < minClippingDuration) {
        minClippingDuration = self.totalDuration;
    }
    _minClippingDuration = minClippingDuration;
}

- (void)setMaxClippingDuration:(double)maxClippingDuration
{
    if (self.minClippingDuration > maxClippingDuration) {
        maxClippingDuration = self.totalDuration;
    }
    if (maxClippingDuration > self.totalDuration) {
        maxClippingDuration = self.totalDuration;
    }
    _maxClippingDuration = maxClippingDuration;
}

#pragma mark - Private Methods
- (void)_createPlayerView
{
    CGFloat margin = 40.f;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(margin-5, 0.f, CGRectGetWidth(self.view.bounds)-(margin-5)*2, 90.f)];
    view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [self.view addSubview:view];
    self.backgroundTrimmerView = view;
    
    LFVideoTrimmerView *trimmerView = [[LFVideoTrimmerView alloc] initWithFrame:CGRectMake(margin, 0.f, CGRectGetWidth(self.view.bounds)-margin*2, 80.f)];
    trimmerView.delegate = self;
    trimmerView.controlMinWidth = (CGRectGetWidth(self.view.bounds)-margin*2)/4;
    trimmerView.enabledLeftCorner = NO;
    [self.view addSubview:trimmerView];
    self.aVideoTrimmerView = trimmerView;
    [self.aVideoTrimmerView setAsset:self.asset];
    
    /** 裁剪按钮 */
    UIButton *button1 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button1.frame = CGRectMake(0.f, 0.f, 60.f, 30.f);
    [button1 setTitle:@"Clip" forState:(UIControlStateNormal)];
    [button1 addTarget:self action:@selector(_clipVideoAction) forControlEvents:(UIControlEventTouchUpInside)];
    [button1 setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.3]];
    [self.view addSubview:button1];
    self.clipBtn = button1;

    JRHorizontalCollectioView *vi = [[JRHorizontalCollectioView alloc] initWithFrame:self.view.bounds];
    vi.delegate = self;
    [self.view addSubview:vi];
    self.collectionView = vi;
}

/** 裁剪 */
- (void)_clipVideoAction
{
    [self pause];
    
    CGFloat width = CGRectGetWidth(self.aVideoTrimmerView.frame);
    
    NSRange currentRange = self.currentRange;

    if (currentRange.location == width) {
        return;
    }
    
    CGFloat currentWidth = NSMaxRange(currentRange);
    
    CGFloat margin = width - currentWidth;
    /** 如果剩余裁剪区域超过最小值的3/2，取最小值 */
    if (margin > self.aVideoTrimmerView.controlMinWidth*3/2) {
        margin = self.aVideoTrimmerView.controlMinWidth;
    }
    
    /** 裁剪之后的区域 */
    NSRange replaceRange = NSMakeRange(currentWidth, margin);
    [self _changeTrimmerView:replaceRange];

    /** ------------- 下面就开始裁剪了 ------------ */
    
    /** 裁剪前后时间 */
    double start = MIN(currentRange.location/width*self.totalDuration, self.totalDuration);
    
    double end = MIN(NSMaxRange(currentRange)/width*self.totalDuration, self.totalDuration);

    
    JRClipInfo *clipInfo = [JRClipInfo new];
    clipInfo.startTime = start;
    clipInfo.endTime = end;
    clipInfo.clipRange = currentRange;
    JRVideoClipInfo *videoInfo = [JRVideoClipInfo new];
    videoInfo.clipInfo = clipInfo;
    
    if (margin < self.aVideoTrimmerView.controlMinWidth) {
        self.clipBtn.enabled = NO;
        self.aVideoTrimmerView.userInteractionEnabled = NO;
    }
    
    CMTime startCM = CMTimeMakeWithSeconds(videoInfo.clipInfo.startTime, self.asset.duration.timescale);
    CMTime durationCM = CMTimeMakeWithSeconds(videoInfo.clipInfo.endTime-videoInfo.clipInfo.startTime, self.asset.duration.timescale);
    
    CMTimeRange range = CMTimeRangeMake(startCM, durationCM);
    LFVideoSession *videoSession = [[LFVideoSession alloc] initWithAsset:self.asset];
    LFVideoClipCommand *clipCommad = [[LFVideoClipCommand alloc] initWithAssetData:videoSession.assetData timeRange:range];
    [videoSession addCommand:clipCommad];
    [videoSession execute];
    
    videoInfo.asset = videoSession.assetData.composition;
    [self.collectionView addJRVideoClipInfo:videoInfo];

}

- (void)_changeTrimmerView:(NSRange)range
{
    [self.aVideoTrimmerView setGridRange:range animated:NO];
    [self lf_videoTrimmerViewDidBeginResizing:self.aVideoTrimmerView gridRange:range];
    [self lf_videoTrimmerViewDidResizing:self.aVideoTrimmerView gridRange:range];
    [self lf_videoTrimmerViewDidEndResizing:self.aVideoTrimmerView gridRange:range];
}

#pragma mark - Setter And Getter

#pragma mark - VideoPlayerProtocol
- (void)didReayToplay:(double)duration
{
    self.startTime = 0;
    self.totalDuration = self.endTime = duration;
    [self.aVideoTrimmerView setHiddenProgress:NO];
    self.aVideoTrimmerView.progress = 0;
    
    self.aVideoTrimmerView.controlMinWidth = CGRectGetWidth(self.aVideoTrimmerView.frame) * (self.minClippingDuration / self.totalDuration);
    if (self.maxClippingDuration > 0.f) {
        self.aVideoTrimmerView.controlMaxWidth = CGRectGetWidth(self.aVideoTrimmerView.frame) * (self.maxClippingDuration / self.totalDuration);
    }
    NSRange firstRange = NSMakeRange(0, self.aVideoTrimmerView.controlMinWidth);
    self.noTag = YES;
    [self _changeTrimmerView:firstRange];
    [self play];

}

- (void)pregessToPlay:(double)duration
{
    self.aVideoTrimmerView.progress = duration/self.totalDuration;
    if (duration >= self.endTime) {
        [self pause];
        self.aVideoTrimmerView.progress = self.startTime/self.totalDuration;
        [self seekToTime:self.startTime];
        [self play];
    }
}

- (void)didEndToplay
{
    [self play];
}

- (void)didRefusedPlay:(NSError *)error
{

}

- (void)cancel
{
    JRVideoEditingOperationController *nav = (JRVideoEditingOperationController *)self.navigationController;
    if ([nav.operationDelegate respondsToSelector:@selector(videoEditingOperationControllerDidCancel:)]) {
        [nav.operationDelegate videoEditingOperationControllerDidCancel:nav];
    }
}

- (void)finish
{
    if (self.collectionView.dataSource.count > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.collectionView.dataSource.count];
        for (NSUInteger i = 0; i < self.collectionView.dataSource.count; i++) {
            JRVideoClipInfo *obj = [self.collectionView.dataSource objectAtIndex:i];
            [array addObject:obj.asset];
        }
        JRVideoPreviewViewController *vc = [[JRVideoPreviewViewController alloc] initWithAssets:[array copy]];
        vc.cancelBtnTitle = @"Back";
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"Tips" message:@"Please clip the video." preferredStyle:(UIAlertControllerStyleAlert)];
        [self presentViewController:alertCon animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertCon dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
}

#pragma mark - LFVideoTrimmerViewDelegate
- (void)lf_videoTrimmerViewDidBeginResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    [self pause];
    [trimmerView setHiddenProgress:YES];
    trimmerView.progress = 0;
    
}

- (void)lf_videoTrimmerViewDidResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    
    double startTime = MIN(gridRange.location/CGRectGetWidth(trimmerView.frame)*self.totalDuration, self.totalDuration);

    double endTime = MIN(NSMaxRange(gridRange)/CGRectGetWidth(trimmerView.frame)*self.totalDuration, self.totalDuration);

    if (!self.noTag) {
        double seekToTime = ((self.startTime != startTime) ? startTime : endTime);
        NSLog(@"seekToTime:%f", seekToTime);
        [self seekToTime:seekToTime];
    } else {
        self.noTag = NO;
    }
    
    self.startTime = lfme_videoDuration(startTime);
    self.endTime = lfme_videoDuration(endTime);
    
    trimmerView.progress = startTime;
}

- (void)lf_videoTrimmerViewDidEndResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    [trimmerView setHiddenProgress:NO];
    [self play];
    self.currentRange = gridRange;
}

#pragma mark - JRHorizontalCollectioViewDelegate
- (BOOL)canRemoveItem
{
    return YES;
}

- (void)horizontalCollectioView:(JRHorizontalCollectioView *)collectioView didDeleteItem:(JRVideoClipInfo *)info
{
    NSRange range = info.clipInfo.clipRange;
    self.aVideoTrimmerView.userInteractionEnabled = YES;
    self.clipBtn.enabled = YES;
    [self _changeTrimmerView:range];
}
@end
