//
//  LFDataFilterVideoView.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/7.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilterSuiteHeader.h"
#import "FilterSuiteUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFDataFilterVideoView : LFFilterVideoView

@property (nonatomic, assign) LFFilterNameType type;

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
