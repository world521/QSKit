//
//
//  TableViewController.m
//  QSKitExample
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/15.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import "AllFontTableController.h"
#import "QSCGUtilities.h"

@interface AllFontTableController ()
@property (nonatomic, strong) NSMutableArray <NSDictionary *>*fontArray;
@end

@implementation AllFontTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.fontArray = [NSMutableArray array];
    NSArray *familyNamesAll = [UIFont familyNames];
    
    for (NSString* family in familyNamesAll) {
        NSMutableDictionary *fontD = [NSMutableDictionary dictionary];
        fontD[@"family"] = family;
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray* fonts = [UIFont fontNamesForFamilyName:family];
        for (NSString *font in fonts) {
            [array addObject:font];
        }
        
        fontD[@"fonts"] = array;
        [self.fontArray addObject:fontD];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fontArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fontArray[section][@"fonts"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *fontN = self.fontArray[indexPath.section][@"fonts"][indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:fontN size:20];
    cell.textLabel.text = [NSString stringWithFormat:@"你好 Hello World(%@)", fontN];
    cell.textLabel.textColor = [UIColor colorWithHue:indexPath.row % 25 / 25.0 saturation:1 brightness:0.9 alpha:1];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -150) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
        header.contentView.backgroundColor = [UIColor lightGrayColor];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth, 50)];
        lb.font = [UIFont systemFontOfSize:16];
        lb.textColor = [UIColor blackColor];
        lb.tag = 50;
        [header.contentView addSubview:lb];
    }
    UILabel *lb = [header viewWithTag:50];
    lb.text = self.fontArray[section][@"family"];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}


@end
