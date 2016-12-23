//
//  UIImage+Common.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "UIImage+Common.h"

@implementation UIImage (Common)

+ (UIImage *)lh_imageWithColor:(UIColor *)color {
    return [UIImage lh_imageWithColor:color size:CGSizeMake(20, 20)];
}

+ (UIImage *)lh_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (color == nil) {
        return nil;
    }
    
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
