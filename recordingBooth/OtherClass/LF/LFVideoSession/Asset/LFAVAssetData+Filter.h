//
//  LFAVAssetData+Filter.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFAVAssetData.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFAVAssetData ()

@property (nonatomic, copy) NSMutableArray <CIFilter *> *filters NS_AVAILABLE_IOS(9_0) __TVOS_PROHIBITED;

@end

NS_ASSUME_NONNULL_END
