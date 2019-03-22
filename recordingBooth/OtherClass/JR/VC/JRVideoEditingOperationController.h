//
//  JRVideoEditingOperationController.h
//  recordingBooth
//
//  Created by 丁嘉睿 on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class JRVideoEditingOperationController, LFVideoEditingController;

NS_ASSUME_NONNULL_BEGIN

@protocol JRVideoEditingOperationControllerDelegate <NSObject>

- (void)videoEditingOperationController:(JRVideoEditingOperationController *)operationer didFinishEditUrl:(NSURL *)url;

- (void)videoEditingOperationControllerDidCancel:(JRVideoEditingOperationController *)operationer error:(nullable NSError *)error;

@end

@interface JRVideoEditingOperationController : UINavigationController

- (instancetype)initWithAsset:(AVAsset *)asset;

@property (nonatomic, weak) id<JRVideoEditingOperationControllerDelegate>operationDelegate;

/** 自动保存到相册 默认YES */
@property (nonatomic, assign) BOOL autoSavePhotoAlbum;

@property (nonatomic, copy) void(^videoEditingLibrary)(LFVideoEditingController *videoEditingController);

/** 视频保存的地址 */
@property (nonatomic, strong) NSURL *videoUrl;

/** 视频、音频质量，默认AVAssetExportPresetHighestQuality */
@property (nonatomic, copy) NSString *presetQuality;

/** 视频类型(AVFileTypeQuickTimeMovie、AVFileTypeMPEG4（默认）、AVFileTypeAppleM4V、AVFileTypeAppleM4A、AVFileType3GPP)*/
@property (nonatomic, copy) NSString *videoType;

/** 允许剪辑的最小时长 1秒 */
@property (nonatomic, assign) double minClippingDuration;

/** 允许剪辑的最大时长 默认视频长度 */
@property (nonatomic, assign) double maxClippingDuration;

@end

NS_ASSUME_NONNULL_END
