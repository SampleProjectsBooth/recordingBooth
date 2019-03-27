//
//  JRRecordVideoController.h
//  recordingBooth
//
//  Created by 丁嘉睿 on 2019/3/27.
//  Copyright © 2019 Marc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JRRecordVideoControllerDelegate;

@interface JRRecordVideoController : UINavigationController

/**
 初始化方法

 @param fps 30/60/120/240
 @param sessionPreset AVCaptureSessionPreset
 @return instancetype
 */
- (instancetype)initWihFPS:(NSUInteger)fps sessionPreset:(AVCaptureSessionPreset)sessionPreset;

/** 代理 */
@property (nonatomic, weak) id<JRRecordVideoControllerDelegate>recordDelegate;

/** 视频保存路径 */
@property (nonatomic, strong) NSURL *videoURL;

@end

@protocol JRRecordVideoControllerDelegate <NSObject>

- (void)recordVideoController:(JRRecordVideoController *)controller didFinishVideoURL:(nullable NSURL *)videoURL error:(nullable NSError *)error;

- (void)recordVideoControllerDidCancel:(JRRecordVideoController *)controller;

@end

NS_ASSUME_NONNULL_END
