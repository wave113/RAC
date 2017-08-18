//
//  VCSignal.m
//  RAC
//
//  Created by XiZhi on 2017/8/17.
//  Copyright © 2017年 XiaoTao. All rights reserved.
//

#import "VCSignal.h"
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

//信号类(RACSiganl)，只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者去发出。
//默认一个信号都是冷信号，也就是值改变了，也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发。
//如何订阅信号：调用信号RACSignal的subscribeNext就能订阅

//@weakify(Obj)和@strongify(Obj)

@implementation VCSignal

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSignal];
    
    [self operateSingnal];
    
    [self timeSignal];
    
    [self otherSignal];
    
    [self mergeSignal];
    
    [self groupSignal];
    
    [self zipSignal];
}

- (void)dealloc {
    NSLog(@"VCSignal 销毁");
}

- (void)createSignal {
    
    NSLog(@"%s",__FUNCTION__);
    
    // 完整的信号包括三部分: 信号内容(可多个), 信号错误(可有可无), 信号发送完成(可有可无)
    // RACSubsscriber:订阅者 是一个协议 用于发送信号,错误信号,完成信号 通过createSignal创建的信号,都有一个订阅者,用于发送信号

    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"信号内容"];
        
        // 如果执行了sendError:操作,则不会再去执行sendCompleted操作
        //[subscriber sendError:[NSError errorWithDomain:@"ErrorDomain" code:500 userInfo:nil]];
        
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"清理资源");
            // RACDispoable : 可用于取消订阅或清理资源, 当一个信号订阅者在接收到全部信号后,就会自动触发这里的block, 多个订阅者时则会多次调用
            //                当不想监听某个信号时, 可以通过它主动取消订阅信号
        }];
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"收到信号1 %@",x);
    } error:^(NSError *error) {
        NSLog(@"收到信号1 %@",error);
    } completed:^{
        NSLog(@"信号完成1");
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"收到信号2 %@",x);
    }];
    /*
     收到信号1 信号内容
     信号完成1
     清理资源
     收到信号2 信号内容
     清理资源
     */
}

