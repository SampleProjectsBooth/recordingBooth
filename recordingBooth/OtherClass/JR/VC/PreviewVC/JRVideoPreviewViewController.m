//
//  JRVideoPreviewViewController.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/13.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoPreviewViewController.h"
#import "JRVideoClipInfo.h"
#import "JRHorizontalCollectioView.h"
#import "LFVideoEditingController.h"

@interface JRVideoPreviewViewController () <JRHorizontalCollectioViewDelegate, LFVideoEditingControllerDelegate>

@property (nonatomic, weak) JRHorizontalCollectioView *collectionView;

@property (nonatomic, assign) NSUInteger selectIndex;

@property (nonatomic, strong) LFAVAssetData *assetData;

/** 需要保存到编辑数据 */
@property (nonatomic, strong) LFVideoEdit *videoEdit;

@property (nonatomic, weak) id<VideoPlayerMergeOperationDelegate>mergeOperationDelegate;
@end

@implementation JRVideoPreviewViewController

#pragma mark - ViewController Life And Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.    for (AVAsset *assetObj in dataSources) {
}

- (instancetype)initWithAssets:(NSArray<AVAsset *> *)assets
{
    self = [super initWithPlaceholderImage:nil];
    if (self) {
        [self _createJRCollectionView];
        for (AVAsset *assetObj in assets) {
            JRVideoClipInfo *videoInfo = [JRVideoClipInfo new];
            videoInfo.asset = assetObj;
            [self.collectionView addJRVideoClipInfo:videoInfo];
        }
        [self createVideoSession];
    } return self;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat bottom = 20.f;
    if (@available(iOS 11.0, *)) {
        bottom += self.view.safeAreaInsets.bottom;
    }
    CGRect rect = self.collectionView.frame;
    rect.origin.y = CGRectGetHeight(self.view.frame) - bottom - self.collectionView.height;
    rect.size.width = CGRectGetWidth(self.view.frame);
    self.collectionView.frame = rect;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self play];
}

- (void)dealloc
{
    self.assetData = nil;
}

- (void)setOperationDelegate:(id<VideoPlayerOperationDelegate>)operationDelegate
{
    [super setOperationDelegate:operationDelegate];
    self.mergeOperationDelegate = operationDelegate;
}

#pragma mark - Public Methods
- (void)completeButtonAction
{
    if ([self.mergeOperationDelegate respondsToSelector:@selector(didFinishMergeOperation:asset:audioMix:videoComposition:)]) {
        [self.mergeOperationDelegate didFinishMergeOperation:self asset:self.assetData.composition audioMix:self.assetData.audioMix videoComposition:self.assetData.videoComposition];
    }
}

#pragma mark - Private Methods
- (void)_createJRCollectionView
{
    JRHorizontalCollectioView *view = [[JRHorizontalCollectioView alloc] initWithFrame:CGRectZero];
    view.delegate = self;
    [self.view addSubview:view];
    self.collectionView = view;
    
}

- (void)createVideoSession
{
    NSArray *assets = self.collectionView.dataSource;
    if (assets.count > 0) {
        JRVideoClipInfo *first = [assets firstObject];
        LFVideoSession *videoSession = [[LFVideoSession alloc] initWithAsset:first.asset];
        CMTimeShow(first.asset.duration);
        NSUInteger i = 1;
        while (i<assets.count) {
            JRVideoClipInfo *assetObj = assets[i];
            LFVideoMergeCommand *mergeCommand = [[LFVideoMergeCommand alloc] initWithAssetData:videoSession.assetData asset:assetObj.asset];
            [videoSession addCommand:mergeCommand];
            i ++;
        }
        [videoSession execute];
        self.assetData = videoSession.assetData;
        [self setAsset:videoSession.assetData.composition];
    }

}

/**
 更新asset

 @param asset asset
 */
- (void)_replaceDataSourcesWithAssat:(AVAsset *)asset
{
    if ((self.selectIndex >= 0) && (self.selectIndex<self.collectionView.dataSource.count)) {
        JRVideoClipInfo *obj = [JRVideoClipInfo new];
        obj.asset = asset;
        [self.collectionView replaceObjectAtIndex:self.selectIndex withObject:obj];
        [self createVideoSession];
    }
    self.selectIndex = -10086;
}

#pragma mark - VideoPlayerDelegate

- (void)didReayToplay:(double)duration
{
    [self play];
}

- (void)pregessToPlay:(double)duration
{
    
}

- (void)didEndToplay
{
    [self play];
}


#pragma mark - JRHorizontalCollectioViewDelegate
- (void)horizontalCollectioView:(JRHorizontalCollectioView *)collectioView didSelectItemAtIndex:(NSUInteger)index
{
    self.selectIndex = index;
    // Do any additional setup after select someone.
    /** 操作结束后需要更新_replaceDataSourcesWithAssat： */
    JRVideoClipInfo *info = [collectioView.dataSource objectAtIndex:index];
    
    LFVideoEditingController *lfVideoEditVC = [[LFVideoEditingController alloc] init];
    lfVideoEditVC.delegate = self;
        lfVideoEditVC.operationType = LFVideoEditOperationType_draw | LFVideoEditOperationType_sticker | LFVideoEditOperationType_text | LFVideoEditOperationType_audio | LFVideoEditOperationType_filter;
    //    lfVideoEditVC.minClippingDuration = 3;
    if (self.videoEdit) {
        lfVideoEditVC.videoEdit = self.videoEdit;
    } else {
        [lfVideoEditVC setVideoAsset:info.asset placeholderImage:info.image];
    }
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:lfVideoEditVC];
    [navi setNavigationBarHidden:YES];
    [self presentViewController:navi animated:NO completion:nil];
}

#pragma mark - LFVideoEditingControllerDelegate
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didCancelPhotoEdit:(LFVideoEdit *)videoEdit
{
    [videoEditingVC.navigationController dismissViewControllerAnimated:NO completion:nil];
}
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didFinishPhotoEdit:(LFVideoEdit *)videoEdit
{
    [videoEditingVC.navigationController dismissViewControllerAnimated:NO completion:nil];
    if (videoEdit && videoEdit.editFinalURL) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoEdit.editFinalURL options:nil];
        [self _replaceDataSourcesWithAssat:asset];
    }
    self.videoEdit = videoEdit;
}


@end
