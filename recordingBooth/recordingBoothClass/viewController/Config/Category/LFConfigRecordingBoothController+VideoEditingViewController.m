//
//  LFConfigRecordingBoothController+VideoEditingViewController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFConfigRecordingBoothController+VideoEditingViewController.h"
#import "JRVideoEditingOperationController.h"
#import "LFRecordManager.h"

@interface LFConfigRecordingBoothController (VideoEditingViewControllerDelegate) <JRVideoEditingOperationControllerDelegate>

@end

@implementation LFConfigRecordingBoothController (VideoEditingViewController)

- (void)showVideoEditingViewController:(AVAsset *)asset
{
    JRVideoEditingOperationController *vc = [[JRVideoEditingOperationController alloc] initWithAsset:asset];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (videoTrack) {
        CGSize size = videoTrack.naturalSize;
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, 0, size}];
        UIView *markView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 20.f, 20.f)];
        markView.backgroundColor = [UIColor yellowColor];
        [view addSubview:markView];
        view.backgroundColor = [UIColor blackColor];
        vc.overlayView = view;
    }
    NSString *path = [LFConfigRecordingBoothController createDirectoryUnderTemporaryDirectory:@"JR" file:@"test.mp4"];
    vc.videoUrl = [NSURL fileURLWithPath:path];
    vc.operationDelegate = self;
    vc.minClippingDuration = 5.f;
    vc.maxClippingDuration = 20.f;
    
    /** audio url */
    NSMutableArray *audioUrls = [NSMutableArray arrayWithCapacity:3];
    NSString *filePath = nil;
    NSURL *fileUrl = nil;
    for (NSString *link in self.config.musicList) {
        filePath = [[LFRecordManager sharedRecordManager] filePathWithLink:link];
        if (filePath) {
            fileUrl = [NSURL fileURLWithPath:filePath];
            if (fileUrl) {
                [audioUrls addObject:fileUrl];
            }
        }
    }
    vc.videoEditingLibrary = ^(LFVideoEditingController * _Nonnull videoEditingController) {
        videoEditingController.defaultAudioUrls = audioUrls;
    };
    
    /** water mark */
    UIImage *image = [UIImage imageNamed:@"waterMark.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(10, 10, image.size.width, image.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    UIView *waterView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [waterView addSubview:imageView];
    
    /** save video url */
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    NSString *name = [[[NSDate date] description] stringByAppendingString:@"_edit.mp4"];
    vc.videoUrl = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:name]];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - JRVideoEditingOperationControllerDelegate

- (void)videoEditingOperationController:(JRVideoEditingOperationController *)operationer didFinishEditUrl:(NSURL *)url error:(nullable NSError *)error
{
    NSLog(@"videoEditingOperationControllerdidFinishEditUrl:%@ error:%@", url, error);
    
    [operationer dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)videoEditingOperationControllerDidCancel:(JRVideoEditingOperationController *)operationer
{
    NSLog(@"videoEditingOperationControllerDidCancel");
    [operationer dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Class Methods
+ (NSString *)createDirectoryUnderTemporaryDirectory:(NSString *)name file:(NSString *)file
{
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];
    NSString *path = NSTemporaryDirectory();
    if (name.length > 0) {
        path = [path stringByAppendingString:name];
    }
    BOOL exist = [fm fileExistsAtPath:path];
    if (!exist) {
        if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"createMediaFolder error: %@ \n",[error localizedDescription]);
        }
    }
    if (file.length > 0) {
        path = [path stringByAppendingPathComponent:file];
    }
    return path;
}

@end
