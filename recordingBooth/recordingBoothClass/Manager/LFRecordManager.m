//
//  LFRecordManager.m
//  recordingBooth
//
//  Created by TsanFeng Lam on 2019/2/23.
//  Copyright © 2019 Marc. All rights reserved.
//

#import "LFRecordManager.h"

NSString * const lf_recordBasePath = @"lf_recordingBooth";
NSString * const lf_recordConfigPath = @"recordConfigPath";
NSString * const lf_recordFilePath = @"recordFilePath";

@interface NSString (lf_stringByAppendingPathComponent)

- (NSString *)lf_stringByAppendingPathComponent:(NSString *)str;

@end

@implementation NSString (lf_stringByAppendingPathComponent)

- (NSString *)lf_stringByAppendingPathComponent:(NSString *)str
{
    NSString *path = [self stringByAppendingPathComponent:str];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:path]) {
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"createFolder error: %@ \n",[error localizedDescription]);
            return nil;
        }
    }
    return path;
}

@end

@interface LFRecordManager()

@property (nonatomic, copy) NSString *recordBasePath;

@end

@implementation LFRecordManager

static LFRecordManager *sharedSelf = nil;

+ (LFRecordManager *)sharedRecordManager
{
    if (sharedSelf == nil) {
        sharedSelf = [[self alloc] init];
    }
    return sharedSelf;
}

+ (void)free
{
    sharedSelf = nil;
}

- (NSString *)recordBasePath
{
    if (!_recordBasePath) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        _recordBasePath = [documentPath lf_stringByAppendingPathComponent:lf_recordBasePath];
    }
    return _recordBasePath;
}

- (BOOL)recordConfigWriteToFile:(LFRecordConfig *)config
{
    NSString *configPath = [self.recordBasePath lf_stringByAppendingPathComponent:lf_recordConfigPath];
    if (config.event) {
        NSString *path = [configPath stringByAppendingPathComponent:config.event];
        return [config.objectData writeToFile:path atomically:YES];
    }
    return NO;
}

- (NSArray <NSString *>*)eventList
{
    NSString *configPath = [self.recordBasePath lf_stringByAppendingPathComponent:lf_recordConfigPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *array = [fileManager contentsOfDirectoryAtPath:configPath error:nil];
    
    return array;
}

- (LFRecordConfig *)recordConfigWithEventName:(NSString *)name
{
    if (name) {
        NSString *configPath = [self.recordBasePath lf_stringByAppendingPathComponent:lf_recordConfigPath];
        NSString *path = [configPath stringByAppendingPathComponent:name];
        NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
        return [LFRecordConfig modelWithObjectData:data];
    }
    return nil;
}

- (NSString *)filePathWithLink:(NSString *)link
{
    if (link) {
        NSString *filePath = [self.recordBasePath lf_stringByAppendingPathComponent:lf_recordFilePath];
        NSString *path = [filePath stringByAppendingPathComponent:link.lastPathComponent];
        return path;
    }
    return nil;
}

@end