- (void)operateSingnal {
    
    NSLog(@"%s",__FUNCTION__);
    
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"4"];
        [subscriber sendNext:@"5"];
        [subscriber sendNext:@"6"];
        
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"清理资源");
        }];
    }];
    
    // 1.filter过滤
    // 信号内容的类型在从id改为其他类型时,要确保信号的实际类型一致
    RACSignal * filterSingal = [signal filter:^BOOL(NSString * value) {
        if ([value integerValue] > 3) {
            return NO;
        }
        return YES;
    }];
    
    [filterSingal subscribeNext:^(id x) {
        NSLog(@"过滤后的信号值: %@",x);
    }];
    
    /*
     过滤后的信号值: 1
     过滤后的信号值: 2
     过滤后的信号值: 3
     清理资源
     */
    
    
    // 2.map操作: 改变信号内容
    RACSignal * mapSignal = [signal map:^id(id value) {
        return [NSString stringWithFormat:@"使用map改变了信号 %@",value];
    }];
    
    [mapSignal subscribeNext:^(id x) {
        NSLog(@"map处理后的信号值: %@",x);
    }];
    
    /*
     map处理后的信号值: 使用map改变了信号 1
     map处理后的信号值: 使用map改变了信号 2
     map处理后的信号值: 使用map改变了信号 3
     map处理后的信号值: 使用map改变了信号 4
     map处理后的信号值: 使用map改变了信号 5
     map处理后的信号值: 使用map改变了信号 6
     清理资源
     */
    
    // 3.flattenMap 可改变信号值,并返回一个新信号
    // RACStream :RACSignal等的父类 可以看下RAC中的流概念
    RACSignal * flattenMapSignal = [signal flattenMap:^RACStream *(id value) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [subscriber sendNext:[NSString stringWithFormat:@"使用flattenMap改变信号值: %@",value]];
            
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"清理flattenMapSignal信号资源");
            }];
        }];
    }];
    
    [flattenMapSignal subscribeNext:^(id x) {
        NSLog(@"flattenMap处理后的信号值: %@",x);
    }];
    
    /*
     flattenMap处理后的信号值: 使用flattenMap改变信号值: 1
     清理flattenMapSignal信号资源
     flattenMap处理后的信号值: 使用flattenMap改变信号值: 2
     清理flattenMapSignal信号资源
     flattenMap处理后的信号值: 使用flattenMap改变信号值: 3
     清理flattenMapSignal信号资源
     flattenMap处理后的信号值: 使用flattenMap改变信号值: 4
     清理flattenMapSignal信号资源
     flattenMap处理后的信号值: 使用flattenMap改变信号值: 5
     清理flattenMapSignal信号资源
     flattenMap处理后的信号值: 使用flattenMap改变信号值: 6
     清理flattenMapSignal信号资源
     清理资源
     */
    
    // 4.ignore 忽略单个信号值
    [[signal ignore:@"1"] subscribeNext:^(id x) {
        NSLog(@"忽略后的结果: %@",x);
    }];
    
    /*
     忽略后的结果: 2
     忽略后的结果: 3
     忽略后的结果: 4
     忽略后的结果: 5
     忽略后的结果: 6
     清理资源
     */
    
    // 5.ignoreValues忽略所有信号值 只使错误信号Error和完成信号Comletion有效
    [[signal ignoreValues] subscribeNext:^(id x) {
        NSLog(@"ignoreValues 忽略所有信号值");
    } error:^(NSError *error) {
        NSLog(@"ignoreValues忽略所有信号值 错误信号");
    } completed:^{
        NSLog(@"ignoreValues忽略所有信号值 完成信号");
    }];
    
    /*
     ignoreValues忽略所有信号值 完成信号
     清理资源
     */
    
    // 6.take : 从开始一共取次信号
    [[signal take:2] subscribeNext:^(id x) {
        NSLog(@"take : %@",x);
    }];
    
    /*
     take : 1
     take : 2
     清理资源
     */
    
    // 7.takeUntilBlock: 取信号直到block内返回YES
    [[signal takeUntilBlock:^BOOL(id x) {
        if ([x isEqualToString:@"4"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"takeUntilBlock获取的值:%@",x);
    }];

    /*
     takeUntilBlock获取的值:1
     takeUntilBlock获取的值:2
     takeUntilBlock获取的值:3
     清理资源
     */
    
    // 8.takeLast取最后几个信号的值
    [[signal takeLast:2] subscribeNext:^(id x) {
        NSLog(@"takeLast 取最后几个信号的值 : %@",x);
    }];
    
    /*
     takeLast 取最后几个信号的值 : 5
     takeLast 取最后几个信号的值 : 6
     清理资源
     */
    
    // 9.skip跳过几个信号
    [[signal skip:3] subscribeNext:^(id x) {
        NSLog(@"skip 跳过信号后获取到的值 %@",x);
    }];
    
    /*
     skip 跳过信号后获取到的值 4
     skip 跳过信号后获取到的值 5
     skip 跳过信号后获取到的值 6
     清理资源
     */
    
    // 10.skipUntilBlock 跳过信号,直到block内返回YES
    [[signal skipUntilBlock:^BOOL(id x) {
        if ([x isEqualToString:@"4"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"skipUntilBlock 跳过信号收到的值 %@",x);
    }];
    
    /*
     skipUntilBlock 跳过信号收到的值 4
     skipUntilBlock 跳过信号收到的值 5
     skipUntilBlock 跳过信号收到的值 6
     清理资源
     */
    
    
    // 11.skipWhileBlock 跳过信号,直到block内返回NO
    [[signal skipWhileBlock:^BOOL(id x) {
        if ([x isEqualToString:@"4"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"skipWhileBlock 跳过信号收到的值 %@",x);
    }];
    
    // 第一个信号值为@"1" -> 开始不跳过信号,所以全部信号都有效
    /*
     skipWhileBlock 跳过信号收到的值 1
     skipWhileBlock 跳过信号收到的值 2
     skipWhileBlock 跳过信号收到的值 3
     skipWhileBlock 跳过信号收到的值 4
     skipWhileBlock 跳过信号收到的值 5
     skipWhileBlock 跳过信号收到的值 6
     清理资源
     */
    
    // 12.not : 信号值取反
    // [RACSignal return:id] 使用值直接创建信号
    [[[RACSignal return:@(0)] not] subscribeNext:^(id x) {
        NSLog(@"not信号值取反的结果 : %@",x);
    }];
    
    /*
     not信号值取反的结果 : 1
     */
    
    // 13.startWith : 在信号值前面添加额外信号值,即在发送信号前,预先发送一个信号
    [[[RACSignal return:@"原始信号值"] startWith:@"额外值"] subscribeNext:^(id x) {
        NSLog(@"startWith在信号值前面添加信号值值 %@",x);
    }];
    
    /*
     startWith在信号值前面添加值 额外值
     startWith在信号值前面添加值 原始信号值
     */
    
    // 14.reduceEach 用于信号内发出的内容是RAC定义的RACTuplePack元组(类比数组去理解),把元组内的值处理成一个值
    RACSignal * tupleSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:RACTuplePack(@1,@2)];
        [subscriber sendNext:RACTuplePack(@11,@22)];
        [subscriber sendNext:RACTuplePack(@111,@222)];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"清理资源");
        }];
    }];
    
    [[tupleSignal reduceEach:^id(NSNumber *first,NSNumber *secnod){
        return [first integerValue] > [secnod integerValue] ? first : secnod;
    }] subscribeNext:^(id x) {
        NSLog(@"reduceEach处理后的信号值%@",x);
    }];
    
    /*
     reduceEach处理后的信号值2
     reduceEach处理后的信号值22
     reduceEach处理后的信号值222
     清理资源
     */
    
}

