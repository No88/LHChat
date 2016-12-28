//
//  LHTools.h
//  LHChatUI
//
//  Created by lenhart on 2016/12/23.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LHTools : NSObject


/**
 相册权限

 @return YES or NO
 */
+ (BOOL)cameraLimit;

/**
 相机权限
 
 @return YES or NO
 */
+ (BOOL)photoLimit;


/**
 时间处理

 @param date 时间戳
 @return 处理后的格式 yyyy/MM/dd HH:mm
 */
+ (NSString *)processingTimeWithDate:(NSString *)date;

@end
