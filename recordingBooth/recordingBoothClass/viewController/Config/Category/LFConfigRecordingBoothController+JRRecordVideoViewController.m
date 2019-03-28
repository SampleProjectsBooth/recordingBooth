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
#import "JRRecordVideoController.h"

@interface LFConfigRecordingBoothController (JRRecordVideoViewControllerDelegate) <JRRecordVideoControllerDelegate>

@end

@implementation LFConfigRecordingBoothController (JRRecordVideoViewController)

- (void)showRecordVideoViewController
{
    
    JRRecordVideoController *vc = [[JRRecordVideoController alloc] initWihFPS:self.config.fps sessionPreset:AVCaptureSessionPresetHigh];
    /** save video url */
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    NSString *name = [[[NSDate date] description] stringByAppendingString:@".mp4"];
    vc.videoURL = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:name]];
    vc.recordDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - JRRecordVideoViewControllerDelegate
- (void)recordVideoController:(JRRecordVideoViewController *)controller didFinishVideoURL:(nullable NSURL *)videoURL error:(nullable NSError *)error
{
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"error" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:(UIAlertControllerStyleAlert)];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }]];
        [controller presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"create video..." preferredStyle:(UIAlertControllerStyleAlert)];
        [controller presentViewController:alert animated:YES completion:nil];
        
        __block NSString *localIdentifier = nil;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            localIdentifier = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL].placeholderForCreatedAsset.localIdentifier;
            
        } completionHandler:^(BOOL success, NSError * _Nullable error1) {
            
            if (success) {
                
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
                
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [alert dismissViewControllerAnimated:NO completion:^{
                            [controller dismissViewControllerAnimated:YES completion:^{
                                [self showVideoEditingViewController:asset];
                            }];
                        }];
                    });
                }];
            } else {
                [alert dismissViewControllerAnimated:NO completion:^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"error" message:[NSString stringWithFormat:@"%@", error1.localizedDescription] preferredStyle:(UIAlertControllerStyleAlert)];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                        [controller dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    [controller presentViewController:alert animated:YES completion:nil];
                    
                    NSLog(@"save video error:%@", error1);
                }];
            }
        }];
    }
    

}

- (void)recordVideoControllerDidCancel:(JRRecordVideoViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}



@end
