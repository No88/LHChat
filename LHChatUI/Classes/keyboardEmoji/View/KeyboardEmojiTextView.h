//
//  KeyboardEmojiTextView.h
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyboardEmojiModel;

@interface KeyboardEmojiTextView : UITextView

@property (nonatomic, strong) void(^insertEmojiTextBlock)(UITextView *textView);

/**
 插入表情文字
 
 - parameter emoji: 需要插入的表情模型
 */
- (void)insertEmojiText:(KeyboardEmojiModel *)emoji;

/**
 插入表情
 
 - parameter emoji: 需要插入的表情模型
 */
- (void)insertEmoji:(KeyboardEmojiModel *)emoji;

/**
 获取属性字符串对应的文本字符串
 
 - returns: 文本字符串
 */
- (NSString *)emojiString;

@end
