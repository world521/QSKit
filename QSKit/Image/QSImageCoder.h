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
}

#pragma mark - Decoder

@interface QSImageDecoder : NSObject 

@property (nonatomic, strong, readonly, nullable) NSData *data;
@property (nonatomic, assign, readonly) CGFloat scale;
@property (nonatomic, assign, readonly, getter=isFinalized) BOOL finalized;

+ (instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale;
- (instancetype)initWithScale:(CGFloat)scale;
- (BOOL)updateData:(NSData *)data final:(BOOL)final;

@end

NS_ASSUME_NONNULL_END
