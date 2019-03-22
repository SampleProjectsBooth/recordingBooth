//
//  LFVideoFilterCommand.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/15.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFVideoFilterCommand.h"
#import "LFAVAssetData+Filter.h"

@interface LFVideoFilterCommand ()

@property (nonatomic, strong) CIFilter *filter;

@end

@implementation LFVideoFilterCommand

- (instancetype)initWithAssetData:(LFAVAssetData *)assetData filter:(CIFilter *)filter
{
    self = [super initWithAssetData:assetData];
    if(self) {
        _filter = filter;
    }
    
    return self;
}

- (void)execute
{
    if (self.assetData) {
        if ([[AVMutableVideoComposition class] respondsToSelector:@selector(videoCompositionWithAsset:applyingCIFiltersWithHandler:)]) {
            
            if (self.filter) {
                [self.assetData.filters addObject:self.filter];
            }
        }
    }
}

@end
