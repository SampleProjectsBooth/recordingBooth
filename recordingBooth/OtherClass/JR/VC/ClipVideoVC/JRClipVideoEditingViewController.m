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

@property (nonatomic, weak) UIButton *aPlayBtn;

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

@end

@implementation JRClipVideoEditingViewController

- (instancetype)initWithVideoAsset:(AVAsset *)videoAsset placeholderImage:(nullable UIImage *)placeholderImage
{
    self = [self initWithPlaceholderImage:placeholderImage];
    if (self) {
        self.asset = videoAsset;
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
    
    self.aPlayBtn.center = CGPointMake(CGRectGetMidX(self.videoPlayerViewFrame), CGRectGetMidY(self.videoPlayerViewFrame));
    
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

- (void)dealloc
{
    [self.aVideoTrimmerView removeFromSuperview];
    self.aVideoTrimmerView = nil;
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
    
    
    /** 播放按钮 */
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.selected = NO;
    button.enabled = NO;
    button.hidden = YES;
    button.frame = CGRectMake(0.f, 0.f, 50.f, 50.f);
    [button setImage:[UIImage jr_getImgFromJRVideoEditingBundleWithName:@"pause.png"] forState:(UIControlStateSelected)];
    [button setImage:[UIImage jr_getImgFromJRVideoEditingBundleWithName:@"errorPlay.png"] forState:(UIControlStateDisabled)];
    [button setImage:[UIImage jr_getImgFromJRVideoEditingBundleWithName:@"play.png"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(_vdeioPlayAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    self.aPlayBtn = button;
    
    /** 裁剪按钮 */
    UIButton *button1 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button1.frame = CGRectMake(0.f, 0.f, 60.f, 30.f);
    [button1 setTitle:@"裁剪" forState:(UIControlStateNormal)];
    [button1 addTarget:self action:@selector(_clipVideoAction) forControlEvents:(UIControlEventTouchUpInside)];
    [button1 setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.3]];
    [self.view addSubview:button1];
    self.clipBtn = button1;

    JRHorizontalCollectioView *vi = [[JRHorizontalCollectioView alloc] initWithFrame:self.view.bounds];
    vi.delegate = self;
    [self.view addSubview:vi];
    self.collectionView = vi;
}


- (void)_vdeioPlayAction
{
    [self reset];
    [self seekToTime:self.startTime];
    self.aPlayBtn.selected = !self.aPlayBtn.selected;
    if (self.aPlayBtn.selected) {
        [self play];
    } else {
        [self pause];
    }
}

/** 裁剪 */
- (void)_clipVideoAction
{
    CGFloat width = CGRectGetWidth(self.aVideoTrimmerView.frame);
    
    CGFloat location = self.startTime * (self.aVideoTrimmerView.frame.size.width/self.totalDuration);
    CGFloat length = (self.endTime * (self.aVideoTrimmerView.frame.size.width/self.totalDuration)) - location;

    NSRange currentRange = NSMakeRange(location, length);
    
    if (currentRange.location == width) {
        return;
    }
    
    CGFloat currentWidth = NSMaxRange(currentRange);
    CGFloat margin = width - currentWidth;
    if (margin > self.aVideoTrimmerView.controlMinWidth*3/2) {
        margin = self.aVideoTrimmerView.controlMinWidth;
    }
    
    NSRange replaceRange = NSMakeRange(currentWidth, margin);
    
    double start = self.startTime;
    double end = self.endTime;
    
    JRClipInfo *clipInfo = [JRClipInfo new];
    clipInfo.startTime = start;
    clipInfo.endTime = end;
    clipInfo.clipRange = currentRange;
    JRVideoClipInfo *videoInfo = [JRVideoClipInfo new];
    videoInfo.clipInfo = clipInfo;
    [self.aVideoTrimmerView setGridRange:replaceRange animated:NO];
    [self lf_videoTrimmerViewDidBeginResizing:self.aVideoTrimmerView gridRange:replaceRange];
    [self lf_videoTrimmerViewDidEndResizing:self.aVideoTrimmerView gridRange:replaceRange];
    
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

#pragma mark - Setter And Getter

#pragma mark - VideoPlayerProtocol
- (void)didReayToplay:(double)duration
{
    self.aPlayBtn.hidden = NO;
    self.aPlayBtn.enabled = YES;
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
    [self.aVideoTrimmerView setGridRange:firstRange animated:NO];
    [self lf_videoTrimmerViewDidBeginResizing:self.aVideoTrimmerView gridRange:firstRange];
    [self lf_videoTrimmerViewDidEndResizing:self.aVideoTrimmerView gridRange:firstRange];
}

- (void)pregessToPlay:(double)duration
{
    self.aVideoTrimmerView.progress = duration/self.totalDuration;
    if (duration > self.endTime) {
        [self pause];
        [self didEndToplay];
    }
}

- (void)didEndToplay
{
    self.aPlayBtn.hidden = NO;
    self.aPlayBtn.selected = NO;
    
    [self reset];
    [self seekToTime:self.startTime];
}

- (void)didRefusedPlay:(NSError *)error
{
    self.aPlayBtn.hidden = NO;
    self.aPlayBtn.enabled = NO;
}

- (void)cancel
{
    JRVideoEditingOperationController *nav = (JRVideoEditingOperationController *)self.navigationController;
    if ([nav.operationDelegate respondsToSelector:@selector(videoEditingOperationControllerDidCancel:error:)]) {
        [nav.operationDelegate videoEditingOperationControllerDidCancel:nav error:nil];
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
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"请裁剪视频" preferredStyle:(UIAlertControllerStyleAlert)];
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
    [self.aPlayBtn setSelected:NO];
    [trimmerView setHiddenProgress:YES];
    trimmerView.progress = 0;
    [self lf_videoTrimmerViewDidResizing:trimmerView gridRange:gridRange];
    
}

- (void)lf_videoTrimmerViewDidResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    double startTime = MIN(lfme_videoDuration(gridRange.location/CGRectGetWidth(trimmerView.frame)*self.totalDuration), self.totalDuration);

    double endTime = MIN(lfme_videoDuration(NSMaxRange(gridRange)/CGRectGetWidth(trimmerView.frame)*self.totalDuration), self.totalDuration);

    [self seekToTime:((self.startTime != startTime) ? startTime : endTime)];
    
    self.startTime = lfme_videoDuration(startTime);
    self.endTime = lfme_videoDuration(endTime);
    
    trimmerView.progress = startTime;

}

- (void)lf_videoTrimmerViewDidEndResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange
{
    [trimmerView setHiddenProgress:NO];
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
    self.aPlayBtn.enabled = YES;
    [self.aVideoTrimmerView setGridRange:range animated:NO];
    [self lf_videoTrimmerViewDidBeginResizing:self.aVideoTrimmerView gridRange:range];
    [self lf_videoTrimmerViewDidEndResizing:self.aVideoTrimmerView gridRange:range];
}
@end
