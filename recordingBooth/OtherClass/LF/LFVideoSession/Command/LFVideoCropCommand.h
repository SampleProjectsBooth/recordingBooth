//
//  LFVideoCropCommand.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFVideoCropCommand : LFVideoBaseCommand

// crop frame
- (instancetype)initWithAssetData:(LFAVAssetData *)assetData cropFrame:(CGRect)cropFrame;

@end

NS_ASSUME_NONNULL_END
