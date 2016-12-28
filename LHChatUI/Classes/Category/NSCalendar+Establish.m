//
//  NSCalendar+Establish.m
//  XSTeachEDU
//
//  Created by liuhao on 2016/10/17.
//  Copyright © 2016年 xsteach.com. All rights reserved.
//

#import "NSCalendar+Establish.h"

@implementation NSCalendar (Establish)

+ (instancetype)lh_calendar
{
    if ([NSCalendar respondsToSelector:@selector(calendarWithIdentifier:)]) {
        return [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    } else {
        return [NSCalendar currentCalendar];
    }
}


@end
