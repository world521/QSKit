//
//
//  ViewController.m
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/15.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import "ViewController.h"
#import "QSCGUtilities.h"
#import "AllFontTableController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showAllFonts];
}

- (void)showAllFonts {
    UIButton *fontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fontBtn.bounds = CGRectMake(0, 0, 100, 30);
    [fontBtn setTitle:@"所有字体" forState:UIControlStateNormal];
    [fontBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    fontBtn.center = CGPointMake(kScreenWidth * 0.5, kScreenHeight * 0.5);
    [fontBtn addTarget:self action:@selector(pushFontVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fontBtn];
}

- (void)pushFontVC {
    [self presentViewController:[AllFontTableController new] animated:YES completion:nil];
}


@end
