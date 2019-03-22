//
//  LFRecordingBoothController.h
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LFRecordingBoothControllerDelegate;

@interface LFRecordingBoothController : UINavigationController

@property (nonatomic,weak) id<LFRecordingBoothControllerDelegate> recordingBoothDelegate;

@end

@protocol LFRecordingBoothControllerDelegate <NSObject>

- (void)lf_recordingBoothControllerDidCancel:(LFRecordingBoothController *)recordingBooth;

@end

NS_ASSUME_NONNULL_END
