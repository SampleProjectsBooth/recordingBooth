//
//  LFConfigRecordingBoothController+JRRecordVideoViewController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFConfigRecordingBoothController+JRRecordVideoViewController.h"
#import "LFConfigRecordingBoothController+VideoEditingViewController.h"
#import "JRRecordVideoViewController.h"
#import <Photos/Photos.h>

@interface LFConfigRecordingBoothController (JRRecordVideoViewControllerDelegate) <JRRecordVideoViewControllerDelegate>

@end

@implementation LFConfigRecordingBoothController (JRRecordVideoViewController)

- (void)showRecordVideoViewController
{
    JRRecordVideoViewControllerFPSType type = self.config.fps;
    JRRecordVideoViewController *cameraVC = [JRRecordVideoViewController showRecordVideoViewControllerWithVC:self fps:type sessionPreset:AVCaptureSessionPresetHigh];
    cameraVC.recordDelegate = self;
    /** save video url */
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    NSString *name = [[[NSDate date] description] stringByAppendingString:@".mp4"];
    cameraVC.saveURL = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:name]];
}

#pragma mark - JRRecordVideoViewControllerDelegate
- (void)didFinishRecordVideoVC:(JRRecordVideoViewController *)recordVC
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"create video..." preferredStyle:(UIAlertControllerStyleAlert)];
    [self presentViewController:alert animated:YES completion:nil];
    
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        localIdentifier = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:recordVC.saveURL].placeholderForCreatedAsset.localIdentifier;
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            if (localIdentifier) {
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    [alert dismissViewControllerAnimated:YES completion:^{
                        [self showVideoEditingViewController:asset];
                    }];
                }];
            }
            
        } else {
            NSLog(@"save video error:%@", error);
        }
        
    }];
}

- (void)didCancelRecordVideoVC:(JRRecordVideoViewController *)recordVC
{
    
}



@end
