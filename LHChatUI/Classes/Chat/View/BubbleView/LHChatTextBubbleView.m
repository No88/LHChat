//
//  LHChatTextBubbleView.m
//  LHChatUI
//
//  Created by liuhao on 2016/12/26.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatTextBubbleView.h"
#import "YYLabel.h"
#import "YYImage.h"
#import "YYAnimatedImageView.h"
#import "NSAttributedString+YYText.h"
#import "FaceDefine.h"

//　textLaebl 最大宽度
CGFloat const TEXTLABEL_MAX_WIDTH = 200.0f;
CGFloat const LABEL_FONT_SIZE = 15.0f;

static CGSize kTextBoundingSize;

@interface LHChatTextBubbleView () {
    NSDataDetector *_detector;
    NSArray *_urlMatches;
}

@property (nonatomic, strong) YYLabel *textLabel;

@end

@implementation LHChatTextBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _textLabel.userInteractionEnabled = YES;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.userInteractionEnabled = NO;
        _textLabel.multipleTouchEnabled = NO;
        _textLabel.textColor = [UIColor lh_colorWithHex:0x1d1d1d];
        // _textLabel.displaysAsynchronously = YES; /// enable async display
        _textLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        // _textLabel.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        // };
        [self addSubview:_textLabel];
        
        _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
    if (self.messageModel.isSender) {
        frame.origin.x = BUBBLE_VIEW_PADDING;
    }else{
        frame.origin.x = BUBBLE_VIEW_PADDING + BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = BUBBLE_VIEW_PADDING;
    [self.textLabel setFrame:frame];
}


#pragma mark - setter

- (void)setMessageModel:(LHMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    
    
    NSAttributedString *text = [LHChatTextBubbleView processModel:self.messageModel];
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(TEXTLABEL_MAX_WIDTH, MAXFLOAT)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:text];
    
    _textLabel.textLayout = textLayout;
    _textLabel.size = textLayout.textBoundingSize;
    kTextBoundingSize = textLayout.textBoundingSize;
    // _textLabel.text = self.model.content;
    // _textLabel.textColor = model.isSender ? [UIColor whiteColor] : [UIColor colorWithHex:0x47474a];
    
    // 去除超链接
    // _urlMatches = [_detector matchesInString:self.model.content options:0 range:NSMakeRange(0, self.model.content.length)];
    // [self highlightLinksWithIndex:NSNotFound];
}

#pragma mark - 私有




+ (NSAttributedString *)processModel:(LHMessageModel *)model {
    NSMutableAttributedString * mAttributedString = [[NSMutableAttributedString alloc]init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];//调整行间距
    [paragraphStyle setParagraphSpacing:4];//调整行间距
    
    NSDictionary *attri = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:15],model.isSender ? [UIColor whiteColor] : [UIColor lh_colorWithHex:0x47474a],paragraphStyle] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName,NSParagraphStyleAttributeName]];
    [mAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:model.content attributes:attri]];
    
    //创建匹配正则表达式的类型描述模板
    NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    //创建匹配对象
    NSError * error;
    NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    //判断
    if (!regularExpression) {
        //如果匹配规则对象为nil
        NSLog(@"正则创建失败！");
        NSLog(@"error = %@",[error localizedDescription]);
        return nil;
    } else {
        NSArray * resultArray = [regularExpression matchesInString:mAttributedString.string options:NSMatchingReportCompletion range:NSMakeRange(0, mAttributedString.string.length)];
        
        NSInteger index = resultArray.count;
        while (index > 0) {
            index --;
            NSTextCheckingResult *result = resultArray[index];
            //根据range获取字符串
            NSString * rangeString = [mAttributedString.string substringWithRange:result.range];
            DLog(@"rangge is %@",rangeString);
            
            
            NSString *imageName =  [FaceDict objectForKey:rangeString];
            if (imageName) {
                //获取图片
                YYImage * image = [LHChatTextBubbleView getImageWithRangeString:imageName];//这是个自定义的方法
                if (image != nil) {
                    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
                    imageView.width = 50;
                    imageView.height = 50;
                    
                    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:[UIFont systemFontOfSize:15] alignment:YYTextVerticalAlignmentCenter];
                    //开始替换
                    [mAttributedString replaceCharactersInRange:result.range withAttributedString:attachText];
                }
            }
        }
    }
    
    return mAttributedString;
}

//根据rangeString获取plist中的图片
+ (YYImage *)getImageWithRangeString:(NSString *)rangeString {
    YYImage *image = [YYImage imageNamed:rangeString];
    image.preloadAllAnimatedImageFrames = YES;
    return image;
}

+ (CGFloat)heightForBubbleWithObject:(LHMessageModel *)object {
    
    NSAttributedString *text = [self processModel:object];
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(TEXTLABEL_MAX_WIDTH, MAXFLOAT)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:text];
    return 2 * BUBBLE_VIEW_PADDING + textLayout.textBoundingSize.height + 20;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 40;
    if (2*BUBBLE_VIEW_PADDING + kTextBoundingSize.height > height) {
        height = 2*BUBBLE_VIEW_PADDING + kTextBoundingSize.height;
    }
    
    
    CGFloat width = kTextBoundingSize.width + BUBBLE_VIEW_PADDING*2 + BUBBLE_VIEW_PADDING;
    if (width < 46.5) {
        width = 46.5;
    }
    
    return CGSizeMake(width, height);
}

#pragma mark 处理超链接
- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_textLabel.attributedText mutableCopy];
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            } else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    _textLabel.attributedText = attributedString;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    NSMutableAttributedString* optimizedAttributedText = [self.textLabel.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [self.textLabel.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.textLabel.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName]) {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:self.textLabel.font range:NSMakeRange(0, [self.textLabel.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName]) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:self.textLabel.lineBreakMode];
            
            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    
    // modify kCTLineBreakByTruncatingTail lineBreakMode to kCTLineBreakByWordWrapping
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
         NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
         
         if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
             [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
         }
         
         [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
         [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
     }];
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = self.textLabel.frame;
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.textLabel.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.textLabel.numberOfLines > 0 ? MIN(self.textLabel.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    //NSLog(@"num lines: %d", numberOfLines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}


#pragma mark - public

-(void)bubbleViewPressed:(id)sender {
    return;
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:self];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    
    [self highlightLinksWithIndex:NSNotFound];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                [self routerEventWithName:kRouterEventTextURLTapEventName userInfo:@{kMessageKey : self.messageModel, @"url" : match.URL}];
                break;
            }
        }
    }
}


+ (UIFont *)textLabelFont {
    return [UIFont systemFontOfSize:LABEL_FONT_SIZE];
}

+ (NSLineBreakMode)textLabelLineBreakModel {
    return NSLineBreakByCharWrapping;
}

@end
