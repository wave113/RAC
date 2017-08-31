//
//  VCMenu.m
//  RAC
//
//  Created by XiZhi on 2017/8/17.
//  Copyright © 2017年 XiaoTao. All rights reserved.
//

#import "VCMenu.h"
#import "VCSignal.h"
#import "VCSubject.h"
#import "VCRACCommand.h"

@interface VCMenu ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) NSArray       * dataArray;
@property (nonatomic,strong) UITableView   * mainTableView;

@end

@implementation VCMenu

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"RAC";
    
    [self.view addSubview:self.mainTableView];
}

- (NSArray *)dataArray {
    if (_dataArray == nil) {
        
        NSArray * array = @[
                            NSStringFromClass([VCSignal class]),
                            NSStringFromClass([VCSubject class]),
                            NSStringFromClass([VCRACCommand class])
                            ];
        
        _dataArray = array;
        
    }
    return _dataArray;
}

- (UITableView *)mainTableView {
    if (_mainTableView == nil) {
        UITableView * tableView                  = [[UITableView alloc] initWithFrame:CGRectMake(0,0.5, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height)
                                                                                style:UITableViewStylePlain];
        tableView.showsVerticalScrollIndicator   = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.dataSource                     = self;
        tableView.delegate                       = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        tableView.rowHeight                      = 49.f;
        
        _mainTableView = tableView;
    }
    return _mainTableView;
}

#pragma mark tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.accessoryType    = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text   = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString * className = self.dataArray[indexPath.row];
    UIViewController * viewController = [NSClassFromString(className) new];
    viewController.title = className;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
