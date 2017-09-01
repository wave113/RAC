//
//  VCHotAndColdSignal.m
//  RAC
//
//  Created by XiZhi on 2017/9/1.
//  Copyright © 2017年 XiaoTao. All rights reserved.
//

#import "VCHotAndColdSignal.h"

@interface VCHotAndColdSignal ()

@end

@implementation VCHotAndColdSignal

/*
    热信号: 1.不管有没有订阅者, 都会发送信号 (订阅信号在发送信号之后,收不到之前发出的信号)
           2.
    冷信号: 1.只有被订阅后,才会发出信号
           2.只要有订阅者,它就会重头执行一遍信号的发送
           3.RACSignal是冷信号
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self coldSignal];
    
    //[self hotSignal];
    
    //[self subject];
    
    [self changeColdSignalToHotSignal];
}

// 冷信号不关心订阅者 只要有订阅者,他就会重头发送全部信号值
- (void)coldSignal {
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@111];
        [subscriber sendNext:@222];
        [subscriber sendNext:@333];
        [subscriber sendCompleted];
    
        return nil;
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"1-收到信号:%@",x);
        }];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:1.0 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"2-收到信号:%@",x);
        }];
    }];
    
    /*
     1-收到信号:111
     1-收到信号:222
     1-收到信号:333
     2-收到信号:111
     2-收到信号:222
     2-收到信号:333
     */
    
}
// 热信号关心订阅者, 信号会主动发送,订阅者如果错过了信号就接受不到了  publish可以把冷信号转成热信号
- (void)hotSignal {
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
            [subscriber sendNext:@111];
        }];
        
        [[RACScheduler mainThreadScheduler] afterDelay:1.0 schedule:^{
            [subscriber sendNext:@222];
        }];
        
        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{
            [subscriber sendNext:@333];
        }];
        
        [[RACScheduler mainThreadScheduler] afterDelay:2.0 schedule:^{
            [subscriber sendNext:@444];
        }];
        
        return nil;
    }];
    
    RACMulticastConnection * connect = [signal publish];
    
    [connect connect];
    
    RACSignal * singal2 = connect.signal;
    
    // 分别在1.1秒时和1.2秒时订阅获得的信号
    [[RACScheduler mainThreadScheduler] afterDelay:1.1 schedule:^{
        [singal2 subscribeNext:^(id x) {
            NSLog(@"1.1-收到信号:%@",x);
        }];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:1.2 schedule:^{
        [singal2 subscribeNext:^(id x) {
            NSLog(@"1.2-收到信号:%@",x);
        }];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:1.7 schedule:^{
        [singal2 subscribeNext:^(id x) {
            NSLog(@"1.7-收到信号:%@",x);
        }];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:4.0 schedule:^{
        [singal2 subscribeNext:^(id x) {
            NSLog(@"4.0-收到信号:%@",x);
        }];
    }];
    
    /*
     1.1-收到信号:333
     1.2-收到信号:333
     1.1-收到信号:444
     1.2-收到信号:444
     1.7-收到信号:444
     */
    
}
/*
 RACSubject 是一个热信号
 RACReplaySubject 具备为未来订阅者缓冲时间的能力
 */
- (void)subject {
    
    RACSubject * subject = [RACSubject subject];
    RACSubject * replaySubject = [RACReplaySubject subject];
    
    [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
        
        [subject subscribeNext:^(id x) {
            NSLog(@"111-subject-收到信号值:%@",x);
        }];
        
        [replaySubject subscribeNext:^(id x) {
            NSLog(@"111-replaySubject-收到信号值:%@",x);
        }];
        
        [subject subscribeNext:^(id x) {
            NSLog(@"222-subject-收到信号值:%@",x);
        }];
        
        [replaySubject subscribeNext:^(id x) {
            NSLog(@"222-replaySubject-收到信号值:%@",x);
        }];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:1.0 schedule:^{
        
        [subject sendNext:@"subject"];
        [replaySubject sendNext:@"replaySubject"];
        
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{
        
        [subject subscribeNext:^(id x) {
            NSLog(@"333-subject-收到信号值:%@",x);
        }];
        
        [replaySubject subscribeNext:^(id x) {
            NSLog(@"333-replaySubject-收到信号值:%@",x);
        }];
    }];
    
    /*
     111-subject-收到信号值:subject
     222-subject-收到信号值:subject
     111-replaySubject-收到信号值:replaySubject
     222-replaySubject-收到信号值:replaySubject
     333-replaySubject-收到信号值:replaySubject
     */
    
    /*
     RACSubject 发送过sendNext之后, 再去订阅这个信号是没有效果的
     RACSubject 必须要先订阅信号之后才能发送信号，而RACReplaySubject可以先发送信号后订阅.
     */
}
// 冷信号转为热信号 订阅冷信号,订阅到的每一个时间通过RACSubjuct发送出去,其他订阅者只订阅这个RACSubject
- (void)changeColdSignalToHotSignal {
    
    RACSignal * coldSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
            [subscriber sendNext:@"111"];
        }];
        
        [[RACScheduler mainThreadScheduler] afterDelay:1.0 schedule:^{
            [subscriber sendNext:@"222"];
        }];
        
        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{
            [subscriber sendNext:@"333"];
        }];
        
        return nil;
    }];
    
    RACSubject * subject = [RACSubject subject];
    
    [[RACScheduler mainThreadScheduler] afterDelay:0.8 schedule:^{
        [coldSignal subscribe:subject];
    }];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"111-收到信号:%@",x);
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:1.2 schedule:^{
       [subject subscribeNext:^(id x) {
           NSLog(@"222-收到信号:%@",x);
       }];
    }];
    
    /*
     111-收到信号:111
     222-收到信号:111
     111-收到信号:222
     222-收到信号:222
     111-收到信号:333
     222-收到信号:333
     */
    
}

@end
