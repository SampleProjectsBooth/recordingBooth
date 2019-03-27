//
//  JRRecordVideoController.m
//  recordingBooth
//
//  Created by 丁嘉睿 on 2019/3/27.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "JRRecordVideoController.h"
#import "JRRecordVideoViewController.h"

@interface JRRecordVideoController () <JRRecordVideoViewControllerDelegate>


@end

@implementation JRRecordVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES];
}

#pragma mark - Public Methods
- (instancetype)initWihFPS:(NSUInteger)fps sessionPreset:(AVCaptureSessionPreset)sessionPreset
{
    self = [super init];
    if (self) {
        [self _createCaremaWithFPS:fps sessionPreset:sessionPreset];
    } return self;
}

#pragma mark - Setter And Getter
- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    id obj = [self.viewControllers firstObject];
    if ([obj isKindOfClass:[JRRecordVideoViewController class]]) {
        JRRecordVideoViewController *vc = (JRRecordVideoViewController *)obj;
        vc.saveURL = videoURL;
    }
}

#pragma mark - Private Methods
- (void)_createCaremaWithFPS:(NSUInteger)fps sessionPreset:(AVCaptureSessionPreset)sessionPreset
{
    JRRecordVideoViewController *vc = [[JRRecordVideoViewController alloc] initWithFPS:fps sessionPreset:sessionPreset];
    vc.recordDelegate = self;
    NSArray *array = @[vc];
    self.viewControllers = array;
}

#pragma mark - JRRecordVideoViewControllerDelegate
- (void)didFinishRecordVideoVC:(JRRecordVideoViewController *)recordVC url:(NSURL *)url error:(nullable NSError *)error
{
    if ([self.recordDelegate respondsToSelector:@selector(recordVideoController:didFinishVideoURL:error:)]) {
        [self.recordDelegate recordVideoController:self didFinishVideoURL:url error:error];
    }
}

- (void)didCancelRecordVideoVC:(JRRecordVideoViewController *)recordVC
{
    if ([self.recordDelegate respondsToSelector:@selector(recordVideoControllerDidCancel:)]) {
        [self.recordDelegate recordVideoControllerDidCancel:self];
    }
}

@end
