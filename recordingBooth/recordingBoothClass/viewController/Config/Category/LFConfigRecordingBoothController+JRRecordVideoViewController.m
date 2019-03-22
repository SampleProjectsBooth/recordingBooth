//
//  LFConfigRecordingBoothController+JRRecordVideoViewController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFConfigRecordingBoothController+JRRecordVideoViewController.h"
#import "JRRecordVideoViewController.h"

@interface LFConfigRecordingBoothController (JRRecordVideoViewControllerDelegate) <JRRecordVideoDelegate>

@end

@implementation LFConfigRecordingBoothController (JRRecordVideoViewController)

- (void)showRecordVideoViewController
{
    JRCaremaFPSType type = self.config.fps;
    JRRecordVideoViewController *cameraVC = [JRRecordVideoViewController showRecordVideoViewControllerWithVC:self fps:type];
    cameraVC.recordDelegate = self;
    cameraVC.sessionPreset = AVCaptureSessionPresetHigh;
    /** save video url */
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    NSString *name = [[[NSDate date] description] stringByAppendingString:@".mp4"];;
    cameraVC.saveURL = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:name]];
}

#pragma mark - JRRecordVideoDelegate
- (void)didFinishRecordVideo:(JRRecordVideoViewController *)recordVC
{
    
}


@end
