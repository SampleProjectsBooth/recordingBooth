//
//  LFVideoBaseCommand.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFVideoCommandProtocol.h"
#import "LFAVAssetData.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFVideoBaseCommand : NSObject <LFVideoCommandProtocol>

@property (weak, nonatomic, readonly) LFAVAssetData *assetData;

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData;

@property (nonatomic, strong) NSError *error;

@end

NS_ASSUME_NONNULL_END
