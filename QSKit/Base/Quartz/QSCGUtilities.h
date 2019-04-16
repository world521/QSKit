//
//
//  QSCGUtilities.h
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/16.
//  Copyright © 2019 fqs. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "QSKitMacro.h"

QS_EXTERN_C_BEGIN

CGSize QSScreenSize(void);

#ifndef kScreenSize
#define kScreenSize
#endif

#ifndef kScreenWidth
#define kScreenWidth QSScreenSize().width
#endif

#ifndef kScreenHeight
#define kScreenHeight QSScreenSize().height
#endif


QS_EXTERN_C_END



