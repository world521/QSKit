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

#pragma mark - Decoder

@interface QSImageDecoder : NSObject

@property (nonatomic, readonly) CGFloat scale;

- (instancetype)initWithScale:(CGFloat)scale;
+ (instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale;
- (BOOL)updateData:(NSData *)data final:(BOOL)final;

@end

NS_ASSUME_NONNULL_END
