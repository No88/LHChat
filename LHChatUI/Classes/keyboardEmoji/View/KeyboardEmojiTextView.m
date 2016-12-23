//
//  KeyboardEmojiTextView.m
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "KeyboardEmojiTextView.h"
#import "KeyboardEmojiAttachment.h"
#import "KeyboardEmojiModel.h"

@implementation KeyboardEmojiTextView

- (void)insertEmojiText:(KeyboardEmojiModel *)emoji {
    self.text = [self.text stringByAppendingString:emoji.name];
    !self.insertEmojiTextBlock ? : self.insertEmojiTextBlock(self);
}

- (void)insertEmoji:(KeyboardEmojiModel *)emoji {
    NSString *temp = emoji.emojiStr;
    if (temp && ![temp isEqualToString:@"\0"]) {
        [self replaceRange:self.selectedTextRange withText:temp];
    }
    
    if (emoji.imagePath) {
        NSMutableAttributedString *stringM = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        
        NSAttributedString *emojiStr = [KeyboardEmojiAttachment emojiString:emoji font:[UIFont systemFontOfSize:16.0f]];
        
        NSRange range = self.selectedRange;
        [stringM replaceCharactersInRange:range withAttributedString:emojiStr];
        
        [stringM addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(range.location, 1)];
        
        self.attributedText = stringM;
        
        self.selectedRange = NSMakeRange(range.location + 1, 0);
        return;
    }
}

- (NSString *)emojiString {
    NSString *string;
    
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary* attrs, NSRange range, BOOL * stop) {
        if (attrs[@"NSAttachment"]) {
            KeyboardEmojiAttachment *attachment = attrs[@"NSAttachment"];
            [string stringByAppendingString:attachment.chs];
        } else {
            [string stringByAppendingString:[self.attributedText.string substringWithRange:range]];
        }
    }];
    
    return string;
}

@end
