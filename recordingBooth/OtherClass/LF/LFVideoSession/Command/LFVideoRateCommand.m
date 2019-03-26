//
//  LFVideoRateCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoRateCommand.h"
#import "LFAVAssetData+private.h"

@interface LFVideoRateCommand ()

@property (nonatomic, assign) CMTimeValue rate;

@end

@implementation LFVideoRateCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData rate:(CMTimeValue)rate
{
    self = [super initWithAssetData:assetData];
    if(self) {
        _rate = 1.f;
        if (rate > 0) {
            _rate = rate;
        }
    }
    
    return self;
}

- (void)execute
{
    if (self.assetData) {
        
        
        AVMutableComposition *composition = self.assetData.composition;
        
        [self.assetData.videoCompositionTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, composition.duration) toDuration:CMTimeMake(composition.duration.value*self.rate, composition.duration.timescale)];
        
        [self.assetData.audioCompositionTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, composition.duration) toDuration:CMTimeMake(composition.duration.value*self.rate, composition.duration.timescale)];
        
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
