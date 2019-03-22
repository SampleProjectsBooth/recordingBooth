//
//  JRVideoClipInfo.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "JRClipInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface JRVideoClipInfo : NSObject

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) JRClipInfo *clipInfo;

@end

NS_ASSUME_NONNULL_END
