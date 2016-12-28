//
//  NSDate+Judge.m
//  XSTeachEDU
//
//  Created by liuhao on 2016/10/17.
//  Copyright © 2016年 xsteach.com. All rights reserved.
//

#import "NSDate+Judge.h"
#import "NSCalendar+Establish.h"

@implementation NSDate (Judge)

/** 是否是今天 */
- (BOOL)lh_isInToDay
{
    NSCalendar *calendar = [NSCalendar lh_calendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *selfDate = [calendar components:unit fromDate:self];
    NSDateComponents *newDate = [calendar components:unit fromDate:[NSDate date]];
    
    return [selfDate isEqual:newDate];
}

/** 是否是明天 */
- (BOOL)lh_isIntTomorrow
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    
    NSString *selfString = [formatter stringFromDate:self];
    NSString *newString = [formatter stringFromDate:[NSDate date]];
    
    NSDate *selfDate = [formatter dateFromString:selfString];
    NSDate *newDate = [formatter dateFromString:newString];
    
    NSCalendar *calendar = [NSCalendar lh_calendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unit fromDate:selfDate toDate:newDate options:0];
    
    return components.year == 0
    && components.month == 0
    && components.day == -1;
}

/** 是否是昨天 */
- (BOOL)lh_isInYesterday
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    
    NSString *selfString = [formatter stringFromDate:self];
    NSString *newString = [formatter stringFromDate:[NSDate date]];
    
    NSDate *selfDate = [formatter dateFromString:selfString];
    NSDate *newDate = [formatter dateFromString:newString];
    
    NSCalendar *calendar = [NSCalendar lh_calendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unit fromDate:selfDate toDate:newDate options:0];
    
    return components.year == 0
    && components.month == 0
    && components.day == 1;
}

/** 是否是今年 */
- (BOOL)lh_isInThisYear
{
    NSCalendar *calendar = [NSCalendar lh_calendar];
    
    NSDateComponents *selfDate = [calendar components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *newDate = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return [selfDate isEqual:newDate];
}

@end
