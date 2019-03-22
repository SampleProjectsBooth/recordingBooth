//
//  LFConfigRecordingBoothController+VideoEditingViewController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFConfigRecordingBoothController+VideoEditingViewController.h"
#import "JRClipVideoEditingViewController.h"

@interface LFConfigRecordingBoothController (VideoEditingViewControllerDelegate)

@end

@implementation LFConfigRecordingBoothController (VideoEditingViewController)

- (void)showVideoEditingViewController:(AVAsset *)asset
{
    JRClipVideoEditingViewController *vc = [[JRClipVideoEditingViewController alloc] initWithVideoAsset:asset placeholderImage:[asset lf_firstImage:nil]];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
