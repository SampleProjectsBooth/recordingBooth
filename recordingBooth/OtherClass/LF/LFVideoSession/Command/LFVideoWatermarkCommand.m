//
//  LFVideoWatermarkCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoWatermarkCommand.h"
#import "LFAVAssetData+private.h"

@interface LFVideoWatermarkCommand ()

@property (nonatomic, strong) UIView *view;

@end

@implementation LFVideoWatermarkCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData view:(UIView *)view
{
    self = [super initWithAssetData:assetData];
    if(self) {
        _view = view;
    }
    
    return self;
}

- (void)execute
{
    if (self.assetData) {
        
        /** 水印 */
        if(self.view) {
            CGSize renderSize = self.assetData.videoSize;
            
            CALayer *animatedLayer = [self _generateAnimatedTitleLayerForSize:renderSize];
            CALayer *parentLayer = [CALayer layer];
            CALayer *videoLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
            [parentLayer addSublayer:videoLayer];
            [parentLayer addSublayer:animatedLayer];
            
            CMTime duration = self.assetData.composition.duration;
            
            AVMutableVideoCompositionInstruction *instruction = nil;
            for (id <AVVideoCompositionInstruction>obj in self.assetData.internal_videoComposition.instructions) {
                if ([obj isKindOfClass:[AVMutableVideoCompositionInstruction class]]) {
                    instruction = (AVMutableVideoCompositionInstruction *)obj;
                    break;
                }
            }
            if (instruction == nil) {
                // The rotate transform is set on a layer instruction
                instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
                instruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
                
                AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction
                                                                               videoCompositionLayerInstructionWithAssetTrack:self.assetData.videoCompositionTrack];
                
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
            
            self.assetData.internal_videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        }
        
    }
}

- (CALayer *)_generateAnimatedTitleLayerForSize:(CGSize)size
{
    UIImage *watermarkImage = [self _generateWaterImageForVideoSize:size];
    // 1 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.contentsScale = [UIScreen mainScreen].scale;
    overlayLayer.contents = (__bridge id _Nullable)(watermarkImage.CGImage);
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    return overlayLayer;
}

- (UIImage *)_generateWaterImageForVideoSize:(CGSize)videoSize
{
    UIView *overlayView = self.view;
    
    if (overlayView) {
        /** 根据视频大小，重新排版水印 */
        overlayView.frame = (CGRect){CGPointZero, videoSize};
        
        CGRect rect = overlayView.frame;
        CGSize size = rect.size;
        //1.开启上下文
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        //2.绘制图层
        [overlayView.layer renderInContext:context];
        //3.从上下文中获取新图片
        UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
        //4.关闭图形上下文
        UIGraphicsEndImageContext();
        
        /** 缩放至视频大小 */
//        UIGraphicsBeginImageContextWithOptions(videoSize, NO, 1);
//        [watermarkImage drawInRect:CGRectMake(0, 0, videoSize.width, videoSize.height)];
//        UIImage *generatedWatermarkImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        
        return watermarkImage;
    }
    return nil;
}

@end
