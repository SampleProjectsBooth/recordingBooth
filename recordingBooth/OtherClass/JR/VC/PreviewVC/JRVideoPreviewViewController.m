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
#import "JRVideoEditingOperationController.h"

@interface JRVideoPreviewViewController () <JRHorizontalCollectioViewDelegate, LFVideoEditingControllerDelegate>

@property (nonatomic, weak) JRHorizontalCollectioView *collectionView;

@property (nonatomic, assign) NSUInteger selectIndex;

@property (nonatomic, strong) LFAVAssetData *assetData;

/** 需要保存到编辑数据 */
@property (nonatomic, strong) LFVideoEdit *videoEdit;

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
        [self _createVideoSession];
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


#pragma mark - Public Methods


#pragma mark - Private Methods
- (void)_createJRCollectionView
{
    JRHorizontalCollectioView *view = [[JRHorizontalCollectioView alloc] initWithFrame:CGRectZero];
    view.delegate = self;
    [self.view addSubview:view];
    self.collectionView = view;
    
}

- (void)_createVideoSession
{
    NSArray *assets = self.collectionView.dataSource;
    if (assets.count > 0) {
        JRVideoClipInfo *first = [assets firstObject];
        LFVideoSession *videoSession = [[LFVideoSession alloc] initWithAsset:first.asset];
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
        [self _createVideoSession];
    }
    self.selectIndex = -10086;
}

- (void)_saveVideo:(NSURL *)url{
    
    if (url) {
        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
        if (compatible)
        {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(_savedVideoPath:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}


//保存视频完成之后的回调
- (void)_savedVideoPath:(NSString *)path didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    NSString *name = @"保存视频成功";
    if (error) {
        name = [NSString stringWithFormat:@"保存视频失败%@", error.localizedDescription];
        
    }
    UIAlertController *ale = [UIAlertController alertControllerWithTitle:nil message:name preferredStyle:(UIAlertControllerStyleAlert)];
    [ale addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:ale animated:YES completion:nil];
}

#pragma mark - VideoPlayerProtocol

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

- (void)cancel
{
    JRVideoEditingOperationController *nav = (JRVideoEditingOperationController *)self.navigationController;
    if ([nav.operationDelegate respondsToSelector:@selector(videoEditingOperationControllerDidCancel:)]) {
        [nav.operationDelegate videoEditingOperationControllerDidCancel:nav];
    }
}

- (void)finish
{
    JRVideoEditingOperationController *nav = (JRVideoEditingOperationController *)self.navigationController;

    
    NSURL *url = nav.videoUrl;
    if (!url) {
        if ([nav.operationDelegate respondsToSelector:@selector(videoEditingOperationController:didFinishEditUrl:error:)]) {
            [nav.operationDelegate videoEditingOperationController:nav didFinishEditUrl:nil error:[NSError errorWithDomain:@"url is error" code:-90 userInfo:@{NSLocalizedDescriptionKey:@"视频存储地址无效"}]];
        }
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:url.path]) {
        [fm removeItemAtURL:url error:nil];
    }
    

    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"正在储存..." preferredStyle:(UIAlertControllerStyleAlert)];
    [self presentViewController:alertCon animated:YES completion:^{
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:self.assetData.composition presetName:nav.presetQuality];
        exportSession.outputURL = url;
        exportSession.outputFileType = nav.videoType;
        exportSession.audioMix = self.assetData.audioMix;
        exportSession.videoComposition = self.assetData.videoComposition;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [alertCon dismissViewControllerAnimated:YES completion:^{
                }];
                switch ([exportSession status]) {
                    case AVAssetExportSessionStatusFailed:
                        if ([nav.operationDelegate respondsToSelector:@selector(videoEditingOperationController:didFinishEditUrl:error:)]) {
                            [nav.operationDelegate videoEditingOperationController:nav didFinishEditUrl:nil error:exportSession.error];
                        }
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        if ([nav.operationDelegate respondsToSelector:@selector(videoEditingOperationController:didFinishEditUrl:error:)]) {
                            [nav.operationDelegate videoEditingOperationController:nav didFinishEditUrl:nil error:[NSError errorWithDomain:@"url is error" code:-90 userInfo:@{NSLocalizedDescriptionKey:@"操作已取消"}]];
                        }
                        break;
                    case AVAssetExportSessionStatusCompleted:
                        if (nav.autoSavePhotoAlbum) {
                            [self _saveVideo:url];
                        }
                        if ([nav.operationDelegate respondsToSelector:@selector(videoEditingOperationController:didFinishEditUrl:error:)]) {
                            [nav.operationDelegate videoEditingOperationController:nav didFinishEditUrl:url error:nil];
                        }
                        NSLog(@"Export completed : %@", [url path]);
                        break;
                    default:
                        break;
                }
            });
        }];
    }];
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
    JRVideoEditingOperationController *nav = (JRVideoEditingOperationController *)self.navigationController;
    if (nav.videoEditingLibrary) {
        nav.videoEditingLibrary(lfVideoEditVC);
    }
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
