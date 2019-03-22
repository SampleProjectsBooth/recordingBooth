//
//  LFRecordConfig.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFRecordConfig.h"

@implementation LFRecordConfig

- (NSMutableArray *)musicList
{
    if (!_musicList) {
        _musicList = [NSMutableArray array];
    }
    return _musicList;
}

#pragma mark - 从文件中读取
- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    if ((self = [super init]))
    
    {
        _event = [aDecoder decodeObjectForKey:@"event"];
        _fps = [[aDecoder decodeObjectForKey:@"fps"] integerValue];
        _overlayIsOn = [[aDecoder decodeObjectForKey:@"overlayIsOn"] boolValue];
        _musicList = [aDecoder decodeObjectForKey:@"musicList"];
        _automatic = [[aDecoder decodeObjectForKey:@"automatic"] boolValue];
    }
    
    return self;
    
}

#pragma mark - 写入文件
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_event forKey:@"event"];
    [aCoder encodeObject:@(_fps) forKey:@"fps"];
    [aCoder encodeObject:@(_overlayIsOn) forKey:@"overlayIsOn"];
    [aCoder encodeObject:_musicList forKey:@"musicList"];
    [aCoder encodeObject:@(_automatic) forKey:@"automatic"];
}

+ (instancetype)modelWithObjectData:(NSData *)data
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSData *)objectData
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
