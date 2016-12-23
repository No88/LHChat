//
//  LHMainVCTableViewController.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHMainVC.h"
#import "LHConversationCell.h"
#import "LHChatVC.h"

@interface LHMainVC ()

@end

@implementation LHMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self lh_setupConfigWithTitle:@"会话"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LHConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LHConversationCell class])];
    if (!cell) {
        cell = [[LHConversationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([LHConversationCell class])];
        cell.textLabel.text = @"点我进聊天室";
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LHChatVC *cahtVC = [[LHChatVC alloc] init];
    [self.navigationController pushViewController:cahtVC animated:YES];
}

@end
