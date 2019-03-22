//
//  JRCameraVideoViewController.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/8.
//  Copyright © 2019 djr. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JRCaremaFPSType) {
    JRCaremaFPSType30 = 30,
    JRCaremaFPSType60 = 60,
    JRCaremaFPSType120 = 120,
    JRCaremaFPSType240 = 240,
};

NS_ASSUME_NONNULL_BEGIN

@interface JRCameraVideoViewController : UIViewController

+ (void)showRecordVideoViewControllerWithVC:(UIViewController *)vc fps:(JRCaremaFPSType)fps;
+ (void)showRecordVideoViewControllerWithVC:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
