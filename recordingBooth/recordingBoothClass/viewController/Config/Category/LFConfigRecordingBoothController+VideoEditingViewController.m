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
    JRVideoEditingOperationController *vc;
    if (self.config.automatic) {
        vc = [[JRVideoEditingOperationController alloc] initWithEditAsset:@[asset]];
    } else {
        vc = [[JRVideoEditingOperationController alloc] initWithClipAsset:asset];
        vc.minClippingDuration = 5.f;
        vc.maxClippingDuration = 20.f;
    }
    
    vc.operationDelegate = self;

    
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
    
    if (self.config.overlayIsOn) {
        /** water mark */
        UIImage *image = [UIImage imageNamed:@"waterMark.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(10, 10, image.size.width, image.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        UIView *waterView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [waterView addSubview:imageView];
        vc.overlayView = waterView;        
    }
    
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


@end
