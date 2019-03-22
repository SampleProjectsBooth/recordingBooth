//
//  LFVideoClipCommand.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFVideoClipCommand : LFVideoBaseCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData timeRange:(CMTimeRange)timeRange;

@end

NS_ASSUME_NONNULL_END
