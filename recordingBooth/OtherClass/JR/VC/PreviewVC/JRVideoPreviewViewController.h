//
//  JRVideoPreviewViewController.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/13.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoPlayerViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface JRVideoPreviewViewController : JRVideoPlayerViewController

- (instancetype)initWithAssets:(NSArray <AVAsset *>*)assets;

@end

NS_ASSUME_NONNULL_END
