//
//  VCRACScheduler.m
//  RAC
//
//  Created by XiZhi on 2017/8/31.
//  Copyright © 2017年 XiaoTao. All rights reserved.
//

#import "VCRACScheduler.h"

@interface VCRACScheduler ()

@end

@implementation VCRACScheduler

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self scheduler];
    
    //[self asycSubscribe];
    
    //[self asycSend];
    
    //[self asycSendAndSycSend];
    
    //[self asycSendAndSycSendWithAsycSubcribe];
    
    //[self deliverOnThread];
    
    [self subscribeOnThread];
}

/*
    RACScheduler在ReactiveCocoa中是用来控制一个任务，何时何地被执行。它主要是用来解决ReactiveCocoa中并发编程的问题的。
    RACScheduler的实质是对GCD的封装，底层使用GCD实现。
 
    虽然RACScheduler可以方便的控制线程转换及线程间通信操作,使用方法也很简单,但要注意信号的发送和订阅所在的线程,根据实际情况使用subscribeOn:和deliverOn:
 
 */

- (void)scheduler {
    
    NSLog(@"%s",__FUNCTION__);
    
    // 1.主线程
    RACScheduler * mainScheduler = [RACScheduler mainThreadScheduler];
    
    // 获取当前线程的scheduler, 子线程使用该方法获取到的为空
    RACScheduler * scheduler = [RACScheduler currentScheduler];
    
    NSLog(@"当前线程中的scheduler:%@ 获取当前线程中的scheduler:%@",mainScheduler,scheduler);
    
    // 2.创建一个子线程的scheduler(不需要使用GCD,RACScheduler内部已经做了处理)
    RACScheduler * scheduler_2_0 = [RACScheduler scheduler];
    RACScheduler * scheduler_2_1 = [RACScheduler scheduler];
    
    NSLog(@"当前线程:%@ scheduler:%@ scheduler2:%@",[NSThread currentThread],scheduler_2_0,scheduler_2_1);
    NSLog(@"当前子线程中的scheduler3:%@",[RACScheduler currentScheduler]);
    
    // 3.scheduler优先级,我们一般不会去设置优先级
    /*
     scheduler优先级枚举值, 实际是对队列优先级的起的别名
     typedef enum : long {
     RACSchedulerPriorityHigh = DISPATCH_QUEUE_PRIORITY_HIGH,
     RACSchedulerPriorityDefault = DISPATCH_QUEUE_PRIORITY_DEFAULT,
     RACSchedulerPriorityLow = DISPATCH_QUEUE_PRIORITY_LOW,
     RACSchedulerPriorityBackground = DISPATCH_QUEUE_PRIORITY_BACKGROUND,
     } RACSchedulerPriority;
     */
    RACScheduler * scheduler_3 = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh name:@"HighPriorityScheduler"];
    NSLog(@"优先级scheduler:%@",scheduler_3);
    
    // 4.创建立刻执行的scheduler,我们一般不会去设置
    RACScheduler * scheduler_4 = [RACScheduler immediateScheduler];
    NSLog(@"立刻执行的scheduler:%@",scheduler_4);
    
    /* 输出 (注意高优先级的scheduler的打印信息)
      当前线程中的scheduler:<RACTargetQueueScheduler: 0x600000230c20> com.ReactiveCocoa.RACScheduler.mainThreadScheduler 获取当前线程中的scheduler:<RACTargetQueueScheduler: 0x600000230c20> com.ReactiveCocoa.RACScheduler.mainThreadScheduler
     
     当前线程:<NSThread: 0x60800007d1c0>{number = 1, name = main} scheduler:<RACTargetQueueScheduler: 0x60000002e520> com.ReactiveCocoa.RACScheduler.backgroundScheduler scheduler2:<RACTargetQueueScheduler: 0x608000030b20> com.ReactiveCocoa.RACScheduler.backgroundScheduler
     
     当前子线程中的scheduler3:<RACTargetQueueScheduler: 0x600000230c20> com.ReactiveCocoa.RACScheduler.mainThreadScheduler
     
     优先级scheduler:<RACTargetQueueScheduler: 0x608000033940> HighPriorityScheduler
     
     立刻执行的scheduler:<RACImmediateScheduler: 0x608000006990> com.ReactiveCocoa.RACScheduler.immediateScheduler
     */
    
}
// 异步订阅
- (void)asycSubscribe {
    
    NSLog(@"%s",__FUNCTION__);
    
    // 主线程中创建的信号
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"000-当前线程:%@",[NSThread currentThread]);
        
        [subscriber sendNext:@"信号内容"];
        
        return nil;
    }];
    
    // 子线程中订阅信号
    [[RACScheduler scheduler] schedule:^{
        
        // 在子线程中执行的任务块
        
        [signal subscribeNext:^(id x) {
            NSLog(@"收到的信号值:%@ 当前线程:%@",x,[NSThread currentThread]);
        }];
        
    }];
    
    /*
     输出:
     
     000-当前线程:<NSThread: 0x60800026f840>{number = 3, name = (null)}
     2017-09-01 11:04:51.956 RAC[1551:45517] 收到的信号值:信号内容 当前线程:<NSThread: 0x60800026f840>{number = 3, name = (null)}
     
     */
    
    /*
     信号被异步订阅处理后,信号里面的代码也是在子线程中执行
     */
}
// 异步发送
- (void)asycSend {
    
    NSLog(@"%s",__FUNCTION__);
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"000-当前线程:%@",[NSThread currentThread]);
        
        RACDisposable * disposable = [[RACScheduler scheduler] schedule:^{
            
            NSLog(@"111-当前线程:%@",[NSThread currentThread]);
            
            [subscriber sendNext:@"1"];
            [subscriber sendCompleted];
        }];
        return disposable;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"信号内容:%@ 当前线程:%@",x,[NSThread currentThread]);
    }];
    
    /*
     000-当前线程:<NSThread: 0x60000007c0c0>{number = 1, name = main}
     111-当前线程:<NSThread: 0x600000273200>{number = 3, name = (null)}
     信号内容:1 当前线程:<NSThread: 0x600000273200>{number = 3, name = (null)}
     */
    
    /*
        异步发送信号时,订阅信号的处理也是在相应子线程中执行
     */
}

