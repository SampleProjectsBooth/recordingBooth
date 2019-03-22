//
//  JRHorizontalCollectioView.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRVideoClipInfo.h"

@protocol JRHorizontalCollectioViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface JRHorizontalCollectioView : UIView

@property (nonatomic, readonly) CGFloat height;

@property (nonatomic, readonly) NSArray <JRVideoClipInfo *>*dataSource;

@property (nonatomic, weak) id<JRHorizontalCollectioViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addJRVideoClipInfo:(JRVideoClipInfo *)info;

//- (void)removeJRVideoClipInfo:(JRVideoClipInfo *)info;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(JRVideoClipInfo *)object;


@property (nonatomic, assign) BOOL editEnable;

@end


@protocol JRHorizontalCollectioViewDelegate <NSObject>

@optional

- (BOOL)canRemoveItem;

- (void)horizontalCollectioView:(JRHorizontalCollectioView *)collectioView didDeleteItem:(JRVideoClipInfo *)info;

- (void)horizontalCollectioView:(JRHorizontalCollectioView *)collectioView didSelectItemAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
