//
//
//  QSImage.h
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/19.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import <UIKit/UIKit.h>
#import "QSAnimatedImageView.h"
#import "QSImageCoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface QSImage : UIImage
+ (nullable QSImage *)imageNamed:(NSString *)name; // no cache
+ (nullable QSImage *)imageWithContentsOfFile:(NSString *)path;
+ (nullable QSImage *)imageWithData:(NSData *)data;
+ (nullable QSImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;
@end

NS_ASSUME_NONNULL_END