// 同步发送 + 异步发送 (同步订阅)
- (void)asycSendAndSycSend {
    
    NSLog(@"%s",__FUNCTION__);
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"1111-当前线程:%@",[NSThread currentThread]);
        [subscriber sendNext:@"1111"];
        
        RACDisposable * disposable = [[RACScheduler scheduler] schedule:^{
            
            NSLog(@"2222-当前线程:%@",[NSThread currentThread]);
            
            [subscriber sendNext:@"2222"];
        }];
        return disposable;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"信号值:%@ 当前线程:%@",x,[NSThread currentThread]);
    }];
    
    /*
     1111-当前线程:<NSThread: 0x60800006ba00>{number = 1, name = main}
     信号值:1111 当前线程:<NSThread: 0x60800006ba00>{number = 1, name = main}
     2222-当前线程:<NSThread: 0x600000260800>{number = 3, name = (null)}
     信号值:2222 当前线程:<NSThread: 0x600000260800>{number = 3, name = (null)}

     */
    
    /*
        如果订阅信号操作里没有额外添加线程操作,发出信号时所在的线程,就可以决定订阅信号时,订阅操作处理执行所在线程
     */
}
// 同步发送 + 异步发送 (异步订阅)
- (void)asycSendAndSycSendWithAsycSubcribe {
    
    NSLog(@"%s",__FUNCTION__);
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"1111-当前线程:%@",[NSThread currentThread]);
        [subscriber sendNext:@"1111"];
        
        RACDisposable * disposable = [[RACScheduler scheduler] schedule:^{
            
            NSLog(@"2222-当前线程:%@",[NSThread currentThread]);
            
            [subscriber sendNext:@"2222"];
        }];
        return disposable;
    }];
    
    [[RACScheduler scheduler] schedule:^{
        
        NSLog(@"3333-当前线程:%@",[NSThread currentThread]);
        
        [signal subscribeNext:^(id x) {
            NSLog(@"信号值:%@ 当前线程:%@",x,[NSThread currentThread]);
        }];
    }];
    
    /*
     3333-当前线程:<NSThread: 0x60000026fac0>{number = 3, name = (null)}
     1111-当前线程:<NSThread: 0x60000026fac0>{number = 3, name = (null)}
     信号值:1111 当前线程:<NSThread: 0x60000026fac0>{number = 3, name = (null)}
     2222-当前线程:<NSThread: 0x60000026fac0>{number = 3, name = (null)}
     信号值:2222 当前线程:<NSThread: 0x60000026fac0>{number = 3, name = (null)}
     */
    
    /*
     
     1.异步订阅的信号,发送信号的操作都会在异步线程
     2.异步发送的信号,异步订阅的操作可能不在一个子线程
     
     */
}
// 由于发送信号操作所在线程会影响订阅信号操作执行行为所在线程,所以就有了在订阅信号或发送信号时,可以指定线程的需求,deliverOn和subscribeOn由此而来
// 发送时机不确定时 —> deliverOn:
- (void)deliverOnThread {
 
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        NSLog(@"1111-当前线程:%@",[NSThread currentThread]);
        [subscriber sendNext:@"1111"];
        
        RACDisposable * disposable = [[RACScheduler scheduler] schedule:^{
            
            NSLog(@"2222-当前线程:%@",[NSThread currentThread]);
            
            [subscriber sendNext:@"2222"];
        }];
        return disposable;
    }];
    
    // 模拟在子线程中指定回到主线程执行操作
    [[RACScheduler scheduler] schedule:^{
        NSLog(@"3333-当前线程:%@",[NSThread currentThread]);
        [[signal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
           
            // 指定在主线程中执行订阅信号后的操作
            NSLog(@"4444-当前线程:%@ 信号值:%@",[NSThread currentThread],x);
        }];
    }];
    
    /*
     3333-当前线程:<NSThread: 0x608000264680>{number = 3, name = (null)}
     1111-当前线程:<NSThread: 0x608000264680>{number = 3, name = (null)}
     2222-当前线程:<NSThread: 0x608000264680>{number = 3, name = (null)}
     4444-当前线程:<NSThread: 0x608000072f80>{number = 1, name = main} 信号值:1111
     4444-当前线程:<NSThread: 0x608000072f80>{number = 1, name = main} 信号值:2222
     */
    
    /*
      deliverOn可以指定订阅信号的block处理操作在指定线程中执行 当然,如果block内部再做的异步处理,那肯定就有异步子线程处理了
     */
}
// subscribeOn 订阅时机不确定时 —> subscribeOn:
- (void)subscribeOnThread {
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"1111-当前线程:%@",[NSThread currentThread]);
        [subscriber sendNext:@"1111"];
        
        RACDisposable * disposable = [[RACScheduler scheduler] schedule:^{
            
            NSLog(@"2222-当前线程:%@",[NSThread currentThread]);
            
            [subscriber sendNext:@"2222"];
        }];
        return disposable;
    }];
    
    [[RACScheduler scheduler] schedule:^{
        NSLog(@"3333-当前线程:%@",[NSThread currentThread]);
        [[signal subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            
            NSLog(@"4444-当前线程:%@ 信号值:%@",[NSThread currentThread],x);
        
        }];
    }];

    /*
     3333-当前线程:<NSThread: 0x6000002778c0>{number = 3, name = (null)}
     1111-当前线程:<NSThread: 0x6000002614c0>{number = 1, name = main}
     4444-当前线程:<NSThread: 0x6000002614c0>{number = 1, name = main} 信号值:1111
     2222-当前线程:<NSThread: 0x600000278180>{number = 4, name = (null)}
     4444-当前线程:<NSThread: 0x600000278180>{number = 4, name = (null)} 信号值:2222
     */
    
    /*
     使用subscribeOn可以让信号signal内的代码在指定线程中执行
     */
}

@end
