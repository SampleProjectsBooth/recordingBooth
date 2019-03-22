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
    vc.operationDelegate = self;
    vc.minClippingDuration = 5.f;
    vc.maxClippingDuration = 20.f;
    __weak typeof(self) weakSelf = self;
    vc.videoEditingLibrary = ^(LFVideoEditingController * _Nonnull videoEditingController) {
        videoEditingController.defaultAudioUrls = [weakSelf.config.musicList copy];
    };
    /** save video url */
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    NSString *name = [[[NSDate date] description] stringByAppendingString:@"_edit.mp4"];
    vc.videoUrl = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:name]];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - JRVideoEditingOperationControllerDelegate

- (void)videoEditingOperationController:(JRVideoEditingOperationController *)operationer didFinishEditUrl:(NSURL *)url error:(nullable NSError *)error
{
    [operationer dismissViewControllerAnimated:YES completion:^{
        NSLog(@"videoEditingOperationControllerdidFinishEditUrl:%@", url);
    }];
}

- (void)videoEditingOperationControllerDidCancel:(JRVideoEditingOperationController *)operationer
{
    [operationer dismissViewControllerAnimated:YES completion:^{
        NSLog(@"videoEditingOperationControllerDidCancel error: %@", error);        
    }];
}

@end
