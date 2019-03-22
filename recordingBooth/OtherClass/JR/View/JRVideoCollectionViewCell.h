//
//  JRVideoCollectionViewCell.h
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRVideoClipInfo.h"

@protocol JRVideoCollectionViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface JRVideoCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, assign) BOOL isDelete;

@property (nonatomic, weak) id<JRVideoCollectionViewCellDelegate>delegate;

@property (nonatomic, strong) JRVideoClipInfo *clipInfo;

@end


@protocol JRVideoCollectionViewCellDelegate <NSObject>

- (void)videoCollectionViewCell:(JRVideoCollectionViewCell *)cell removeItem:(JRVideoClipInfo *)item;

@end

NS_ASSUME_NONNULL_END
