//
//  LFVideoClipCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoClipCommand.h"
#import "LFAVAssetData+private.h"

@interface LFVideoClipCommand ()

@property (nonatomic, assign) CMTimeRange timeRange;

@end

@implementation LFVideoClipCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData timeRange:(CMTimeRange)timeRange
{
    self = [super initWithAssetData:assetData];
    if(self) {
        _timeRange = timeRange;
    }
    
    return self;
}

- (void)execute
{
    if (self.assetData) {
        
        AVMutableComposition *composition = self.assetData.composition;
        
        if (CMTIME_COMPARE_INLINE(self.timeRange.start, >, kCMTimeZero) && CMTIME_COMPARE_INLINE(self.timeRange.start, <, composition.duration)) {
            CMTimeRange start = CMTimeRangeMake(kCMTimeZero, self.timeRange.start);
            [self.assetData.videoCompositionTrack removeTimeRange:start];
            [self.assetData.audioCompositionTrack removeTimeRange:start];
        }
        CMTime startTime = self.timeRange.duration;
        CMTime endTime = CMTimeSubtract(composition.duration, startTime);
        if (CMTIME_COMPARE_INLINE(startTime, >, kCMTimeZero) && CMTIME_COMPARE_INLINE(endTime, <, composition.duration)) {
            CMTimeRange end = CMTimeRangeMake(startTime, endTime);
            [self.assetData.videoCompositionTrack removeTimeRange:end];
            [self.assetData.audioCompositionTrack removeTimeRange:end];
        }
        
        AVMutableVideoCompositionInstruction *instruction = nil;
        for (id <AVVideoCompositionInstruction>obj in self.assetData.internal_videoComposition.instructions) {
            if ([obj isKindOfClass:[AVMutableVideoCompositionInstruction class]]) {
                instruction = (AVMutableVideoCompositionInstruction *)obj;
                break;
            }
        }
        
        if(instruction) {
            // Extract the existing layer instruction on the mutableVideoComposition
            
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
            
        }
    }
}

@end
