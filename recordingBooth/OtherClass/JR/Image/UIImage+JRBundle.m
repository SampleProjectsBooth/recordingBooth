//
//  UIImage+JRBundle.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/15.
//  Copyright © 2019 djr. All rights reserved.
//

#import "UIImage+JRBundle.h"

@implementation UIImage (JRBundle)

+ (UIImage *)jr_getImgFromJRVideoEditingBundleWithName:(NSString *)name
{
    UIImage *image = nil;
    if (name.length > 0) {
        NSString *extension = name.length ? (name.pathExtension.length ? name.pathExtension : @"png") : nil;
        NSString *defaultName = [name stringByDeletingPathExtension];
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"JRVideoPlayerViewController")] pathForResource:@"JRVideoEditing" ofType:@"bundle"]];
        image = [UIImage imageWithContentsOfFile:[bundle pathForResource:defaultName ofType:extension]];
    }
    return image;
    
}

@end
