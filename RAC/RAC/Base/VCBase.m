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
    
    self.view.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1.0];
    
}



@end
