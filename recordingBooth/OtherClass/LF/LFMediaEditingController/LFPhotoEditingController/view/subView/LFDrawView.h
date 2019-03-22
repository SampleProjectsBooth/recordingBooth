//
//  LFDrawView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/23.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFDrawView : UIView

/** 线粗 */
@property (nonatomic, assign) CGFloat lineWidth;
/** 线颜色 */
@property (nonatomic, strong) UIColor *lineColor;
/** 正在绘画 */
@property (nonatomic, readonly) BOOL isDrawing;

@property (nonatomic, copy) void(^drawBegan)(void);
@property (nonatomic, copy) void(^drawEnded)(void);

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

/** 是否可撤销 */
- (BOOL)canUndo;
//撤销
- (void)undo;

@end
