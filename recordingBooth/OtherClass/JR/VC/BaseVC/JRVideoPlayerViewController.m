//
//  JRVideoPlayerViewController.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/7.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoPlayerViewController.h"
#import "LFVideoPlayerLayerView.h"
#import "LFVideoPlayer.h"

@interface JRVideoPlayerViewController () <LFVideoPlayerDelegate>

@property (nonatomic, strong) LFVideoPlayer *aVideoPlayer;

@property (nonatomic, weak) LFVideoPlayerLayerView *aVideoPlayerLayerView;

@property (nonatomic, strong) UIImage *image;

@end

@implementation JRVideoPlayerViewController

#pragma mark - ViewController Life And Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];

    [self _createVideoPlayerView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect rect = self.aVideoPlayerLayerView.frame;
    if (self.aVideoPlayer) {
        rect = AVMakeRectWithAspectRatioInsideRect(self.aVideoPlayer.size, self.view.bounds);
    }
    _videoPlayerViewFrame = self.aVideoPlayerLayerView.frame = rect;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.aVideoPlayer pause];
}

- (void)dealloc
{
    [self.aVideoPlayer pause];
    [self.aVideoPlayerLayerView removeFromSuperview];
    self.aVideoPlayer = nil;
    self.image = nil;
}

/** 只允许竖屏 */
- (BOOL)shouldAutorotate
{
    return YES;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait);
}
/** 隐藏状态栏 */
-(BOOL)prefersStatusBarHidden
{
    return NO;
}


#pragma mark - Public Methods

- (instancetype)initWithPlaceholderImage:(nullable UIImage *)placeholderImage
{
    self = [super init];
    if (self) {
        self.image = placeholderImage;
    } return self;
}

- (void)play
{
    [self.aVideoPlayer play];
}

- (void)pause
{
    [self.aVideoPlayer pause];
}

-(void)reset
{
    [self.aVideoPlayer resetDisplay];
}

- (void)seekToTime:(CGFloat)time
{
    [self.aVideoPlayer seekToTime:time];
}


#pragma mark - Setter And Getter
- (void)setAsset:(AVAsset *)asset
{
    _asset = asset;
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] firstObject]) {
        if (!self.aVideoPlayer) {
            self.aVideoPlayer = [[LFVideoPlayer alloc] init];
            self.aVideoPlayer.delegate = self;
        }
        [self.aVideoPlayer setAsset:asset];
        /** size在rect的里面中心的frame */
        CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.aVideoPlayer.size, self.view.bounds);
        self.aVideoPlayerLayerView.frame = rect;
        [self.aVideoPlayer resetDisplay];
    } else {
        [self LFVideoPlayerFailedToPrepare:nil error:[NSError errorWithDomain:@"asset is not video tracks" code:-707 userInfo:@{NSLocalizedDescriptionKey:@"无效资源"}]];
    }
}

#pragma mark - Class Methods
+ (NSString *)createDirectoryUnderTemporaryDirectory:(NSString *)name file:(NSString *)file
{
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];
    NSString *path = NSTemporaryDirectory();
    if (name.length > 0) {
        path = [path stringByAppendingString:name];
    }
    BOOL exist = [fm fileExistsAtPath:path];
    if (!exist) {
        if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"createMediaFolder error: %@ \n",[error localizedDescription]);
        }
    }
    if (file.length > 0) {
        path = [path stringByAppendingPathComponent:file];
    }
    return path;
}

#pragma mark - Private Methods
- (void)_createVideoPlayerView
{
    CGRect rect = self.view.bounds;
    if (self.image) {
        rect = AVMakeRectWithAspectRatioInsideRect(self.image.size, self.view.bounds);
    }
    LFVideoPlayerLayerView *playerLayerView = [[LFVideoPlayerLayerView alloc] initWithFrame:rect];
    playerLayerView.image = self.image;
    [self.view addSubview:playerLayerView];
    self.aVideoPlayerLayerView  = playerLayerView;
    
}


#pragma mark - LFVideoPlayerDelegate
/** 画面回调 */
- (void)LFVideoPlayerLayerDisplay:(LFVideoPlayer *)player avplayer:(AVPlayer *)avplayer
{
    [self.aVideoPlayerLayerView setPlayer:avplayer];
}

/** 可以播放 */
- (void)LFVideoPlayerReadyToPlay:(LFVideoPlayer *)player duration:(double)duration
{
    [self didReayToplay:duration];
}

- (void)LFVideoPlayerSyncScrub:(LFVideoPlayer *)player duration:(double)duration
{
    [self pregessToPlay:duration];
}

/** 播放结束 */
- (void)LFVideoPlayerPlayDidReachEnd:(LFVideoPlayer *)player
{
    [self didEndToplay];
}

/** 错误回调 */
- (void)LFVideoPlayerFailedToPrepare:(LFVideoPlayer *)player error:(NSError *)error
{
    [self didRefusedPlay:error];
}

#pragma mark - VideoPlayerProtocol
- (void)didReayToplay:(double)duration
{

}

- (void)pregessToPlay:(double)duration
{
    
}

- (void)didEndToplay
{

}

- (void)didRefusedPlay:(NSError *)error
{
    
}

@end
