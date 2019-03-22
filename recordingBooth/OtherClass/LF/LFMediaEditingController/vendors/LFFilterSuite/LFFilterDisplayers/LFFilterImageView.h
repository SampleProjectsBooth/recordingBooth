//
//  LFFilterImageView.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFContextImageView.h"
#import "LFFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFFilterImageView : LFContextImageView

/**
 The filter to apply when rendering. If nil is set, no filter will be applied
 */
@property (strong, nonatomic) LFFilter *__nullable filter;

@end

NS_ASSUME_NONNULL_END
