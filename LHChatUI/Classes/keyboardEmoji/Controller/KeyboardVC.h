//
//  KeyboardVC.h
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyboardEmojiModel;

typedef void(^EmojiCallBack)(KeyboardEmojiModel *keyboardEmoji);


@interface KeyboardVC : UIViewController
// 发送
@property (nonatomic, strong) void (^emojiSend)();
/** 回调 */
@property (nonatomic, strong) EmojiCallBack emojiCallBack;


- (instancetype)initWithCallBack:(EmojiCallBack)callBack;

@end
