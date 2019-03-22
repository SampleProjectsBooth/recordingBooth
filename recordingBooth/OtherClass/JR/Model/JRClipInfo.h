//
//  JRClipInfo.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRClipInfo : NSObject

@property (nonatomic, assign) double startTime;

@property (nonatomic, assign) double endTime;

@property (nonatomic, assign) NSRange clipRange;

@end

NS_ASSUME_NONNULL_END
