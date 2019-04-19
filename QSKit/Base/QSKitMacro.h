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
#import "pthread.h"

#ifndef QSKitMacro_h
#define QSKitMacro_h

// 使用C编译器编译
#ifdef __cplusplus
#define QS_EXTERN_C_BEGIN extern "C" {
#define QS_EXTERN_C_END }
#else
#define QS_EXTERN_C_BEGIN
#define QS_EXTERN_C_END
#endif


QS_EXTERN_C_BEGIN

// 防止打包静态库时，因为category文件而报错
#ifndef QSSYNTH_DUMMY_CLASS
#define QSSYNTH_DUMMY_CLASS(_name_) \
@interface QSSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end\
@implementation QSSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif


static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define QSMUTEX_ASSERT_ON_ERROR(x_) \
do { \
    __unused volatile int res = (x_); \
    assert(res == 0); \
} while(0)
    assert(mutex != NULL);
    if (!recursive) {
        pthread_mutex_init(mutex, NULL);
    } else {
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(mutex, &attr);
        pthread_mutexattr_destroy(&attr);
    }
#undef QSMUTEX_ASSERT_ON_ERROR
}

QS_EXTERN_C_END

#endif
