//
//  LFRecordingBoothController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFRecordingBoothController.h"
#import "LFConfigRecordingBoothController.h"

@interface LFRecordingBoothController ()

@end

@implementation LFRecordingBoothController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self pushConfigRecordingVC];
}

- (void)pushConfigRecordingVC {
    LFConfigRecordingBoothController *configVC = [[LFConfigRecordingBoothController alloc] init];
    [self setViewControllers:@[configVC] animated:YES];
}

#pragma mark - Public

- (void)cancelButtonClick {
    [self dismissViewControllerAnimated:YES completion:^{
        [self callDelegateMethod];
    }];
}

- (void)callDelegateMethod {
    if ([self.recordingBoothDelegate respondsToSelector:@selector(lf_recordingBoothControllerDidCancel:)]) {
        [self.recordingBoothDelegate lf_recordingBoothControllerDidCancel:self];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    for (UIViewController *childVC in self.childViewControllers) {
        if ([childVC respondsToSelector:@selector(viewDidDealloc)]) {
            [childVC performSelector:@selector(viewDidDealloc)];
        }
    }
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)viewDidDealloc
{
    
}

@end
