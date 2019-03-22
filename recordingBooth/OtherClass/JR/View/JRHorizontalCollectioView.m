//
//  JRHorizontalCollectioView.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/6.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRHorizontalCollectioView.h"
#import "JRVideoCollectionViewCell.h"

@interface JRHorizontalCollectioView () <UICollectionViewDelegate, UICollectionViewDataSource, JRVideoCollectionViewCellDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation JRHorizontalCollectioView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = self.height;
    self = [super initWithFrame:frame];
    if (self) {
        self.data = @[].mutableCopy;
        [self _createCollectionView];
    } return self;
}


- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    rect.size.height = self.height;
    self.bounds = rect;
}


- (void)addJRVideoClipInfo:(JRVideoClipInfo *)info
{
    [self.data addObject:info];
    [self.collectionView reloadData];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(JRVideoClipInfo *)object
{
    if (self.data.count >= index) {
        [self.data replaceObjectAtIndex:index withObject:object];
        [self.collectionView reloadData];
    }
}

- (void)removeJRVideoClipInfo:(JRVideoClipInfo *)info
{
    [self.data removeObject:info];
    [self.collectionView reloadData];
}

- (NSArray *)dataSource
{
    return [self.data copy];
}

- (CGFloat)height
{
    return 120.f;
}

#pragma mark - Private Methods
- (void)_createCollectionView
{
    UINib *nibCell = [UINib nibWithNibName:[JRVideoCollectionViewCell identifier] bundle:nil];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(120.f, 120.f);
    
    UICollectionView *collectionView1 = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectionView1.delegate = self;
    collectionView1.dataSource = self;
    collectionView1.backgroundColor = [UIColor clearColor];
    collectionView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:collectionView1];
    self.collectionView = collectionView1;
    
    [self.collectionView registerNib:nibCell forCellWithReuseIdentifier:[JRVideoCollectionViewCell identifier]];

}


#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.data.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    JRVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[JRVideoCollectionViewCell identifier] forIndexPath:indexPath];
    JRVideoClipInfo *lastInfo = [self.data lastObject];
    JRVideoClipInfo *info = [self.data objectAtIndex:indexPath.row];
    cell.delegate = self;
    BOOL delete = NO;
    if ([self.delegate respondsToSelector:@selector(canRemoveItem)]) {
        delete = [self.delegate canRemoveItem];
    }
    cell.isDelete = NO;
    if ([info isEqual:lastInfo] && delete) {
        cell.isDelete = YES;
    }
    cell.clipInfo = info;
    cell.imageView.image = info.image;
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(horizontalCollectioView:didSelectItemAtIndex:)]) {
        [self.delegate horizontalCollectioView:self didSelectItemAtIndex:indexPath.row];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.f, 5.f, 0.f, 5.f);
}

#pragma mark - JRVideoCollectionViewCellDelegate
- (void)videoCollectionViewCell:(JRVideoCollectionViewCell *)cell removeItem:(JRVideoClipInfo *)item
{
    [self removeJRVideoClipInfo:item];
    if ([self.delegate respondsToSelector:@selector(horizontalCollectioView:didDeleteItem:)]) {
        [self.delegate horizontalCollectioView:self didDeleteItem:item];
    }
}

@end
