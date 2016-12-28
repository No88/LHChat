//
//  LHChatTimeCell.m
//  LHChatUI
//
//  Created by liuhao on 2016/12/27.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatTimeCell.h"

@implementation LHChatTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.timeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 11)];
        self.timeLable.textAlignment = NSTextAlignmentCenter;
        self.timeLable.textColor = [UIColor lh_colorWithHex:0x8e8e93];
        self.timeLable.font = [UIFont systemFontOfSize:11.0];
        self.timeLable.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.timeLable];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
