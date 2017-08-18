//
//  VCSubject.m
//  RAC
//
//  Created by XiZhi on 2017/8/18.
//  Copyright © 2017年 XiaoTao. All rights reserved.
//

#import "VCSubject.h"
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

@interface VCSubject ()

@end

@implementation VCSubject

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSubject];

    [self replaySubject];
    
    [self useRACSubjectReplaceDelegation];
}

/*
   RACSubject : RACSignal的子类,所以可以提供信号  但RACSubject本身还可以充当信号 实际开发中,可以代替代理,省去定义代理的步骤,实际使用时方法与block传
                可以先订阅RACSubject的信号,再发送信号
 
   RACSubject的使用
    1.创建    [RACSubject subject],这一点与RACSignal不同,没有创建时的block
    2.订阅信号 -(RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    3.发送信号 sendNext:(id)value
 
    RACSubject和RACSignal在底层实现上就不一样
    1.调用subscribeNext订阅信号,只是把订阅者保存起来,并且订阅者的nextBlock已经赋值了
    2.调用sendNext发送信号时,遍历刚刚保存的所有订阅者,一个一个的去调用订阅者的nextBlock
 
    RACSubject实例进行map操作之后,一定要调用-sendCompleted, 否则会出现内存泄露
    RACSignal实例则不管是否进行map操作,不管是否调用-sendCompleted,都不会出现内存泄露
    原因:RACSubject是热信号,为了保证未来发出信号是,订阅者可以收到信号,所以需要持有订阅者. 在调用-sendCompleted后,会不再持有订阅者
 
 */

/*
    RACReplaySubject: RACSubject的子类
    如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类
    可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值
      RACReplaySubject的使用
    1.创建    [RACReplaySubject subject]
    2.订阅信号 -(RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    3.发送信号 sendNext:(id)value
      工作流程
    1.订阅信号时,RACReplaySubject内部保存了订阅者和订阅者的nextBlock
    2.发送信号时,遍历订阅者,调用订阅者的nextBlock
    3.发送的信号会保存起来,当有订阅者订阅信号时,会将之前保存的信号,逐一传递给订阅者,执行nextBlock
      也正是因为可以保存信号值,所以RACSubject必须要先订阅信号之后才能发送信号，而RACReplaySubject可以先发送信号后订阅.
 */


- (void)createSubject {
    
    NSLog(@"%s",__FUNCTION__);
    
    RACSubject * subject = [RACSubject subject];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"收到信号1 信号值:%@",x);
    }];
    
    [subject sendNext:@"这是第一个信号值"];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"收到信号2 信号值:%@",x);
    }];
    
    [subject sendNext:@"这是第二个信号值"];

    /*
     收到信号1 信号值:这是第一个信号值
     收到信号1 信号值:这是第二个信号值
     收到信号2 信号值:这是第二个信号值
     */
    // RACSubject 发送过sendNext之后, 再去订阅这个信号是没有效果的
}

- (void)replaySubject {
    
    NSLog(@"%s",__FUNCTION__);
    
    RACReplaySubject * replaySubject = [RACReplaySubject subject];
    
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"RACReplaySubject 收到信号1 信号值:%@",x);
    }];
    
    [replaySubject sendNext:@"这是第一个信号值"];
    
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"RACReplaySubject 收到信号2 信号值:%@",x);
    }];
    
    [replaySubject sendNext:@"RACReplaySubject 这是第二个信号值"];
    
    /*
     RACReplaySubject 收到信号1 信号值:这是第一个信号值
     RACReplaySubject 收到信号2 信号值:这是第一个信号值
     RACReplaySubject 收到信号1 信号值:RACReplaySubject 这是第二个信号值
     RACReplaySubject 收到信号2 信号值:RACReplaySubject 这是第二个信号值
     */
    
}

- (void)useRACSubjectReplaceDelegation {
    
    NSLog(@"%s",__FUNCTION__);
    
    // 在当前页面改变上一页面
    //    步骤一：在第二个控制器.h，添加一个RACSubject代替代理。
    //    @interface TwoViewController : UIViewController
    //
    //    @property (nonatomic, strong) RACSubject *delegateSignal;
    //
    //    @end
    //
    //    步骤二：监听第二个控制器按钮点击
    //    @implementation TwoViewController
    //    - (IBAction)notice:(id)sender {
    //        // 通知第一个控制器，告诉它，按钮被点了
    //
    //        // 通知代理
    //        // 判断代理信号是否有值
    //        if (self.delegateSignal) {
    //            // 有值，才需要通知
    //            [self.delegateSignal sendNext:nil];
    //        }
    //    }
    //    @end
    //
    //    步骤三：在第一个控制器中，给第二个控制器的代理信号赋值，订阅该信号.
    //    @implementation OneViewController
    //    - (IBAction)btnClick:(id)sender {
    //
    //        // 创建第二个控制器
    //        TwoViewController *twoVc = [[TwoViewController alloc] init];
    //
    //        // 设置代理信号
    //        twoVc.delegateSignal = [RACSubject subject];
    //
    //        // 订阅代理信号
    //        [twoVc.delegateSignal subscribeNext:^(id x) {
    //
    //            NSLog(@"点击了通知按钮");
    //        }];
    //        
    //        // 跳转到第二个控制器
    //        [self presentViewController:twoVc animated:YES completion:nil];
    //        
    //    }
    //    @end
    
}






@end
