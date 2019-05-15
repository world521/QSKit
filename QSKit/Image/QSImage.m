//
//
//  QSImage.m
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/19.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import "QSImage.h"
#import "NSBundle+QSAdd.h"
#import "NSString+QSAdd.h"
#import "QSImageCoder.h"

@implementation QSImage {
    dispatch_semaphore_t _preloadedLock;
}

+ (nullable QSImage *)imageNamed:(NSString *)name {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return nil;
    
    NSString *res = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSString *path = nil;
    CGFloat scale = 1;
    
    //加上 @1x @2x @3x
    NSArray *exts = ext.length ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng"];
    NSArray *scales = [NSBundle preferredScales];
    for (int s = 0; s < scales.count; s++) {
        scale = [scales[s] floatValue];
        NSString *scaleName = [res stringByAppendingNameScale:scale];
        for (NSString *e in exts) {
            path = [[NSBundle mainBundle] pathForResource:scaleName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    if (path.length == 0) return nil;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) return nil;
    
    return [[self alloc] initWithData:data scale:scale];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    if (data.length == 0) return nil;
    if (scale < 0) scale = [UIScreen mainScreen].scale;
    
    _preloadedLock = dispatch_semaphore_create(1);
    
    @autoreleasepool {
        QSImageDecoder *decode = 
    }

    return nil;
}

@end
