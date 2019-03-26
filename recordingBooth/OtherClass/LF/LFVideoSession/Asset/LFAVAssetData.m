//
//  LFAVAsset.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFAVAssetData.h"
#import <CoreImage/CoreImage.h>


@interface LFAVAssetData ()

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property (nonatomic, strong) AVMutableAudioMix *audioMix;

@property (nonatomic, strong) AVMutableCompositionTrack *videoCompositionTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *audioCompositionTrack;
@property (nonatomic, assign) CGSize videoSize;

@property (nonatomic, strong) CIContext *context;

@property (nonatomic, readonly) AVMutableVideoComposition *internal_videoComposition;

@end

@implementation LFAVAssetData

- (id)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        NSAssert(asset, @"AVAsset is nil.");
        _asset = asset;
        [self loadAsset:asset];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    return [self initWithAsset:asset];
}

- (void)loadAsset:(AVAsset *)asset {
    
    if (asset) {
        
        AVAssetTrack *_assetVideoTrack = nil;
        AVAssetTrack *_assetAudioTrack = nil;
        
        // Check if the asset contains video and audio tracks
        if ([asset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
            _assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        }
        if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
            _assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
        }
        
        CMTime insertionPoint = kCMTimeZero;
        NSError *error = nil;
        
        // Step 1
        // Create a composition with the given asset and insert audio and video tracks into it from the asset
        // Check if a composition already exists, else create a composition using the input asset
        
        self.composition = [AVMutableComposition composition];
        
        // Insert the video and audio tracks from AVAsset
        if (_assetVideoTrack != nil) {
            // 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
            _videoCompositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            // 视频方向
            [_videoCompositionTrack setPreferredTransform:_assetVideoTrack.preferredTransform];
            // 把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
            [_videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:_assetVideoTrack atTime:insertionPoint error:&error];
            
        }
        if (_assetAudioTrack != nil) {
            _audioCompositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            _audioCompositionTrack.preferredTransform = _assetAudioTrack.preferredTransform;
            [_audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:_assetAudioTrack atTime:insertionPoint error:&error];
        }
        
        _videoSize = _videoCompositionTrack.naturalSize;
    }
}

- (AVMutableVideoComposition *)internal_videoComposition
{
    if (_videoComposition == nil) {
        _videoComposition = [AVMutableVideoComposition videoComposition];
        _videoComposition.frameDuration = CMTimeMake(1, 30);
        _videoComposition.renderSize = _videoSize;
    }
    return _videoComposition;
}


- (AVMutableVideoComposition *)videoComposition
{
    if (_videoComposition.instructions.count == 0) {
        return nil;
    }
    return _videoComposition;
}

@end
