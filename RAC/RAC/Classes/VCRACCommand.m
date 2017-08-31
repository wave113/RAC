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

@interface VCRACCommand () {
    RACCommand * _command;
}

@end

@implementation VCRACCommand

/*
    RACCommand:用于处理事件的类,可以掌握事件如何处理,事假中数据如何传递,可以很方便的监控事件的执行过程
 
    一:RACCommand的使用
        1.创建方法 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
        2.在signalBlock中,创建RACSignal,并且作为signalBlock的返回值
        3.执行命令 -(RACSignal *)execute:(id)input, 返回一个信号
 
    二:RACCommand使用注意点
        1.signalBlock必须返回一个信号,不能返回nil,如果想要返回空信号,使用[RACSignal empty]
        2.如果RACCommand中的信号中数据传输完毕,必须调用[subscriber sendCompleted],只有这样才认为命令执行完毕,否则会一直处于执行中
        3.RACCommand需要被强引用,否则接受不到RACCommand中的信号 RACCommand中的信号是延迟发送的
 
    三:RACCommend使用(围绕signalBlock返回的信号)
        1.在RAC开发中,通常会使用RACCommand去封装网络请求,直接执行RACCommand就可以触发网络请求
        2.当RACCommand内部请求到数据的时候,需要把请求的数据传递给外界,这个时候就可以通过signalBlock返回的信号进行传递了
 
    四:如何拿到RACCommand中signalBlock返回的信号所发出的数据
        1.RACCommand有个执行信号executionSignals,这个是signalBlock返回信号的信号,信号发出的数据是信号,而不是常见的普通类型
        2.订阅executionSignals就能拿到RACCommand中返回的信号,然后订阅sinnalBlock返回的信号,就能获取到signalBlock返回发出的值
 
    五:监听当前命令是否正在执行,订阅execiting信号即可,信号内容为@1或@0,@0代表信号执行完毕,我们一般对这个信号取bool值,判断信号是否执行完毕
 
    六:使用场景,监听按钮点击,网络请求
 */


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.创建命令
    RACCommand * command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            // 模拟网络请求,延迟3秒再发送信号
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [subscriber sendNext:@"数据"];
                // 数据发送完毕时,必须调用信号发送完毕命令,否则命令将一直处于正在执行状态
                [subscriber sendCompleted];
            });
            
            return nil;
        }];
        // 如果需要返回空信号,需要使用[RACSignal empty]创建空信号,而不是直接返回nil
        //return [RACSignal empty];
    }];
    
    // 2.强引用
    _command = command;
    
    // 3.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id x) {
       
        // 参数x,实际就是创建RACCommand时signalBlock返回的信号,再订阅这个x信号就可以拿到执行数据
        [x subscribeNext:^(id x) {
            NSLog(@"收到信号-信号内容:%@",x);
        }];
    }];
    
    // 4.监听命令是否执行完毕,默认会发送一次信号,所以需要跳过首次的信号,
    [[command.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue]) {
            NSLog(@"信号正在执行");
        } else {
            NSLog(@"信号执行完毕");
        }
        
    }];
    
    // 5.使用RACCommand的executionSignals.switchToLatest 从RACCommand直接获取到创建命令时signalBlock返回的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"使用信号的executionSignals.switchToLatest方法获取到是信号内容:%@",x);
        
    }];
    
    // 6.执行命令
    [command execute:@1];
    
    
    /*  控制台输出
     2017-08-31 19:37:24.847 RAC[9160:257515] 信号正在执行
     2017-08-31 19:37:28.143 RAC[9160:257515] 收到信号-信号内容:数据
     2017-08-31 19:37:28.143 RAC[9160:257515] 使用信号的executionSignals.switchToLatest方法获取到是信号内容:数据
     2017-08-31 19:37:28.144 RAC[9160:257515] 信号执行完毕
     */
    
}


@end
