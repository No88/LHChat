//
//  LHChatViewBaseCell.h
//  LHChatUI
//
//  Created by liuhao on 2016/12/26.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHMessageModel.h"
#import "LHChatBaseBubbleView.h"



@interface LHChatViewBaseCell : UITableViewCell {
    UIImageView *_headImageView;
    UILabel *_nameLabel;
    LHChatBaseBubbleView *_bubbleView;
}

@property (nonatomic, strong) UIImageView *headImageView;       //头像
@property (nonatomic, strong) UILabel *nameLabel;               //姓名（暂时不支持显示）
@property (nonatomic, strong) LHChatBaseBubbleView *bubbleView;   //内容区域

@property (nonatomic, strong) LHMessageModel *messageModel;

- (id)initWithMessageModel:(LHMessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setupSubviewsForMessageModel:(LHMessageModel *)model;

+ (NSString *)cellIdentifierForMessageModel:(LHMessageModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(LHMessageModel *)model;

@end
