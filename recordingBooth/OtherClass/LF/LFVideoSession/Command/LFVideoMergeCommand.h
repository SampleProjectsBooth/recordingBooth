//
//  LFVideoMergeCommand.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFVideoMergeCommand : LFVideoBaseCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData asset:(AVAsset *)asset;

@end

NS_ASSUME_NONNULL_END
