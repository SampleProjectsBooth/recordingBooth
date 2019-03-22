//
//  JRVideoClipInfo.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoClipInfo.h"
#import "AVAsset+LFMECommon.h"

@implementation JRVideoClipInfo

- (UIImage *)image
{
    if (!_image) {
        _image = [self.asset lf_firstImage:nil];
    }
    return _image;
}

@end
