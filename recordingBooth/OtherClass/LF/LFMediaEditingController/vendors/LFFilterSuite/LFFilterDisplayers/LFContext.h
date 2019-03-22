//
//  LFContext.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LFContextType) {
    
    /**
     Automatically choose an appropriate LFContext context
     */
    LFContextTypeAuto,
    
    /**
     Create a hardware accelerated LFContext with CoreGraphics
     */
    LFContextTypeCoreGraphics,
    
    /**
     Create a hardware accelerated LFContext with EAGL (OpenGL)
     */
    LFContextTypeEAGL,
    
    /**
     Creates a standard LFContext hardware accelerated.
     */
    LFContextTypeDefault,
};


extern NSString *__nonnull const LFContextOptionsCGContextKey;
extern NSString *__nonnull const LFContextOptionsEAGLContextKey;

@interface LFContext : NSObject

/**
 The CIContext
 */
@property (readonly, nonatomic) CIContext *__nonnull CIContext;

/**
 The type with with which this LFContext was created
 */
@property (readonly, nonatomic) LFContextType type;

/**
 Will be non null if the type is LFContextTypeEAGL
 */
@property (readonly, nonatomic) EAGLContext *__nullable EAGLContext;

/**
 Will be non null if the type is LFContextTypeCoreGraphics
 */
@property (readonly, nonatomic) CGContextRef __nullable CGContext;

/**
 Create and returns a new context with the given type. You must check
 whether the contextType is supported by calling +[LFContext supportsType:] before.
 */
+ (LFContext *__nonnull)contextWithType:(LFContextType)type options:(NSDictionary *__nullable)options;

/**
 Returns whether the contextType can be safely created and used using +[LFContext contextWithType:]
 */
+ (BOOL)supportsType:(LFContextType)contextType;

/**
 The context that will be used when using an Auto context type;
 */
+ (LFContextType)suggestedContextType;

@end

NS_ASSUME_NONNULL_END
