//
//  LFVideoAudioMixCommand.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFVideoAudioMixCommand : LFVideoBaseCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData audioUrl:(NSURL *)audioUrl;

@end

NS_ASSUME_NONNULL_END
