//
//
//  QSKitMacro.h
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/16.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import <UIKit/UIKit.h>

#ifndef QSKitMacro_h
#define QSKitMacro_h

#ifdef __cplusplus
#define QS_EXTERN_C_BEGIN extern "C" {
#define QS_EXTERN_C_END }
#else
#define QS_EXTERN_C_BEGIN
#define QS_EXTERN_C_END
#endif

QS_EXTERN_C_BEGIN




QS_EXTERN_C_END

#endif
