//
//  JRCameraVideoViewController.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/8.
//  Copyright © 2019 djr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class JRRecordVideoViewController;

typedef NS_ENUM(NSUInteger, JRCaremaFPSType) {
    JRCaremaFPSType30 = 30,
    JRCaremaFPSType60 = 60,
    JRCaremaFPSType120 = 120,
    JRCaremaFPSType240 = 240,
};

@protocol JRRecordVideoDelegate <NSObject>

- (void)didFinishRecordVideo:(JRRecordVideoViewController *)recordVC;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JRRecordVideoViewController : UIViewController

+ (instancetype)showRecordVideoViewControllerWithVC:(UIViewController *)vc fps:(JRCaremaFPSType)fps;

/** 视频保存路径 */
@property (nonatomic, strong) NSURL *saveURL;
/** 录制视频质量 */
@property(nonatomic, copy) AVCaptureSessionPreset sessionPreset;

@property (nonatomic, weak) id<JRRecordVideoDelegate> recordDelegate;

@end



NS_ASSUME_NONNULL_END
