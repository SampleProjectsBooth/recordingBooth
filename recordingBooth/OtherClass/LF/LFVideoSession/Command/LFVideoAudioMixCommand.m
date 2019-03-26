//
//  LFVideoAudioMixCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoAudioMixCommand.h"
#import "LFAVAssetData+private.h"

@interface LFVideoAudioMixCommand ()

@property (nonatomic, strong) NSURL *audioUrl;

@end

@implementation LFVideoAudioMixCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData audioUrl:(NSURL *)audioUrl
{
    self = [super initWithAssetData:assetData];
    if(self) {
        _audioUrl = audioUrl;
    }
    
    return self;
}

- (void)execute
{
    if (self.assetData) {
        
        if (self.audioUrl) {
            /** 创建额外音轨特效 */
            NSMutableArray<AVAudioMixInputParameters *> *inputParameters = nil;
            if (self.assetData.audioMix.inputParameters.count == 0) {
                inputParameters = [@[] mutableCopy];
            } else {
                inputParameters = [self.assetData.audioMix.inputParameters mutableCopy];
            }
            /** 声音采集 */
            AVURLAsset *audioAsset = [[AVURLAsset alloc]initWithURL:self.audioUrl options:nil];
            
            AVAssetTrack *additional_assetAudioTrack = nil;
            /** 检查是否有效音轨 */
            if ([[audioAsset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
                additional_assetAudioTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio][0];
            }
            if (additional_assetAudioTrack) {
                NSError *error;
                AVMutableCompositionTrack *additional_compositionAudioTrack = [self.assetData.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                additional_compositionAudioTrack.preferredTransform = additional_assetAudioTrack.preferredTransform;
                [additional_compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.assetData.composition.duration) ofTrack:additional_assetAudioTrack atTime:kCMTimeZero error:&error];
                
                AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:additional_compositionAudioTrack];
                [mixParameters setVolumeRampFromStartVolume:1 toEndVolume:0 timeRange:CMTimeRangeMake(kCMTimeZero, self.assetData.composition.duration)];
                [inputParameters addObject:mixParameters];
                
                if (self.assetData.audioMix == nil) {
                    self.assetData.audioMix = [AVMutableAudioMix audioMix];
                }
                
                self.assetData.audioMix.inputParameters = inputParameters;
                
                self.error = error;
                if (error != nil) {
                    NSLog(@"Failed to append %@ : %@", self.audioUrl, error);
                }
            }
            
        }
    }
}

@end
