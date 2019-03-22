//
//  LFVideoSessionManager.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoSession.h"

@interface LFVideoSession ()

@property (nonatomic, strong) NSMutableArray <id <LFVideoCommandProtocol>>*commands;

@end

@implementation LFVideoSession

- (id)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        NSAssert(asset, @"AVAsset is nil.");
        _assetData = [[LFAVAssetData alloc] initWithAsset:asset];
        _commands = [NSMutableArray array];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    return [self initWithAsset:asset];
}

#pragma mark - base
- (void)addCommand:(id <LFVideoCommandProtocol>)command
{
    [self.commands addObject:command];
}

- (void)removeCommand:(id <LFVideoCommandProtocol>)command
{
    [self.commands removeObject:command];
}

- (void)removeCommandAtIndex:(NSUInteger)index
{
    [self.commands removeObjectAtIndex:index];
}

#pragma mark - option


- (void)execute
{
    for (id <LFVideoCommandProtocol> command in _commands) {
        [command execute];
    }
}

@end
