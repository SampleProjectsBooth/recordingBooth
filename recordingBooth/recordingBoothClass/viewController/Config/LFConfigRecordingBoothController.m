//
//  LFConfigRecordingBoothController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFConfigRecordingBoothController.h"
#import "LFRecordManager.h"
#import "LFDownloadManager.h"

#import "LFConfigRecordingBoothController+VideoEditingViewController.h"
#import "LFConfigRecordingBoothController+JRRecordVideoViewController.h"
#import "JRVideoEditingOperationController.h"
#import <Photos/Photos.h>

@interface LFConfigRecordingBoothController () <JRVideoEditingOperationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fpsSegment;
@property (weak, nonatomic) IBOutlet UISwitch *overlaySwitch;
@property (weak, nonatomic) IBOutlet UITextField *urlLinkField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *recordSegment;

//@property (nonatomic, strong) LFRecordConfig *config;

@end

@implementation LFConfigRecordingBoothController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadUIConfig];
}

- (IBAction)saveOnClick:(id)sender {
    [self saveUIConfig];
    BOOL isSuccess = [[LFRecordManager sharedRecordManager] recordConfigWriteToFile:self.config];
    if (isSuccess) {
        NSLog(@"save event success!");
    } else {
        NSLog(@"save event fail!");
    }
}

- (IBAction)loadOnClick:(id)sender {
    
    NSArray *events = [[LFRecordManager sharedRecordManager] eventList];
    
    if (events.count) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"event" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        for (NSString *name in events) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.config = [[LFRecordManager sharedRecordManager] recordConfigWithEventName:action.title];
                [self loadUIConfig];
            }];
            [alertController addAction:action];
        }
        
        alertController.popoverPresentationController.sourceView = sender;
        
        alertController.popoverPresentationController.sourceRect = [(UIView *)sender bounds];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        NSLog(@"no event");
    }
}

- (IBAction)DLMusicOnClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    NSString *link = self.urlLinkField.text;
#warning test code begin
    if (link.length == 0) {
        link = @"https://sample-videos.com/audio/mp3/crowd-cheering.mp3";
        self.urlLinkField.text = link;
    }
#warning test code end
    if (link.length) {
        
        NSString *path = [[LFRecordManager sharedRecordManager] filePathWithLink:link];
        
        void (^downloadAction)(void) = ^{
            [[LFDownloadManager shareLFDownloadManager] lf_downloadURL:[NSURL URLWithString:link] progress:^(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSURL *URL) {
                NSLog(@"progress %.2f%%", (float)totalBytesWritten/totalBytesExpectedToWrite*100);
            } completion:^(NSData *data, NSError *error, NSURL *URL) {
                NSLog(@"download completion :%@", error);
                button.enabled = YES;
                
                if ([data writeToFile:path atomically:YES]) {

                } else {
                    NSLog(@"file save fail : %@", link);
                }
            }];
        };
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"link" message:@"This link has been downloaded. Do you want to download again?" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                button.enabled = YES;
            }];
            [alertController addAction:cancelAction];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                downloadAction();
            }];

            [alertController addAction:action];
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            downloadAction();
        }
        
    } else {
        NSLog(@"link is nil");
    }
}

- (IBAction)setClipsOnClick:(id)sender {
    NSLog(@"set clips");
    [self saveUIConfig];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"SampleVideo" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:url];
    [self showVideoEditingViewController:asset];
}

- (IBAction)startOnClick:(id)sender {
    NSLog(@"start record");
    [self saveUIConfig];
    
    [self showRecordVideoViewController];
}

- (IBAction)mergeVideoOnClick:(id)sender {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp4"];

    AVURLAsset *asset0 = [AVURLAsset URLAssetWithURL:url options:nil];
    
    url = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"mp4"];
    
    AVURLAsset *asset1 = [AVURLAsset URLAssetWithURL:url options:nil];

    NSArray *array = @[asset0, asset1];
    
    JRVideoEditingOperationController *con = [[JRVideoEditingOperationController alloc] initWithEditAsset:array];
    con.operationDelegate = self;
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    NSString *name = [[[NSDate date] description] stringByAppendingString:@".mp4"];
    con.videoUrl = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:name]];
    [self presentViewController:con animated:NO completion:nil];
}

- (void)videoEditingOperationController:(JRVideoEditingOperationController *)operationer didFinishEditUrl:(nullable NSURL *)url error:(nullable NSError *)error
{
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        localIdentifier = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset.localIdentifier;
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            if (localIdentifier) {
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    NSLog(@"save video success");
                }];
            }
            
        } else {
            NSLog(@"save video error:%@", error);
        }
        
    }];

}

- (void)videoEditingOperationControllerDidCancel:(JRVideoEditingOperationController *)operationer
{
    [operationer dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - private
- (void)loadUIConfig
{
    if (self.config) {
        self.eventField.text = self.config.event;
        NSString *title = nil;
        for (NSInteger i=0; i<self.fpsSegment.numberOfSegments; i++) {
            title = [self.fpsSegment titleForSegmentAtIndex:i];
            if (title.integerValue == self.config.fps) {
                self.fpsSegment.selectedSegmentIndex = i;
                break;
            }
        }
        [self.overlaySwitch setOn:self.config.overlayIsOn];
        self.recordSegment.selectedSegmentIndex = self.config.automatic ? 1 : 0;
        self.urlLinkField.text = self.config.musicList.firstObject;
    }
}

- (void)saveUIConfig
{
    if (self.eventField.text.length == 0) {
        NSLog(@"event is nil");
        return;
    }
    LFRecordConfig *config = [LFRecordConfig new];
    config.event = self.eventField.text;
    config.fps = [self.fpsSegment titleForSegmentAtIndex:self.fpsSegment.selectedSegmentIndex].integerValue;
    config.overlayIsOn = self.overlaySwitch.isOn;
    config.automatic = self.recordSegment.selectedSegmentIndex == 1;
    NSString *link = self.urlLinkField.text;
    if (link) {
        [config.musicList setArray:@[link]];
    }
    self.config = config;
}

@end
