//
//  LFAVAsset.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFAVAssetData : NSObject

/** 原视频 */
@property (nonatomic, readonly) AVAsset *asset;
/** 编辑视频 */
@property (nonatomic, readonly) AVMutableComposition *composition;
/** 视频数据 */
@property (nonatomic, readonly) AVMutableVideoComposition *videoComposition;
@property (nonatomic, readonly) AVMutableAudioMix *audioMix;

@property (nonatomic, readonly) AVMutableCompositionTrack *videoCompositionTrack;
@property (nonatomic, readonly) AVMutableCompositionTrack *audioCompositionTrack;
@property (nonatomic, readonly) CGSize videoSize;

- (id)initWithAsset:(AVAsset *)asset;
- (id)initWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
