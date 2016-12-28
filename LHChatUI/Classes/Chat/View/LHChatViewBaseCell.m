//
//  LHChatViewBaseCell.m
//  LHChatUI
//
//  Created by liuhao on 2016/12/26.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatViewBaseCell.h"

@implementation LHChatViewBaseCell

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = _headImageView.frame;
    frame.origin.x = _messageModel.isSender ? (self.bounds.size.width - _headImageView.frame.size.width - HEAD_X) : HEAD_X;
    _headImageView.frame = frame;
    
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10, CGRectGetMinY(_headImageView.frame), NAME_LABEL_WIDTH, NAME_LABEL_HEIGHT);
}

- (void)setMessageModel:(LHMessageModel *)messageModel {
    _messageModel = messageModel;
    
    _nameLabel.hidden = !messageModel.isChatGroup;
    NSString *imgaeName = nil;
    if (_messageModel.isSender) {
        imgaeName = @"receive_head.jpg";
    } else {
        imgaeName = @"send_head.jpg";
    }
    self.headImageView.image = [UIImage imageNamed:imgaeName];
}

#pragma mark - 事件监听
- (void)headImagePressed:(id)sender {
    [super routerEventWithName:kRouterEventChatHeadImageTapEventName userInfo:@{kMessageKey : self.messageModel}];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    [super routerEventWithName:eventName userInfo:userInfo];
}

#pragma mark - public
- (id)initWithMessageModel:(LHMessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePressed:)];
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HEAD_X, 0, HEAD_SIZE, HEAD_SIZE)];
        [_headImageView addGestureRecognizer:tap];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.multipleTouchEnabled = YES;
        _headImageView.backgroundColor = [UIColor lh_colorWithHex:0xeeeff3];
        [self.contentView addSubview:_headImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:NAME_LABEL_FONT_SIZE];
        [self.contentView addSubview:_nameLabel];
        
        [self setupSubviewsForMessageModel:model];
    }
    return self;
}

- (void)setupSubviewsForMessageModel:(LHMessageModel *)model {
    if (model.isSender) {
        self.headImageView.frame = CGRectMake(self.bounds.size.width - HEAD_SIZE - HEAD_PADDING, CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    } else {
        self.headImageView.frame = CGRectMake(0, CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
}

+ (NSString *)cellIdentifierForMessageModel:(LHMessageModel *)model {
    NSString *identifier = @"MessageCell";
    if (model.isSender) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    } else {
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    switch (model.type) {
        case MessageBodyType_Text: {
            identifier = [identifier stringByAppendingString:@"Text"];
            break;
        }
        case MessageBodyType_Image: {
            identifier = [identifier stringByAppendingString:@"Image"];
            break;
        }
        case MessageBodyType_Video: {
            identifier = [identifier stringByAppendingString:@"Audio"];
            break;
        }
        case MessageBodyType_Location: {
            identifier = [identifier stringByAppendingString:@"Location"];
            break;
        }
        case MessageBodyType_Voice: {
            identifier = [identifier stringByAppendingString:@"Video"];
            break;
        }
            
        default:
            break;
    }
    
    return identifier;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(LHMessageModel *)model {
    return HEAD_SIZE + CELLPADDING;
}

@end
