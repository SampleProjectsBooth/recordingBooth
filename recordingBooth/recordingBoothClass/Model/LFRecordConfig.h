//
//  LFRecordConfig.h
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFRecordConfig : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString *event;
@property (nonatomic, assign) NSInteger fps;
@property (nonatomic, assign) BOOL overlayIsOn;
@property (nonatomic, strong) NSMutableArray <NSString *>*musicList;
@property (nonatomic, assign) BOOL automatic;

+ (instancetype)modelWithObjectData:(NSData *)data;
- (NSData *)objectData;

@end

NS_ASSUME_NONNULL_END
