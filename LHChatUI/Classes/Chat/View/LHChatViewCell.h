//
//  LHChatViewCell.h
//  LHChatUI
//
//  Created by liuhao on 2016/12/26.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatViewBaseCell.h"
#import "LHChatTextBubbleView.h"
#import "LHChatImageBubbleView.h"
#import "LHChatAudioBubbleView.h"
#import "LHChatVideoBubbleView.h"
#import "LHChatLocationBubbleView.h"



@interface LHChatViewCell : LHChatViewBaseCell

@property (nonatomic, strong) UIActivityIndicatorView *activtiy;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIButton *retryButton;

@end
