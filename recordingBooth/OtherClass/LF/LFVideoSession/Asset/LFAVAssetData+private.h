//
//  LFAVAssetData+private.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFAVAssetData.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFAVAssetData ()

@property (nonatomic, strong) AVMutableAudioMix *audioMix;

@property (nonatomic, assign) CGSize videoSize;

@property (nonatomic, readonly) AVMutableVideoComposition *internal_videoComposition;

@end

NS_ASSUME_NONNULL_END
