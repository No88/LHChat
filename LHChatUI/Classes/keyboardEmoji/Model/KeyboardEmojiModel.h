//
//  KeyboardEmojiModel.h
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardEmojiModel : NSObject

/** 当前表情对应的文件夹名称 */
@property (nonatomic, strong) NSString *group_folder_name;

/** 当前表情对应的字符串 */
@property (nonatomic, strong) NSString *name;

/** 当前表情对应的图片 */
@property (nonatomic, strong) NSString *gif;

/** 生成当前表情图片的绝对路径 */
@property (nonatomic, strong) NSString *imagePath;

/** Emoji表情对应的字符串 */
@property (nonatomic, strong) NSString *code;

/** Emoji表情处理之后的字符串 */
@property (nonatomic, strong) NSString *emojiStr;

/** 记录是否是删除表情 */
@property (nonatomic, assign) BOOL *isRemoveButton;

/** 记录当前表情使用的次数 */
@property (nonatomic, assign) NSInteger count;


- (instancetype)initWithDict:(NSDictionary *)dict;

@end
