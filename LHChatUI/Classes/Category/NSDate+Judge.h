//
//  NSDate+Judge.h
//  XSTeachEDU
//
//  Created by liuhao on 2016/10/17.
//  Copyright © 2016年 xsteach.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Judge)
/** 是否是今天 */
- (BOOL)lh_isInToDay;

/** 是否是明天 */
- (BOOL)lh_isIntTomorrow;

/** 是否是昨天 */
- (BOOL)lh_isInYesterday;

/** 是否是今年 */
- (BOOL)lh_isInThisYear;
@end
