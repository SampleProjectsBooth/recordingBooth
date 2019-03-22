//
//  JRClipVideoEditingViewController.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoPlayerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface JRClipVideoEditingViewController : JRVideoPlayerViewController


- (instancetype)initWithVideoAsset:(AVAsset *)videoAsset placeholderImage:(nullable UIImage *)placeholderImage;

/** 允许剪辑的最小时长 1秒 */
@property (nonatomic, assign) double minClippingDuration;

/** 允许剪辑的最大时长 默认视频长度 */
@property (nonatomic, assign) double maxClippingDuration;

@end

NS_ASSUME_NONNULL_END
