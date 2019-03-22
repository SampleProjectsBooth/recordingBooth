//
//  LFConfigRecordingBoothController+VideoEditingViewController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFConfigRecordingBoothController+VideoEditingViewController.h"
#import "JRVideoEditingOperationController.h"

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
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - JRVideoEditingOperationControllerDelegate

- (void)videoEditingOperationController:(JRVideoEditingOperationController *)operationer didFinishEditUrl:(NSURL *)url error:(nullable NSError *)error
{
    [operationer dismissViewControllerAnimated:YES completion:^{
        
    }];
    NSLog(@"videoEditingOperationControllerdidFinishEditUrl error: %@", error);
}

- (void)videoEditingOperationControllerDidCancel:(JRVideoEditingOperationController *)operationer
{
    [operationer dismissViewControllerAnimated:YES completion:^{
        
    }];
    NSLog(@"videoEditingOperationControllerDidCancel");
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
