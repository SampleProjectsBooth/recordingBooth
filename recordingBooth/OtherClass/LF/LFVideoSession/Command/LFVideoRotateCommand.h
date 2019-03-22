//
//  LFVideoRotateCommand.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoBaseCommand.h"

typedef NS_ENUM(NSUInteger, LFVideoRotateOrientation) {
    LFVideoRotateOrientation0,            // default orientation
    LFVideoRotateOrientation90,           // 90 deg CW
    LFVideoRotateOrientation180,          // 180 deg rotation
    LFVideoRotateOrientation270,          // 90 deg CCW
};

NS_ASSUME_NONNULL_BEGIN

@interface LFVideoRotateCommand : LFVideoBaseCommand

// fixed orientation is always up.
- (instancetype)initFixedOrientationWithAssetData:(LFAVAssetData *)assetData;

// degrees 90
- (instancetype)initWithAssetData:(LFAVAssetData *)assetData orientation:(LFVideoRotateOrientation)orientation;


@end

NS_ASSUME_NONNULL_END
