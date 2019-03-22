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

typedef NS_ENUM(NSUInteger, JRRecordVideoViewControllerFPSType) {
    JRRecordVideoViewControllerFPS30 = 30,
    JRRecordVideoViewControllerFPS60 = 60,
    JRRecordVideoViewControllerFPS120 = 120,
    JRRecordVideoViewControllerFPS240 = 240,
};

@protocol JRRecordVideoViewControllerDelegate <NSObject>

- (void)didFinishRecordVideoVC:(JRRecordVideoViewController *)recordVC;

- (void)didCancelRecordVideoVC:(JRRecordVideoViewController *)recordVC;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JRRecordVideoViewController : UIViewController

+ (instancetype)showRecordVideoViewControllerWithVC:(UIViewController *)vc fps:(JRRecordVideoViewControllerFPSType)fps;

/** 视频保存路径 */
@property (nonatomic, strong) NSURL *saveURL;
/** 录制视频质量 */
@property(nonatomic, copy) AVCaptureSessionPreset sessionPreset;

@property (nonatomic, weak) id<JRRecordVideoViewControllerDelegate> recordDelegate;

@end



NS_ASSUME_NONNULL_END
