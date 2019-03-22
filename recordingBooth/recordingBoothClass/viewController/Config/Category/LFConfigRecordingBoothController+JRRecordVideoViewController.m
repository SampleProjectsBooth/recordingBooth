//
//  LFConfigRecordingBoothController+JRRecordVideoViewController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/3/22.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFConfigRecordingBoothController+JRRecordVideoViewController.h"
#import "JRRecordVideoViewController.h"

@interface LFConfigRecordingBoothController (JRRecordVideoViewControllerDelegate) <JRRecordVideoViewControllerDelegate>

@end

@implementation LFConfigRecordingBoothController (JRRecordVideoViewController)

- (void)showRecordVideoViewController
{
    JRRecordVideoViewControllerFPSType type = 240;
    JRRecordVideoViewController *cameraVC = [JRRecordVideoViewController showRecordVideoViewControllerWithVC:self fps:type sessionPreset:AVCaptureSessionPresetHigh];
    cameraVC.recordDelegate = self;
    /** save video url */
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    NSString *name = [[[NSDate date] description] stringByAppendingString:@".mp4"];;
    cameraVC.saveURL = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:name]];
}

- (void)_saveVideo:(NSURL *)url{
    
    if (url) {
        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
        if (compatible)
        {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(_savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}


//保存视频完成之后的回调
- (void)_savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    NSString *name = @"保存视频成功";
    if (error) {
        name = [NSString stringWithFormat:@"保存视频失败%@", error.localizedDescription];
        
    }
    UIAlertController *ale = [UIAlertController alertControllerWithTitle:nil message:name preferredStyle:(UIAlertControllerStyleAlert)];
    [ale addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:ale animated:YES completion:nil];
}

#pragma mark - JRRecordVideoViewControllerDelegate
- (void)didFinishRecordVideoVC:(JRRecordVideoViewController *)recordVC
{
    [self _saveVideo:recordVC.saveURL];
}

- (void)didCancelRecordVideoVC:(JRRecordVideoViewController *)recordVC
{
    
}



@end
