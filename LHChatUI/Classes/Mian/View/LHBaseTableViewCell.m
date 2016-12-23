//
//  LHBaseTableViewCell.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHBaseTableViewCell.h"

@implementation LHBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupInit];
}

- (void)setupInit {
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage lh_imageWithColor:[UIColor lh_colorWithHex:0xf7f7f9]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
