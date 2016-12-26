//
//  UIResponder+Router.m
//  LHChatUI
//
//  Created by liuhao on 2016/12/26.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "UIResponder+Router.h"

@implementation UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
}

@end
