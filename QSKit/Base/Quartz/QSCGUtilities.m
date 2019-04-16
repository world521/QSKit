//
//
//  QSCGUtilities.m
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/16.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import "QSCGUtilities.h"

CGSize QSScreenSize(void) {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.width > size.height) {
            CGFloat tmp = size.width;
            size.width = size.height;
            size.height = tmp;
        }
    });
    return size;
}
