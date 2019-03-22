//
//  LFVideoSessionManager.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFVideoCommandProtocol.h"
#import "LFAVAssetData.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFVideoSession : NSObject

@property (nonatomic, readonly) LFAVAssetData *assetData;

- (id)initWithAsset:(AVAsset *)asset;
- (id)initWithURL:(NSURL *)url;

- (void)addCommand:(id <LFVideoCommandProtocol>)command;
- (void)removeCommand:(id <LFVideoCommandProtocol>)command;
- (void)removeCommandAtIndex:(NSUInteger)index;

/** 执行命令 */
- (void)execute;

@end

NS_ASSUME_NONNULL_END
