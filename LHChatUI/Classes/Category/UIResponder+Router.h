//
//  UIResponder+Router.h
//  LHChatUI
//
//  Created by liuhao on 2016/12/26.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Router)


/**
 发送一个路由器消息, 对eventName感兴趣的UIResponsder 可以对消息进行处理

 @param eventName 发生的时间名称
 @param userInfo 传递消息时, 携带的数据, 数据传递过程中, 会有新的数据添加
 */
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end
