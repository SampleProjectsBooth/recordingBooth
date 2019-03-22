//
//  JRClipVideoEditingViewController.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoPlayerOperationViewController.h"

@class  JRClipVideoEditingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol VideoPlayerClipOperationDelegate <VideoPlayerOperationDelegate>

@optional
/** 完成代理 */
- (void)didFinishClipOperation:(JRClipVideoEditingViewController *)vc clipAssets:(NSArray <AVAsset *>*)clipAssets;

@end

@interface JRClipVideoEditingViewController : JRVideoPlayerOperationViewController <VideoPlayerClipOperationDelegate>


- (instancetype)initWithVideoAsset:(AVAsset *)videoAsset placeholderImage:(nullable UIImage *)placeholderImage;

/** 允许剪辑的最小时长 1秒 */
@property (nonatomic, assign) double minClippingDuration;

@end

NS_ASSUME_NONNULL_END
