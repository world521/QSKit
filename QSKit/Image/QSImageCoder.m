//
//
//  QSImageCoder.m
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/19.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import "QSImageCoder.h"
#import "pthread.h"

@implementation QSImageDecoder {
    pthread_mutex_t _lock; // recursive lock
    dispatch_semaphore_t _framesLock;
}

+ (instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale {
    if (!data) return nil;
    QSImageDecoder *decoder = [[QSImageDecoder alloc] initWithScale:scale];
    [decoder updateData:data final:YES];
    
    
    return nil;
}

- (instancetype)init {
    return [self initWithScale:[UIScreen mainScreen].scale];
}

- (instancetype)initWithScale:(CGFloat)scale {
    self = [super init];
    if (scale <= 0) scale = 1;
    
    _scale = scale;
    _framesLock = dispatch_semaphore_create(1);
    pthread_mutex_init_
}

- (BOOL)updateData:(NSData *)data final:(BOOL)final {
    
}

@end
