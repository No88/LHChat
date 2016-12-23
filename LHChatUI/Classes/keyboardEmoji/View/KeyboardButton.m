//
//  KeyboardButton.m
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "KeyboardButton.h"

@implementation KeyboardButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat imageWH = 36;
    CGFloat imageX = (contentRect.size.width - imageWH) * 0.5;
    CGFloat imageY = contentRect.size.height - 19 - imageWH;
    return CGRectMake(imageX, imageY, imageWH, imageWH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat titleY = CGRectGetMaxY(self.imageView.frame) + 7;
    return CGRectMake(0, titleY, contentRect.size.width, 12);
}
@end
