//
//  KeyboardEmojiAttachment.h
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KeyboardEmojiModel;


@interface KeyboardEmojiAttachment : NSTextAttachment
/** 保存当前附件对应的字符串 */
@property (nonatomic, strong) NSString *chs;
/** 图片 */
@property (nonatomic, strong) UIWebView *webImage;

/**
 *  根据表情模型生成表情字符串
 *
 *  @return 带表情的字符串
 */
+ (NSAttributedString *)emojiString:(KeyboardEmojiModel *)emoji font:(UIFont *)font;

@end
