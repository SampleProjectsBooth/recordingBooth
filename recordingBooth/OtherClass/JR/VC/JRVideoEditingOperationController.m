//
//  JRVideoEditingOperationController.m
//  recordingBooth
//
//  Created by 丁嘉睿 on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "JRVideoEditingOperationController.h"
#import "JRClipVideoEditingViewController.h"
#import "JRVideoPreviewViewController.h"

@interface JRVideoEditingOperationController ()
{
    NSArray *_assets;
    NSUInteger _editType;
}

@end

@implementation JRVideoEditingOperationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self setNavigationBarHidden:YES];
}

- (instancetype)initWithAssets:(NSArray<AVAsset *> *)assets EditType:(NSUInteger)editType
{
    self = [super init];
    if (self) {
        _assets = assets;
        _editType = editType;
        [self _createCustomInit];
    } return self;
}

- (instancetype)initWithClipAsset:(AVAsset *)ClipAsset
{
    if (ClipAsset) {
        return [self initWithAssets:@[ClipAsset] EditType:0];
    }
    return nil;
}

- (instancetype)initWithEditAsset:(NSArray<AVAsset *> *)EditAsset
{
    return [self initWithAssets:EditAsset EditType:1];
}


#pragma mark - Setter And Getter
- (void)setMinClippingDuration:(double)minClippingDuration
{
    _minClippingDuration = minClippingDuration;
    JRClipVideoEditingViewController *vc = [self.viewControllers firstObject];
    vc.minClippingDuration = minClippingDuration;
}

- (void)setMaxClippingDuration:(double)maxClippingDuration
{
    _maxClippingDuration = maxClippingDuration;
    JRClipVideoEditingViewController *vc = [self.viewControllers firstObject];
    vc.maxClippingDuration = maxClippingDuration;
}

#pragma mark - Private Methods
- (void)_createCustomInit
{
    [self _defaultData];
    JRVideoPlayerViewController *vc = nil;
    if (_editType == 0) {
        AVAsset *asset = [_assets firstObject];
        JRClipVideoEditingViewController *ClipVideoVC = [[JRClipVideoEditingViewController alloc] initWithVideoAsset:asset placeholderImage:[asset lf_firstImage:nil]];
        vc = ClipVideoVC;
    } else {
        JRVideoPreviewViewController *previewVideoVC = [[JRVideoPreviewViewController alloc] initWithAssets:_assets];
        vc = previewVideoVC;
    }
    [self pushViewController:vc animated:YES];
}

- (void)_defaultData
{
    _autoSavePhotoAlbum = YES;
    _presetQuality = AVAssetExportPresetHighestQuality;
    _videoType = AVFileTypeQuickTimeMovie;
    _minClippingDuration = 1.f;
    if (_editType == 0) {
        AVAsset *asset = [_assets firstObject];
        _maxClippingDuration = CMTimeGetSeconds(asset.duration);
    }
}

@end
