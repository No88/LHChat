//
//  UIColor+RGB.h
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGB)

// 透明度固定为1，以0x开头的十六进制转换成的颜色
+ (UIColor *)lh_colorWithHex:(long)hexColor;

// 0x开头的十六进制转换成的颜色,透明度可调整
+ (UIColor *)lh_colorWithHex:(long)hexColor alpha:(float)opacity;

// 颜色转换三：iOS中十六进制的颜色（以#开头）转换为UIColor
+ (UIColor *)lh_colorWithHexString:(NSString *)color;

@end
