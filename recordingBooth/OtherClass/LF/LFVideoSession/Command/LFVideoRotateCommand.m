//
//  LFVideoRotateCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoRotateCommand.h"
#import "LFAVAssetData+private.h"
#import <UIKit/UIKit.h>

@interface LFVideoRotateCommand ()

@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) CGSize renderSize;

@end

@implementation LFVideoRotateCommand

- (instancetype)initFixedOrientationWithAssetData:(LFAVAssetData *)assetData
{
    self = [super initWithAssetData:assetData];
    if(self) {
        
        UIImageOrientation orientation = [self orientationFromAVAssetTrack:assetData.videoCompositionTrack];
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        CGSize renderSize = assetData.videoSize;
        
        switch (orientation) {
            case UIImageOrientationLeft:
                //顺时针旋转270°
                //            NSLog(@"视频旋转270度，home按键在右");
                transform = CGAffineTransformTranslate(transform, 0.0, assetData.videoSize.width);
                transform = CGAffineTransformRotate(transform,M_PI_2*3.0);
                renderSize = CGSizeMake(assetData.videoSize.height,assetData.videoSize.width);
                break;
            case UIImageOrientationRight:
                //顺时针旋转90°
                //            NSLog(@"视频旋转90度,home按键在左");
                transform = CGAffineTransformTranslate(transform, assetData.videoSize.height, 0.0);
                transform = CGAffineTransformRotate(transform,M_PI_2);
                renderSize = CGSizeMake(assetData.videoSize.height,assetData.videoSize.width);
                break;
            case UIImageOrientationDown:
                //顺时针旋转180°
                //            NSLog(@"视频旋转180度，home按键在上");
                transform = CGAffineTransformTranslate(transform, assetData.videoSize.width, assetData.videoSize.height);
                transform = CGAffineTransformRotate(transform,M_PI);
                renderSize = CGSizeMake(assetData.videoSize.width,assetData.videoSize.height);
                break;
            default:
                break;
        }
        _transform = transform;
        _renderSize = renderSize;
    }
    
    return self;
}

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData orientation:(LFVideoRotateOrientation)orientation
{
    self = [super initWithAssetData:assetData];
    if(self) {
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        CGSize renderSize = assetData.videoSize;
        
        switch (orientation) {
            case LFVideoRotateOrientation0:
                break;
            case LFVideoRotateOrientation90:
                transform = CGAffineTransformTranslate(transform, assetData.videoSize.height, 0.0);
                transform = CGAffineTransformRotate(transform,M_PI_2);
                renderSize = CGSizeMake(assetData.videoSize.height,assetData.videoSize.width);
                break;
            case LFVideoRotateOrientation180:
                transform = CGAffineTransformTranslate(transform, assetData.videoSize.width, assetData.videoSize.height);
                transform = CGAffineTransformRotate(transform,M_PI);
                renderSize = CGSizeMake(assetData.videoSize.width,assetData.videoSize.height);
                break;
            case LFVideoRotateOrientation270:
                transform = CGAffineTransformTranslate(transform, 0.0, assetData.videoSize.width);
                transform = CGAffineTransformRotate(transform,M_PI_2*3.0);
                renderSize = CGSizeMake(assetData.videoSize.height,assetData.videoSize.width);
                break;
        }
        _transform = transform;
        _renderSize = renderSize;
    }
    
    return self;
}

- (UIImageOrientation)orientationFromAVAssetTrack:(AVAssetTrack *)videoTrack
{
    UIImageOrientation orientation = UIImageOrientationUp;
    
    CGAffineTransform t = videoTrack.preferredTransform;
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        // Portrait
        //        degress = 90;
        orientation = UIImageOrientationRight;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        // PortraitUpsideDown
        //        degress = 270;
        orientation = UIImageOrientationLeft;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        // LandscapeRight
        //        degress = 0;
        orientation = UIImageOrientationUp;
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        // LandscapeLeft
        //        degress = 180;
        orientation = UIImageOrientationDown;
    }
    
    return orientation;
}

- (void)execute
{
    if (self.assetData) {
        if (!CGAffineTransformEqualToTransform(_transform, CGAffineTransformIdentity)) {
            
            AVMutableVideoCompositionInstruction *instruction = nil;
            AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
            
            CMTime duration = self.assetData.composition.duration;
            
            for (id <AVVideoCompositionInstruction>obj in self.assetData.internal_videoComposition.instructions) {
                if ([obj isKindOfClass:[AVMutableVideoCompositionInstruction class]]) {
                    instruction = (AVMutableVideoCompositionInstruction *)obj;
                    break;
                }
            }
            
            if(instruction == nil) {
                // The rotate transform is set on a layer instruction
                instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
                instruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
                
                layerInstruction = [AVMutableVideoCompositionLayerInstruction
                                    videoCompositionLayerInstructionWithAssetTrack:self.assetData.videoCompositionTrack];
                [layerInstruction setTransform:self.transform atTime:kCMTimeZero];
                
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
                    [layerInstruction setTransform:self.transform atTime:kCMTimeZero];
                } else {
                    //CGAffineTransform t3 = CGAffineTransformMakeTranslation(-1 * videoSize.height / 2, 0.0);
                    //CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, CGAffineTransformConcat(t2, t3));
                    //[layerInstruction setTransform:newTransform atTime:kCMTimeZero];
                    
                    CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, self.transform);
                    [layerInstruction setTransform:newTransform atTime:kCMTimeZero];
                }
                instruction.layerInstructions = @[layerInstruction];
            }
            
            self.assetData.internal_videoComposition.renderSize = self.renderSize;
            self.assetData.videoSize = self.renderSize;
        }
    }
}

@end
