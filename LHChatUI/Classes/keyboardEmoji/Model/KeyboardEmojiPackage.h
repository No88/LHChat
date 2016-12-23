//
//  KeyboardEmojiPackage.h
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardEmojiPackage : NSObject

/** 当前组文件夹名称 */
@property (nonatomic, strong) NSString *group_folder_name;

/** 当前组的名称 */
@property (nonatomic, strong) NSString *group_name;

/** 当前组所有的表情模型 */
@property (nonatomic, strong) NSMutableArray *emojis;

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)shareInstance;

/** 所有组数据 */
+ (NSArray *)packages;
/** 加载所有组表情 */
+ (NSArray *)loadPackages;

/**
 根据指定字符串, 生成带表情图片的属性字符串
 
 - parameter str: 指定字符串
 
 - returns: 带表情图片的属性字符串
 */
- (NSAttributedString *)attributedString:(NSString *)string font:(UIFont *)font;

@end
