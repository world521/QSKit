//
//
//  QSImageCoder.h
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/19.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import <UIKit/UIKit.h>

#ifndef QSIMAGE_WEBP_ENABLED
#if __has_include(<webp/decode.h>) && __has_include(<webp/encode.h>) \
&& __has_include(<webp/demux.h>) && __has_include(<webp/mux.h>)
#define QSIMAGE_WEBP_ENABLED 1
#import <webp/decode.h>
#import <webp/encode.h>
#import <webp/demux.h>
#import <webp/mux.h>
#elif __has_include("webp/decode.h") && __has_include("webp/encode.h") \
&& __has_include("webp/demux.h") && __has_include("webp/mux.h")
#import "webp/decode.h"
#import "webp/encode.h"
#import "webp/demux.h"
#import "webp/mux.h"
#else
#define QSIMAGE_WEBP_ENABLED 0
#endif
#endif


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QSImageType) {
    QSImageTypeUnknown = 0, // unknown
    QSImageTypeJPEG,        // jpeg, jpg
    QSImageTypeJPEG2000,    // jp2
    QSImageTypeTIFF,        // tiff, tif
    QSImageTypeBMP,         // bmp
    QSImageTypeICO,         // ico
    QSImageTypeICNS,        // icns
    QSImageTypeGIF,         // gif
    QSImageTypePNG,         // png
    QSImageTypeWebP,        // webp
    QSImageTypeOther        // other image format
};

#pragma mark - Decoder

@interface QSImageDecoder : NSObject 

@property (nonatomic, strong, readonly, nullable) NSData *data;
@property (nonatomic, assign, readonly) QSImageType type;
@property (nonatomic, assign, readonly) CGFloat scale;
@property (nonatomic, assign, readonly, getter=isFinalized) BOOL finalized;
@property (nonatomic, assign, readonly) NSUInteger width;
@property (nonatomic, assign, readonly) NSUInteger height;
@property (nonatomic, assign, readonly) NSUInteger loopCount;
@property (nonatomic, assign, readonly) NSUInteger frameCount;

+ (instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale;
- (instancetype)initWithScale:(CGFloat)scale;
- (BOOL)updateData:(NSData *)data final:(BOOL)final;

@end

NS_ASSUME_NONNULL_END
