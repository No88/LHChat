//
//  LHChatBarMoreView.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/23.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatBarMoreView.h"

const NSInteger CHAT_BUTTON_SIZE = 55;
const NSInteger INSETS = 8;

@interface LHChatBarMoreView ()

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;

@end

@implementation LHChatBarMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lh_colorWithHex:0xf2f2f6];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    CGFloat insets = (self.frame.size.width - 4 * CHAT_BUTTON_SIZE) / 5;
    
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_photoButton setFrame:CGRectMake(insets, 25, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_photoButton setImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"chatBar_colorMore_photo"]] forState:UIControlStateNormal];
    [_photoButton setImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"chatBar_colorMore_photoSelected"]] forState:UIControlStateHighlighted];
    [_photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    _photoButton.titleLabel.textColor = [UIColor lh_colorWithHex:0x8e8e93];
    [self addSubview:_photoButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(insets, CGRectGetMaxY(_photoButton.frame) + 10, CHAT_BUTTON_SIZE, 12)];
    label.font = [UIFont systemFontOfSize:12];
    label.text = @"照片";
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    _takePicButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_takePicButton setFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 25, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_takePicButton setImage: [UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"chatBar_colorMore_camera"]] forState:UIControlStateNormal];
    [_takePicButton setImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"chatBar_colorMore_cameraSelected"]] forState:UIControlStateHighlighted];
    [_takePicButton addTarget:self action:@selector(takePicAction) forControlEvents:UIControlEventTouchUpInside];
    _takePicButton.titleLabel.textColor = [UIColor lh_colorWithHex:0x8e8e93];
    [self addSubview:_takePicButton];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(insets*2+ CHAT_BUTTON_SIZE, CGRectGetMaxY(_takePicButton.frame) + 10, CHAT_BUTTON_SIZE, 12)];
    label2.font = [UIFont systemFontOfSize:12];
    label2.text = @"拍照";
    label2.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label2];
}

#pragma mark - action

- (void)takePicAction {
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)photoAction {
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
        [_delegate moreViewPhotoAction:self];
    }
}

@end
