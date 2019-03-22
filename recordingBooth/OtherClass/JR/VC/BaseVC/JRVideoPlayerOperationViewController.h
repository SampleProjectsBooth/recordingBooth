//
//  JRVideoPlayerOperationViewController.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/21.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoPlayerViewController.h"

@class JRVideoPlayerOperationViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol VideoPlayerOperationDelegate <NSObject>

@optional

/** 取消代理 */
- (void)dissminssVideoPlayerViewController:(JRVideoPlayerOperationViewController *)vc;

/** 完成代理 */
- (void)didFinishOperation:(JRVideoPlayerOperationViewController *)vc asset:(AVAsset *)asset;

@end

@interface JRVideoPlayerOperationViewController : JRVideoPlayerViewController <VideoPlayerOperationDelegate>

@property (nonatomic, weak) id<VideoPlayerOperationDelegate>operationDelegate;

/**
 提供给子类重写完成按钮事件(不会影响didFinishOperation:asset:代理, 后执行代理)
 */
- (void)completeButtonAction;

@end

NS_ASSUME_NONNULL_END
