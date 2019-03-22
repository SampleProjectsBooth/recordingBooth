//
//  LFVideoCropCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoCropCommand.h"
#import "LFAVAssetData+private.h"

@interface LFVideoCropCommand ()

@property (nonatomic, assign) CGRect cropFrame;

@end

@implementation LFVideoCropCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData cropFrame:(CGRect)cropFrame
{
    self = [super initWithAssetData:assetData];
    if(self) {
        /** 视频的宽高都必须是16的整数倍,否则经过AVFoundation的API合成后系统会自动对尺寸进行校正，不足的地方会以绿边的形式进行填充 */
        CGFloat v_w = round(cropFrame.size.width/16.f)*16.f;
        CGFloat v_h = round(cropFrame.size.height/16.f)*16.f;
        cropFrame.size = CGSizeMake(v_w, v_h);
        _cropFrame = cropFrame;
    }
    
    return self;
}

- (void)execute {
    
    if (self.assetData) {
        
        CGRect cropFrame = (CGRect){CGPointZero, self.assetData.videoSize};
        if (CGRectContainsRect(cropFrame, self.cropFrame)) {

            AVMutableVideoCompositionInstruction *instruction = nil;
            AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
            
            //CMTime duration = self.videoData.videoCompositionTrack.timeRange.duration;
            CMTime duration = [self.assetData.composition duration];
            
            for (id <AVVideoCompositionInstruction>obj in self.assetData.internal_videoComposition.instructions) {
                if ([obj isKindOfClass:[AVMutableVideoCompositionInstruction class]]) {
                    instruction = (AVMutableVideoCompositionInstruction *)obj;
                    break;
                }
            }
            
            if(instruction == nil) {
                NSLog(@"zero instruction!");
                // The rotate transform is set on a layer instruction
                instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
                instruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
                
                layerInstruction = [AVMutableVideoCompositionLayerInstruction
                                    videoCompositionLayerInstructionWithAssetTrack:self.assetData.videoCompositionTrack];
                
                
                [layerInstruction setCropRectangle:self.cropFrame atTime:kCMTimeZero];
                CGAffineTransform t1 = CGAffineTransformMakeTranslation(-1*self.cropFrame.origin.x, -1*self.cropFrame.origin.y);
                [layerInstruction setTransform:t1 atTime:kCMTimeZero];
                
                instruction.layerInstructions = @[layerInstruction];
                
                NSMutableArray *instructions = [self.assetData.internal_videoComposition.instructions mutableCopy];
                if (instructions == nil) {
                    instructions = [NSMutableArray arrayWithCapacity:1];
                    [instructions addObject:instruction];
                } else {
                    [instructions addObject:instruction];
                }
                self.assetData.internal_videoComposition.instructions = instructions;
            }
            else {
                // Extract the existing layer instruction on the mutableVideoComposition
                
                layerInstruction = (AVMutableVideoCompositionLayerInstruction *)[instruction.layerInstructions lastObject];
                
                CGAffineTransform existingTransform;
                
                BOOL success = [layerInstruction getTransformRampForTime:duration
                                                          startTransform:&existingTransform
                                                            endTransform:NULL timeRange:NULL];
                
                if (!success) {
                    [layerInstruction setCropRectangle:self.cropFrame atTime:kCMTimeZero];
                    CGAffineTransform t1 = CGAffineTransformMakeTranslation(-1*self.cropFrame.origin.x, -1*self.cropFrame.origin.y);
                    [layerInstruction setTransform:t1 atTime:kCMTimeZero];
                } else {
                    //CGAffineTransform t3 = CGAffineTransformMakeTranslation(-1 * videoSize.height / 2, 0.0);
                    //CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, CGAffineTransformConcat(t2, t3));
                    //[layerInstruction setTransform:newTransform atTime:kCMTimeZero];
                    
                    CGAffineTransform t1 = CGAffineTransformMakeTranslation(-1*self.cropFrame.origin.x, -1*self.cropFrame.origin.y);
                    CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, t1);
                    [layerInstruction setTransform:newTransform atTime:kCMTimeZero];
                }
                instruction.layerInstructions = @[layerInstruction];
            }
            
            // set render size
            self.assetData.internal_videoComposition.renderSize = self.cropFrame.size;
            self.assetData.videoSize = self.cropFrame.size;
            
        }
    }
    
}

@end
