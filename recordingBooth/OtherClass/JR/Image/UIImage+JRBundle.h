//
//  UIImage+JRBundle.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/15.
//  Copyright © 2019 djr. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JRBundle)

/**
 获取bundle内图片资源
 
 @param name name
 @return UIImage
 */
+ (UIImage *)jr_getImgFromJRVideoEditingBundleWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
