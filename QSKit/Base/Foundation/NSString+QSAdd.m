//
//
//  NSString+QSAdd.m
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/19.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import "NSString+QSAdd.h"
#import "QSKitMacro.h"

QSSYNTH_DUMMY_CLASS(NSString_QSAdd)

@implementation NSString (QSAdd)

- (NSString *)stringByAppendingNameScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) {
        return self.copy;
    }
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

@end
