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

//#import "JRClipVideoEditingViewController.h"
#import "JRVideoEditingOperationController.h"

@interface LFConfigRecordingBoothController () <JRVideoEditingOperationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fpsSegment;
@property (weak, nonatomic) IBOutlet UISwitch *overlaySwitch;
@property (weak, nonatomic) IBOutlet UITextField *urlLinkField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *recordSegment;

@property (nonatomic, strong) LFRecordConfig *config;

@end

@implementation LFConfigRecordingBoothController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
                    [self.config.musicList setArray:@[path]];
                } else {
                    NSLog(@"file save fail : %@", link);
                }
            }];
        };
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"link" message:@"This link has been downloaded. Do you want to download again?" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
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
    [self saveOnClick:nil];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"SampleVideo" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:url];
//    JRClipVideoEditingViewController *vc = [[JRClipVideoEditingViewController alloc] initWithVideoAsset:asset placeholderImage:[asset lf_firstImage:nil]];
//    vc.operationDelegate = self;
//    [self presentViewController:vc animated:YES completion:nil];
    
    JRVideoEditingOperationController *nav = [[JRVideoEditingOperationController alloc] initWithAsset:asset];
    nav.operationDelegate = self;
    nav.maxClippingDuration = 10.f;
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)startOnClick:(id)sender {
    NSLog(@"start record");
    [self saveOnClick:nil];
    
    
}

#pragma mark - private
- (void)loadUIConfig
{
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
    NSString *path = [[LFRecordManager sharedRecordManager] filePathWithLink:self.urlLinkField.text];
    if (path) {
        [config.musicList setArray:@[path]];
    }
    self.config = config;
}

#pragma mark - JRVideoEditingOperationControllerDelegate

- (void)videoEditingOperationController:(JRVideoEditingOperationController *)operationer didFinishEditUrl:(NSURL *)url
{
    NSLog(@"videoEditingOperationControllerdidFinishEditUrl");
}

- (void)videoEditingOperationControllerDidCancel:(JRVideoEditingOperationController *)operationer error:(nullable NSError *)error
{
    [operationer dismissViewControllerAnimated:YES completion:^{
        
    }];
    NSLog(@"videoEditingOperationControllerDidCancel");
}

@end
