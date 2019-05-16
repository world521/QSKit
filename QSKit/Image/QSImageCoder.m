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
        case QS_FOUR_CC('B', 'G', 'P', 0xFB): { // BPG
            return QSImageTypeBPG;
            break;
        }
        */
    }
    
    uint16_t magic2 = *((uint16_t *)bytes);
    switch (magic2) {
        case QS_TWO_CC('B', 'A'):
        case QS_TWO_CC('B', 'M'):
        case QS_TWO_CC('I', 'C'):
        case QS_TWO_CC('P', 'I'):
        case QS_TWO_CC('C', 'I'):
        case QS_TWO_CC('C', 'P'): { // BMP
            return QSImageTypeBMP;
            break;
        }
        case QS_TWO_CC(0xFF, 0x4F): { // JPEG2000
            return QSImageTypeJPEG2000;
            break;
        }
    }
    
    if (memcmp(bytes, "\377\330\377", 3) == 0) return QSImageTypeJPEG;
    
    if (memcmp(bytes + 4, "\152\120\040\040\015", 5) == 0) return QSImageTypeJPEG2000;
    
    return QSImageTypeUnknown;
}

#pragma mark - Decoder

@implementation QSImageDecoder {
    pthread_mutex_t _lock; // recursive lock
    BOOL _sourceTypeDetected;
#ifdef QSIMAGE_WEBP_ENABLED
    WebPDemuxer *_webpSource;
#endif
    
    dispatch_semaphore_t _framesLock;
    NSArray *_frames; // GGImageDecoderFrame
}

+ (instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale {
    if (!data) return nil;
    QSImageDecoder *decoder = [[QSImageDecoder alloc] initWithScale:scale];
    [decoder updateData:data final:YES];
    
    
    return decoder;
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
    return self;
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
    if (_sourceTypeDetected) {
        if (_type != type) {
            return NO;
        } else {
            [self _updateSource];
        }
    } else {
        if (_data.length > 16) {
            _type = type;
            _sourceTypeDetected = YES;
            [self _updateSource];
        }
    }
    return YES;
}

- (void)_updateSource {
    switch (_type) {
        case QSImageTypeWebP: {
            [self _updateSourceWebP];
            break;
        }
        case QSImageTypePNG: {
            [self _updateSourceAPNG];
            break;
        }
        default: {
            [self _updateSourceImageIO];
            break;
        }
    }
}

- (void)_updateSourceWebP {
#ifdef QSIMAGE_WEBP_ENABLED
    _width = 0;
    _height = 0;
    _loopCount = 0;
    if (_webpSource) WebPDemuxDelete(_webpSource);
    _webpSource = NULL;
    
    dispatch_semaphore_wait(_framesLock, DISPATCH_TIME_FOREVER);
    _frames = nil;
    dispatch_semaphore_signal(_framesLock);
    
    
    
    
    
#endif
}

- (void)_updateSourceAPNG {
    
}

- (void)_updateSourceImageIO {
    
}

@end
