//
//  LFRecordManager.h
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFRecordConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFRecordManager : NSObject

+ (LFRecordManager *)sharedRecordManager;
+ (void)free;

/** save */
- (BOOL)recordConfigWriteToFile:(LFRecordConfig *)config;

/** load */
- (NSArray <NSString *>*)eventList;
- (LFRecordConfig *)recordConfigWithEventName:(NSString *)name;

/** file path */
- (NSString *)filePathWithLink:(NSString *)link;

@end

NS_ASSUME_NONNULL_END
