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

////////////////////////////////////////////////////////////////////////////////////

@implementation QSImageFrame

+ (instancetype)frameWithImage:(UIImage *)image {
    QSImageFrame *frame = [[QSImageFrame alloc] init];
    frame.image = image;
    return frame;
}

- (id)copyWithZone:(NSZone *)zone {
    QSImageFrame *frame = [[[self class] alloc] init];
    frame.index = _index;
    frame.width = _width;
    frame.height = _height;
    frame.offsetX = _offsetX;
    frame.offsetY = _offsetY;
    frame.duration = _duration;
    frame.dispose = _dispose;
    frame.blend = _blend;
    frame.image = [_image copy];
    return frame;
}

@end

////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Decoder

@interface _QSImageDecoderFrame : QSImageFrame

@property (nonatomic, assign) BOOL hasAlpha;
@property (nonatomic, assign) BOOL isFullSize;
@property (nonatomic, assign) NSUInteger blendFromIndex;

@end

@implementation _QSImageDecoderFrame

- (id)copyWithZone:(NSZone *)zone {
    _QSImageDecoderFrame *frame = [super copyWithZone:zone];
    frame.hasAlpha = _hasAlpha;
    frame.isFullSize = _isFullSize;
    frame.blendFromIndex = _blendFromIndex;
    return frame;
}

@end

////////////////////////////////////////////////////////////////////////////////////

@implementation QSImageDecoder {
    pthread_mutex_t _lock; // recursive lock
    BOOL _sourceTypeDetected;
#ifdef QSIMAGE_WEBP_ENABLED
    WebPDemuxer *_webpSource;
#endif
    
    dispatch_semaphore_t _framesLock;
    NSArray *_frames; // GGImageDecoderFrame
    BOOL _needBlend;
    NSUInteger _blendFrameIndex;
    CGContextRef _blendCanvas;
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
    
    /*
     https://developers.google.com/speed/webp/docs/api
     */
    WebPData webpData = {0};
    webpData.bytes = _data.bytes;
    webpData.size = _data.length;
    WebPDemuxer *demuxer = WebPDemux(&webpData);
    if (!demuxer) return;
    
    uint32_t webpFrameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT);
    uint32_t webpLoopCount = WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT);
    uint32_t canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
    uint32_t canvasHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
    if (webpFrameCount == 0 || canvasWidth < 1 || canvasHeight < 1) {
        WebPDemuxDelete(demuxer);
        return;
    }
    
    NSMutableArray *frames = [NSMutableArray array];
    BOOL needBlend = NO;
    uint32_t iterIndex = 0;
    uint32_t lastBlendIndex = 0;
    WebPIterator iter = {0};
    
    if (WebPDemuxGetFrame(demuxer, 1, &iter)) {
        do {
            _QSImageDecoderFrame *frame = [[_QSImageDecoderFrame alloc] init];
            [frames addObject:frame];
            
            if (iter.dispose_method == WEBP_MUX_DISPOSE_NONE) {
                frame.dispose = QSImageDisposeBackground;
            }
            if (iter.blend_method == WEBP_MUX_BLEND) {
                frame.blend = QSImageBlendOver;
            }
            
            int canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
            int canvasHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
            frame.index = iterIndex;
            frame.duration = iter.duration / 1000.0;
            frame.width = iter.width;
            frame.height = iter.height;
            frame.hasAlpha = iter.has_alpha;
            frame.blend = iter.blend_method == WEBP_MUX_BLEND;
            frame.offsetX = iter.x_offset;
            frame.offsetY = canvasHeight - iter.y_offset - iter.height;
            
            BOOL sizeEqualToCanvas = (iter.width == canvasWidth && iter.height == canvasHeight);
            BOOL offsetIsZero = (iter.x_offset == 0 && iter.y_offset == 0);
            frame.isFullSize = sizeEqualToCanvas && offsetIsZero;
            
            if ((!frame.blend || !frame.hasAlpha) && frame.isFullSize) {
                frame.blendFromIndex = lastBlendIndex = iterIndex;
            } else {
                if (frame.dispose && frame.isFullSize) {
                    frame.blendFromIndex = lastBlendIndex;
                    lastBlendIndex = iterIndex + 1;
                } else {
                    frame.blendFromIndex = lastBlendIndex;
                }
            }
            if (frame.index != frame.blendFromIndex) needBlend = YES;
            iterIndex++;
        } while (WebPDemuxNextFrame(&iter));
        WebPDemuxReleaseIterator(&iter);
    }
    
    if (frames.count != webpFrameCount) {
        WebPDemuxDelete(demuxer);
        return;
    }
    
    _width = canvasWidth;
    _height = canvasHeight;
    _frameCount = frames.count;
    _loopCount = webpLoopCount;
    _needBlend = needBlend;
    _webpSource = demuxer;
    dispatch_semaphore_wait(_framesLock, DISPATCH_TIME_FOREVER);
    _frames = frames;
    dispatch_semaphore_signal(_framesLock);
#else
    static const char *func = __FUNCTION__;
    static const int line = __LINE__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[%s: %d] WebP is not available, check the documentation to see how to install WebP component", func, line);
    });
#endif
}

- (void)_updateSourceAPNG {
#warning APNG decoder
}

- (void)_updateSourceImageIO {
#warning ImageIO.framework
}

@end
