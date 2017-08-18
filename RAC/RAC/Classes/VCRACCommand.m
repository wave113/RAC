//
//  VCRACCommand.m
//  RAC
//
//  Created by XiZhi on 2017/8/18.
//  Copyright © 2017年 XiaoTao. All rights reserved.
//

#import "VCRACCommand.h"
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

@interface VCRACCommand ()

@end

@implementation VCRACCommand

/*
    RACCommand:用于处理事件的类,可以撞我事件如何处理,事假中数据如何传递,可以很方便的监控事件的执行过程
 
    RACCommand的使用
        1.创建方法 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
        2.在signalBlock中,创建RACSignal,并且作为signalBlock的返回值
        3.执行命令 -(RACSignal *)execute:(id)input, 返回一个信号
    RACCommand使用注意点
        1.signalBlock必须返回一个信号,不能返回nil,如果想要返回空信号,使用[RACSignal empty]
        2.如果RACCommand中的信号中数据传输完毕,必须调用[subscriber sendCompleted],只有这样才认为命令执行完毕,否则会一直处于执行中
        3.RACCommand需要被强引用,否则接受不到RACCommand中的信号 RACCommand中的信号是延迟发送的
 
 */


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}


@end
