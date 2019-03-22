//
//  JRVideoCollectionViewCell.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRVideoCollectionViewCell.h"
#import "JRVideoPlayerViewController.h"
#import "UIImage+Bundle.h"

@interface JRVideoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;


@end

@implementation JRVideoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.deleteBtn setImage:[UIImage getImgFromJRVideoEditingBundleWithName:@"delete.png"] forState:(UIControlStateNormal)];
}

- (void)setIsDelete:(BOOL)isDelete
{
    _isDelete = isDelete;
    self.deleteBtn.hidden = !_isDelete;
}

+ (NSString *)identifier
{
    return NSStringFromClass([JRVideoCollectionViewCell class]);
}

- (IBAction)_deleteItemAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(videoCollectionViewCell:removeItem:)]) {
        [self.delegate videoCollectionViewCell:self removeItem:self.clipInfo];
    }
}

@end
