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

@end
