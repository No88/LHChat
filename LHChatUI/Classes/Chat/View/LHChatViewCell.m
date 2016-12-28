//
//  LHChatViewCell.m
//  LHChatUI
//
//  Created by liuhao on 2016/12/26.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatViewCell.h"

CGFloat const ACTIVTIYVIEW_BUBBLE_PADDING = 5.0f;
CGFloat const SEND_STATUS_SIZE = 20.0f;

@implementation LHChatViewCell

- (id)initWithMessageModel:(LHMessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithMessageModel:model reuseIdentifier:reuseIdentifier]) {
        self.headImageView.clipsToBounds = YES;
        self.headImageView.layer.cornerRadius = 20.0;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = self.headImageView.frame.origin.y;
    
    if (self.messageModel.isChatGroup) {
        bubbleFrame.origin.y = self.headImageView.frame.origin.y + NAME_LABEL_HEIGHT;
    }
    if (self.messageModel.isSender) {
        bubbleFrame.origin.y = self.headImageView.frame.origin.y;
        // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
        switch (self.messageModel.status) {
            case MessageDeliveryState_Delivering:
            {
                [_activityView setHidden:NO];
                [_retryButton setHidden:YES];
                [_activtiy setHidden:NO];
                [_activtiy startAnimating];
            }
                break;
            case MessageDeliveryState_Delivered:
            {
                [_activtiy stopAnimating];
                [_activityView setHidden:YES];
                
            }
                break;
            case MessageDeliveryState_Failure:
            {
                [_activityView setHidden:NO];
                [_activtiy stopAnimating];
                [_activtiy setHidden:YES];
                [_retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        
        bubbleFrame.origin.x = self.headImageView.frame.origin.x - bubbleFrame.size.width - 8;
        _bubbleView.frame = bubbleFrame;
        
        CGRect frame = self.activityView.frame;
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING;
        frame.origin.y = _bubbleView.center.y - frame.size.height / 2;
        self.activityView.frame = frame;
    }
    else{
        bubbleFrame.origin.x = HEAD_PADDING  + HEAD_SIZE + 8;
        _bubbleView.frame = bubbleFrame;
    }
}

- (void)setMessageModel:(LHMessageModel *)model {
    [super setMessageModel:model];
    
    if (model.isChatGroup) {
//        _nameLabel.text = [model.message.ext objectForKey:sendUserName];
        _nameLabel.hidden = model.isSender;
    }
    
    _bubbleView.messageModel = self.messageModel;
    [_bubbleView sizeToFit];
}

#pragma mark - action

// 重发按钮事件
- (void)retryButtonPressed:(UIButton *)sender {
    [self routerEventWithName:kRouterEventChatResendEventName
                     userInfo:@{kShouldResendCell : self}];
}

#pragma mark - private
- (void)setupSubviewsForMessageModel:(LHMessageModel *)messageModel
{
    [super setupSubviewsForMessageModel:messageModel];
    
    if (messageModel.isSender) {
        // 发送进度显示view
        _activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE)];
        [_activityView setHidden:YES];
        [self.contentView addSubview:_activityView];
        
        // 重发按钮
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.frame = CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE);
        [_retryButton addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setImage:[UIImage imageNamed:@"messageSendFail"] forState:UIControlStateNormal];
        [_activityView addSubview:_retryButton];
        
        // 菊花
        _activtiy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activtiy.backgroundColor = [UIColor clearColor];
        [_activityView addSubview:_activtiy];
    }
    
    _bubbleView = [self bubbleViewForMessageModel:messageModel];
    [self.contentView addSubview:_bubbleView];
}

- (LHChatBaseBubbleView *)bubbleViewForMessageModel:(LHMessageModel *)messageModel {
    switch (messageModel.type) {
        case MessageBodyType_Text: {
            return [[LHChatTextBubbleView alloc] init];
        }
            break;
        case MessageBodyType_Image: {
            return [[LHChatImageBubbleView alloc] init];
        }
            break;
        case MessageBodyType_Voice: {
            return [[LHChatAudioBubbleView alloc] init];
        }
            break;
        case MessageBodyType_Location: {
            return [[LHChatLocationBubbleView alloc] init];
        }
            break;
        case MessageBodyType_Video: {
            return [[LHChatVideoBubbleView alloc] init];
        }
            break;
        default:
            break;
    }
    
    return nil;
}

+ (CGFloat)bubbleViewHeightForMessageModel:(LHMessageModel *)messageModel {
    switch (messageModel.type) {
        case MessageBodyType_Text: {
            return [LHChatTextBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_Image: {
            return [LHChatImageBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_Voice: {
            return [LHChatAudioBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_Location: {
            return [LHChatLocationBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_Video: {
            return [LHChatVideoBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        default:
            break;
    }
    
    return HEAD_SIZE;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(LHMessageModel *)model {
    NSInteger bubbleHeight = [self bubbleViewHeightForMessageModel:model];
    NSInteger headHeight = HEAD_SIZE;
    if (model.isChatGroup && !model.isSender) {
        bubbleHeight += NAME_LABEL_HEIGHT;
    }
    return MAX(headHeight, bubbleHeight);
}

@end
