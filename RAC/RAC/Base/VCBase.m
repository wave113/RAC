//
//  VCBase.m
//  RAC
//
//  Created by XiZhi on 2017/8/17.
//  Copyright © 2017年 XiaoTao. All rights reserved.
//

#import "VCBase.h"

@interface VCBase ()

@end

@implementation VCBase

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.hidden      = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
}



@end
