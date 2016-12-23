//
//  LHChatBarMoreView.h
//  LHChatUI
//
//  Created by lenhart on 2016/12/23.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LHChatBarMoreView;

@protocol LHChatBarMoreViewDelegate <NSObject>

@required
- (void)moreViewTakePicAction:(LHChatBarMoreView *)moreView;
- (void)moreViewPhotoAction:(LHChatBarMoreView *)moreView;

@end

@interface LHChatBarMoreView : UIView

@property (nonatomic, weak) id<LHChatBarMoreViewDelegate> delegate;

@end
