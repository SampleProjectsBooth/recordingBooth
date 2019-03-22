//
//  JRVideoEditingOperationController.m
//  recordingBooth
//
//  Created by 丁嘉睿 on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "JRVideoEditingOperationController.h"
#import "JRClipVideoEditingViewController.h"

@interface JRVideoEditingOperationController ()
{
    AVAsset *_asset;
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

- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        [self _createCustomInit];
    } return self;
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
    JRClipVideoEditingViewController *vc = [[JRClipVideoEditingViewController alloc] initWithVideoAsset:_asset placeholderImage:[_asset lf_firstImage:nil]];
    [self setViewControllers:@[vc]];
}

- (void)_defaultData
{
    _autoSavePhotoAlbum = YES;
    _presetQuality = AVAssetExportPresetHighestQuality;
    _videoType = AVFileTypeQuickTimeMovie;
    _minClippingDuration = 1.f;
    _maxClippingDuration = CMTimeGetSeconds(_asset.duration);
}

@end
