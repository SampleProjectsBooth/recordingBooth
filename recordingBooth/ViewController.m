//
//  ViewController.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "ViewController.h"
#import "LFRecordingBoothController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onClick:(id)sender {
    LFRecordingBoothController *recordingBooth = [LFRecordingBoothController new];
    [self presentViewController:recordingBooth animated:YES completion:nil];
}

@end
