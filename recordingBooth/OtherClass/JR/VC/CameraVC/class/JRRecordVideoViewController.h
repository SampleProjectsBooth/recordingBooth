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


NS_ASSUME_NONNULL_BEGIN

@protocol JRRecordVideoViewControllerDelegate <NSObject>

- (void)didFinishRecordVideoVC:(JRRecordVideoViewController *)recordVC url:(nullable NSURL *)url error:(nullable NSError *)error;

- (void)didCancelRecordVideoVC:(JRRecordVideoViewController *)recordVC;

@end

@interface JRRecordVideoViewController : UIViewController


/**
 初始化方法

 @param fps zhenlv
 @param sessionPreset 视频质量
 @return instancetype
 */
- (instancetype)initWithFPS:(JRRecordVideoViewControllerFPSType)fps sessionPreset:(AVCaptureSessionPreset)sessionPreset;

/** 视频保存路径 */
@property (nonatomic, strong) NSURL *saveURL;

@property (nonatomic, weak) id<JRRecordVideoViewControllerDelegate> recordDelegate;

@end



NS_ASSUME_NONNULL_END
