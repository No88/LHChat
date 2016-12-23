//
//  KeyboardEmojiModel.m
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "KeyboardEmojiModel.h"

@implementation KeyboardEmojiModel


- (NSString *)imagePath {
    if (self.group_folder_name) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:self.id ofType:nil];
//        return [path stringByAppendingPathComponent:self.gif];
        return [[NSBundle mainBundle] pathForResource:self.gif ofType:nil];
    }
    return nil;
}


- (NSString *)code {
//    NSScanner *scanner = [NSScanner scannerWithString:self.code];
//    UInt32 result = 0;
//    [scanner scanHexInt:&result];
    NSRange range;
    range.location = [self.name rangeOfString:@"["].location + 1;
    range.length = [self.name rangeOfString:@"]"].location - range.location;
    return [self.name substringWithRange:range];
}



- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

@end
