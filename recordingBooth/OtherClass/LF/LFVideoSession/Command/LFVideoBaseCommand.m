//
//  LFVideoBaseCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoBaseCommand.h"

@implementation LFVideoBaseCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData
{
    self = [super init];
    if(self) {
        _assetData = assetData;
    }
    return self;
}

- (void)execute
{
    
}

@end
