//
//  UIView+Addtions.m
//
//
//  Created by apple on 14-4-16.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "UIView+Addtions.h"

@implementation UIView (Addtions)

- (UIViewController *)viewController {
    //下一个响应者
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next);
    return nil;
}

@end
