//
//  LFVideoRateCommand.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFVideoRateCommand : LFVideoBaseCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData rate:(CMTimeValue)rate;

@end

NS_ASSUME_NONNULL_END
