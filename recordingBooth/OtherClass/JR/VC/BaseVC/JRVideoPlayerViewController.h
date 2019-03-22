//
//  JRVideoPlayerViewController.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/7.
//  Copyright © 2019 djr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LFVideoSessionHeader.h"
#import "LFVideoSession.h"
#import "UIImage+Bundle.h"
#import "AVAsset+LFMECommon.h"

NS_ASSUME_NONNULL_BEGIN


@protocol VideoPlayerProtocol <NSObject>

@required

/**
 可以播放视频
 
 @param duration 视频总时间长
 */
- (void)didReayToplay:(double)duration;

@optional

/**
 视频播放回调
 
 @param duration 视频播放时间
 */
- (void)pregessToPlay:(double)duration;

/**
 视频播放结束
 */
- (void)didEndToplay;

/**
 播放错误

 @param error error
 */
- (void)didRefusedPlay:(NSError *)error;

@end

@interface JRVideoPlayerViewController : UIViewController <VideoPlayerProtocol>


- (instancetype)initWithPlaceholderImage:(nullable UIImage *)placeholderImage;

@property (nonatomic, assign) CGRect videoPlayerViewFrame;

@property (nonatomic, strong) AVAsset *asset;

- (void)play;

- (void)pause;

-(void)reset;

/** 跳转到某帧 */
- (void)seekToTime:(CGFloat)time;

+ (NSString *)createDirectoryUnderTemporaryDirectory:(NSString *)name file:(NSString *)file;

@end

NS_ASSUME_NONNULL_END