- (void)timeSignal {
    
    NSLog(@"%s",__FUNCTION__);
    
    // 1.定时器
    RACSignal * timeSignal = [RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]];
    
    NSLog(@"%@",[NSDate date]);
    
    // 只取前5个定时器信号
    [[timeSignal take:5] subscribeNext:^(id x) {
        NSLog(@"时间到 %@",[NSDate date]);
    }];
    
    /*
     2017-08-18 05:56:45 +0000
     时间到 2017-08-18 05:56:46 +0000
     时间到 2017-08-18 05:56:47 +0000
     时间到 2017-08-18 05:56:48 +0000
     时间到 2017-08-18 05:56:49 +0000
     时间到 2017-08-18 05:56:50 +0000
     */
    
    // 2.超时发送错误操作和延迟操作
    // 时间到超时时间后,会发送错误信号
    RACSignal * timeoutSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"11"];
        [subscriber sendError:[NSError errorWithDomain:@"超时错误" code:500 userInfo:nil]];
        return nil;
    }] timeout:1 onScheduler:[RACScheduler mainThreadScheduler]];
    
    [timeoutSignal subscribeNext:^(id x) {
        NSLog(@"收到带超时时间的信号");
    } error:^(NSError *error) {
        NSLog(@"收到带超时信号的错误信号");
    }];
    
    [[timeoutSignal delay:2] subscribeNext:^(id x) {
        NSLog(@"收到延迟2秒发送带超时的信号");
    } error:^(NSError *error) {
        NSLog(@"收到延迟2秒发送带超时的信号的错误信号");
    }];

    /*
     收到带超时时间的信号
     收到带超时信号的错误信号
     收到延迟2秒发送带超时的信号的错误信号
     */
}

- (void)otherSignal {
    
    NSLog(@"%s",__FUNCTION__);
    
    // 1.retry 若发送了错误信号,这订阅者不会去执行错误信号操作,而是再去执行创建信号时的block,直到发出正确信号
    __block int i = 0;
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        if (i > 5) {
            [subscriber sendNext:@(i)];
        } else {
            i ++;
            [subscriber sendError:nil];
        }
        return nil;
    }];
    
    [[signal retry] subscribeNext:^(id x) {
        NSLog(@"收到信号%@",x);
    } error:^(NSError *error) {
        NSLog(@"收到错误信号");   // 使用retry修饰的信号不会再执行error:
    }];
    
    /*
     收到信号6
     */
    
    // 2.takeUntil 停止发送信号直到takeUntil:中的信号也发出信号
    RACSignal * aSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        RACSignal * timeSignal = [RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]];
        [timeSignal subscribeNext:^(id x) {
            [subscriber sendNext:[NSString stringWithFormat:@"现在时间 %@",[NSDate date]]];
        }];
        
        return nil;
    }];
    
    RACSignal * stopSignal = [aSignal takeUntil:[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSLog(@"别再说了,我记着了记着了,我现在就出门");
            
            [subscriber sendNext:nil];
        });
        return nil;
    }]];
    
    [stopSignal subscribeNext:^(id x) {
        NSLog(@" : %@",x);
    }];
    
    /*
     : 现在时间 2017-08-18 07:05:52 +0000
     : 现在时间 2017-08-18 07:05:53 +0000
     : 现在时间 2017-08-18 07:05:54 +0000
     别再说了,我记着了记着了,我现在就出门
     */
    
    
    // 3.doNext doComplate 在订阅者执行subscribeNext:和completed:操作前,执行其他操作
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"信号内容"];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        NSLog(@"执行doNext:");
    }] doCompleted:^{
        NSLog(@"执行doCompleted:");
    }] subscribeNext:^(id x) {
        NSLog(@"收到信号内容 : %@",x);
    } completed:^{
        NSLog(@"收到信号完成发送信号");
    }];
    
    /*
     执行doNext:
     收到信号内容 : 信号内容
     执行doCompleted:
     收到信号完成发送信号
     */
    
    // 4.throttle节流 用于当信号发送比较频繁时, 限制发送频率,在某一段时间内不发送信号内容时,取出最新的信号值在发出
    //           用处举例:对于实时搜索功能,当用户输入的文字在一定时间没不改变时,再去请求服务器
    RACSignal * throttleSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"3"];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"4"];
        });
        
        return nil;
    }] throttle:1];
    
    [throttleSignal subscribeNext:^(id x) {
        NSLog(@"throttleSignal %@",x);
    }];
    
    /*
     throttleSignal 2
     throttleSignal 4
     */
}

