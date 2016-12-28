//
//  LHTools.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/23.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHTools.h"
#import <AVFoundation/AVFoundation.h>
#import "NSDate+Judge.h"

@implementation LHTools

+ (BOOL)photoLimit {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return YES;
    } else {
        return NO;
    }
}


+ (BOOL)cameraLimit {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusRestricted ||
        authStatus == AVAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        
        return NO;
        
    } else {
        return YES;
    }
}

+ (NSString *)processingTimeWithDate:(NSString *)date {
    NSTimeInterval time = [[date substringToIndex:10] doubleValue];//因为时差问题要加8小时
    NSDate *sinceDate = [NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *createdAtString  = [formatter stringFromDate:sinceDate];
    
    if (sinceDate.lh_isInThisYear) { // 是今年
        formatter.dateFormat = @"HH:mm";
        createdAtString = [formatter stringFromDate:sinceDate];
        if (sinceDate.lh_isInYesterday) { // 是昨天
            createdAtString = [NSString stringWithFormat:@"昨天 %@", [formatter stringFromDate:sinceDate]];
        }
        else if (!sinceDate.lh_isInToDay) {
            [formatter setDateFormat:@"MM.dd HH:mm"];
            createdAtString = [formatter stringFromDate:sinceDate];
        }
    }
    
    return createdAtString;
}

@end
