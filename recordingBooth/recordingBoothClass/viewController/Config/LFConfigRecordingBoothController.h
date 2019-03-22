//
//  LFConfigRecordingBoothController.h
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFBaseRecordingBoothController.h"
#import "LFRecordConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFConfigRecordingBoothController : LFBaseRecordingBoothController

@property (nonatomic, strong) LFRecordConfig *config;

@end

NS_ASSUME_NONNULL_END
