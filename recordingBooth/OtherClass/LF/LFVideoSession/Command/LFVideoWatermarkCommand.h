//
//  LFVideoWatermarkCommand.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoBaseCommand.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 iOS9之前的系统LFVideoWatermarkCommand必须为最后一个处理。
*/
@interface LFVideoWatermarkCommand : LFVideoBaseCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData view:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
