//
//  JRVideoPreviewViewController.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/13.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoPlayerOperationViewController.h"

@class JRVideoPreviewViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol VideoPlayerMergeOperationDelegate <VideoPlayerOperationDelegate>

@optional
- (void)didFinishMergeOperation:(JRVideoPreviewViewController *)vc asset:(AVAsset *)asset audioMix:(AVAudioMix *)audioMix videoComposition:(AVVideoComposition *)videoComposition;

@end

@interface JRVideoPreviewViewController : JRVideoPlayerOperationViewController <VideoPlayerMergeOperationDelegate>

- (instancetype)initWithAssets:(NSArray <AVAsset *>*)assets;

@end

NS_ASSUME_NONNULL_END