- (void)mergeSignal {
    
    NSLog(@"%s",__FUNCTION__);
    
    RACSignal *aSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"aSignal清理了");
        }];
    }];
    
    RACSignal *bSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"4"];
        
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"bSignal清理了");
        }];
    }];
    
    // 1.combineLatest用法 将多个信号合并起来，并且拿到各个信号的最新的值,把各信号值放到元组中,但每个合并的signal必须至少都有过一次sendNext，才会触发合并的信号
    RACSignal *combineSignal = [aSignal combineLatestWith:bSignal];
    
    [combineSignal subscribeNext:^(id x) {
        // x类型为RACTuple, 可通过[x first]和[x second]方法,拿到元组中各个信号的信号值
        NSLog(@"combineSignal为:%@",x);
    }];
    
    /*
     aSignal清理了
     combineSignal为:<RACTuple: 0x60000001a580> (2,3)
     combineSignal为:<RACTuple: 0x60000001a590> (2,4)
     bSignal清理了
     */
    
    // 2.combineLatest + reduce将合并信号值处理成一个信号值
    RACSignal * combineReduceSignal = [RACSignal combineLatest:@[aSignal,bSignal] reduce:^id(NSString *aItem,NSString *bItem){
        return [NSString stringWithFormat:@"%@-%@",aItem,bItem];
    }];
    
    [combineReduceSignal subscribeNext:^(id x) {
        NSLog(@"合并后combineSignal的值：%@",x);
    }];
    
    /*
     合并后combineSignal的值：2-3
     合并后combineSignal的值：2-4
     */
    
    // 3.then用于连接信号,当一个信号完成时,采取连接then返回的信号,对比同步去理解
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"第一步");
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"第二步");
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"第三步");
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeCompleted:^{
        NSLog(@"完成");
    }];
    
    /*
     第一步
     第二步
     第三步
     完成
     */
    
    // 4.collect 将一个信号的各个信号内容,合并成元组
    
    [[aSignal collect] subscribeNext:^(id x) {
       NSLog(@"collect 单个信号各信号值合并后的值%@",x);
    }];
    
    /*
     collect 单个信号各信号值合并后的值(1,2)
     */
}

- (void)groupSignal {
    
    NSLog(@"%s",__FUNCTION__);
    
    // 信号队列,将几个信号放进一个组里面,按顺序连接每个,每个信号必须执行sendCompleted方法后才能执行下一个信号
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"喜欢一个人"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"直接去表白"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"成功在一起"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal * groupSignal = [[signalA concat:signalB] concat:signalC];
    [groupSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    /*
     喜欢一个人
     直接去表白
     成功在一起
     */
}

- (void)zipSignal {
    
    NSLog(@"%s",__FUNCTION__);
    
    // 压缩信号成元组
    // 压缩具有一一对应关系,以2个信号中 消息发送数量少的为主对应
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"A"];
        [subscriber sendNext:@"B"];
        [subscriber sendNext:@"C"];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"Double A"];
        [subscriber sendNext:@"Double B"];
        return nil;
    }];
    
    [[signalA zipWith:signalB] subscribeNext:^(RACTuple * x) {
        RACTupleUnpack(NSString * stringA, NSString * stringB) = x;
        NSLog(@"%@ -- %@",stringA,stringB);
    }];
    
    /*
     A -- Double A
     B -- Double B
     */
    
}

@end
