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
#import "QSKitMacro.h"

#pragma mark - Utility (for little endian platform 小端模式平台)

#define QS_FOUR_CC(c1, c2, c3, c4) ((uint32_t)((c4 << 24) | (c3 << 16) | (c2 << 8) | (c1)))
#define QS_TWO_CC(c1, c2) ((uint16_t)((c2 << 8) | (c1)))


#pragma mark - Helper

QSImageType QSImageDetectType(CFDataRef data) {
    if (!data) return QSImageTypeUnknown;
    uint64_t length = CFDataGetLength(data);
    if (length < 16) return QSImageTypeUnknown;
    
    const char *bytes = (char *)CFDataGetBytePtr(data);
    
    uint32_t magic4 = *((uint32_t *)bytes);
    switch (magic4) {
        case QS_FOUR_CC(0x4D, 0x4D, 0x00, 0x2A): { // big endian TIFF
            return QSImageTypeTIFF;
            break;
        }
        case QS_FOUR_CC(0x49, 0x49, 0x2A, 0x00): { // little endian TIFF
            return QSImageTypeTIFF;
            break;
        }
        case QS_FOUR_CC(0x00, 0x00, 0x01, 0x00): { // ICO
            return QSImageTypeICO;
            break;
        }
        case QS_FOUR_CC('i', 'c', 'n', 's'): { // ICNS
            return QSImageTypeICNS;
            break;
        }
        case QS_FOUR_CC('G', 'I', 'F', '8'): { // GIF
            return QSImageTypeGIF;
            break;
        }
        case QS_FOUR_CC(0x89, 'P', 'N', 'G'): { // PNG
            return QSImageTypePNG;
            break;
        }
        case QS_FOUR_CC('R', 'I', 'F', 'F'): { // WebP
            return QSImageTypeWebP;
            break;
        }
        /*
        case QS_FOUR_CC('B', 'G', 'P', 0xFB): { //BPG
            return QSImageTypeBPG;
            break;
        }
        */
    }
    
    uint16_t magic2 = *((uint16_t *)bytes);
    switch (magic2) {
        case QS_TWO_CC('B', 'A'):
        case QS_TWO_CC('B', 'M'):
        case QS_TWO_CC('', ''):
        case QS_TWO_CC('', ''):
        case QS_TWO_CC('', ''):
        case QS_TWO_CC('', ''): {
            break;
        }
        
    }
    
}

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
    pthread_mutex_init_recursive(&_lock, true);
    return nil;
}

// Updates the incremental image with new data.
- (BOOL)updateData:(NSData *)data final:(BOOL)final {
    BOOL result = NO;
    pthread_mutex_lock(&_lock);
    result = [self _updateData:data final:final];
    pthread_mutex_unlock(&_lock);
    return result;
}

#pragma mark - private

- (BOOL)_updateData:(NSData *)data final:(BOOL)final {
    if (_finalized) return NO;
    if (data.length < _data.length) return NO;
    
    _finalized = final;
    _data = data;
    
    QSImageType type = QSImageDetectType((__bridge CFDataRef)data);
}

@end
