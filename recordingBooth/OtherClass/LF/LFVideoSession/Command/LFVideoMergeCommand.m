//
//  LFVideoMergeCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoMergeCommand.h"

@interface LFVideoMergeCommand ()

@property (nonatomic, strong) AVAsset *mergeAsset;

@end

@implementation LFVideoMergeCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData asset:(AVAsset *)asset
{
    self = [super initWithAssetData:assetData];
    if(self) {
        _mergeAsset = asset;
    }
    
    return self;
}

- (void)execute
{
    if (self.assetData) {
        
        AVMutableComposition *composition = self.assetData.composition;
        
        if (self.mergeAsset) {
            NSError *error = nil;
            
            AVAssetTrack *_assetVideoTrack = nil;
            AVAssetTrack *_assetAudioTrack = nil;
            
            // Check if the asset contains video and audio tracks
            if ([self.mergeAsset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
                _assetVideoTrack = [self.mergeAsset tracksWithMediaType:AVMediaTypeVideo][0];
            }
            if ([self.mergeAsset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
                _assetAudioTrack = [self.mergeAsset tracksWithMediaType:AVMediaTypeAudio][0];
            }
            
            CMTime duration = composition.duration;
            if (_assetVideoTrack) {
                [self.assetData.videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.mergeAsset.duration) ofTrack:_assetVideoTrack atTime:duration error:&error];
            }
            if (_assetAudioTrack) {
                [self.assetData.audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.mergeAsset.duration) ofTrack:_assetAudioTrack atTime:duration error:&error];
            }
            
            self.error = error;
            if (error != nil) {
                NSLog(@"Failed to append %@ : %@", self.mergeAsset, error);
            }            
        }
        
    }
}

@end
