//
//  LHTools.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/23.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHTools.h"
#import <AVFoundation/AVFoundation.h>


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

@end
