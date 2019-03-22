//
//  LFVideoCommandProtocol.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LFVideoCommandProtocol <NSObject>

@required
- (void)execute;

@end

NS_ASSUME_NONNULL_END
