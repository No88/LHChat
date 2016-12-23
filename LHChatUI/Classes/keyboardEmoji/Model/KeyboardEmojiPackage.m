//
//  KeyboardEmojiPackage.m
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "KeyboardEmojiPackage.h"
#import "KeyboardEmojiModel.h"
#import "KeyboardEmojiAttachment.h"

static NSArray *_packages = nil;

@implementation KeyboardEmojiPackage

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}



+ (NSArray *)packages {
    return _packages;
}

+ (NSArray *)loadPackages {
    if (_packages) {
        return _packages;
    }
    
    NSMutableArray *models = [NSMutableArray array];
    KeyboardEmojiPackage *packge = [[KeyboardEmojiPackage alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoticons.plist" ofType:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *array = dict[@"packages"];
    
    for (NSDictionary *dict in array) {
        KeyboardEmojiPackage *package = [[KeyboardEmojiPackage alloc] initWithDict:dict];
        [packge loadEmojis];
        [packge appendEmptyEmoji];
        [models addObject:package];
    }
    
    _packages = models;
    return models;
}


/**
 *  加载当前组所有的表情
 */
- (void)loadEmojis {

    NSString *path = [[NSBundle mainBundle] pathForResource:self.group_name ofType:nil];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *models = [NSMutableArray array];
    
    NSInteger index = 0;
    
    for (NSDictionary *dict in array) {
        KeyboardEmojiModel *emotion = [[KeyboardEmojiModel alloc] initWithDict:dict];
        emotion.group_folder_name = self.group_folder_name;
        [models addObject:emotion];
        index ++;
    }
    
    self.emojis = models;
}


/**
 根据字符串查找表情模型
 
 - parameter str: 指定字符串
 
 - returns: 表情模型
 */
- (KeyboardEmojiModel *)findEmoji:(NSString *)string {
    __block KeyboardEmojiModel *emotion;
    for (KeyboardEmojiPackage *package in [KeyboardEmojiPackage loadPackages]) {
        [package.emojis enumerateObjectsUsingBlock:^(KeyboardEmojiModel *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([item.name isEqualToString:string]) {
                emotion = item;
            }
        }];
        
        if (emotion) {
            break;
        }
    }
    return emotion;
}


/**
 *  追加空白按钮, 当当前组的数据不能被8整除时, 就追加空白按钮, 让当前组能够被8整除
 */
- (void)appendEmptyEmoji {
    NSInteger count = self.emojis.count % 8;
    if (!count) return;
    for (NSInteger i = count; i < 8; i++) {
        [self.emojis addObject:[KeyboardEmojiModel new]];
    }
}

#pragma mark - lazy 

- (NSMutableArray *)emojis {
    if (!_emojis) {
        _emojis = [NSMutableArray array];
    }
    return _emojis;
}

#pragma mark - 外部方法
- (NSAttributedString *)attributedString:(NSString *)string font:(UIFont *)font {
    NSString *pattern = @"\\[\\w+\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *array = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    NSMutableAttributedString *stringM = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSInteger index = array.count;
    while (index > 0) {
        index --;
        NSTextCheckingResult *result = array[index];
        NSString *temp = [string substringWithRange:result.range];
        KeyboardEmojiModel *emotion = [self findEmoji:temp];
        if (!emotion) continue;
        
        NSAttributedString *attrString = [KeyboardEmojiAttachment emojiString:emotion font:font];
        
        [stringM replaceCharactersInRange:result.range withAttributedString:attrString];
    }
    
    return stringM;
}


#pragma mark - 单例
+ (instancetype)shareInstance {
    KeyboardEmojiPackage *instance = [[self alloc] init];
    return instance;
}

static KeyboardEmojiPackage *_instance = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:zone] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}


@end
