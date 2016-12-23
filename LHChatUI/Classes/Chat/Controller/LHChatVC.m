//
//  LHChatVC.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatVC.h"
#import "LHChatBarView.h"

NSString *const kTableViewOffset = @"contentOffset";
NSString *const kTableViewFrame = @"frame";

@interface LHChatVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) LHChatBarView *chatBarView;
// 满足刷新
@property (nonatomic, assign, getter=isMeetRefresh) BOOL meetRefresh;

@end

@implementation LHChatVC


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupInit];
}

- (void)setupInit {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatBarView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.chatBarView action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:tapGesture];
}

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:kTableViewFrame];
    [self.tableView removeObserver:self forKeyPath:kTableViewOffset];
}

#pragma mark - 事件监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *messageCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!messageCell) {
        messageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return messageCell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.isMeetRefresh) return nil;
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 40)];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((SCREEN_W - 15) * 0.5, (20 - 15) * 0.5, 15, 15)];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicatorView startAnimating];
    [refreshView addSubview:activityIndicatorView];
    return refreshView;
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, SCREEN_W, SCREEN_H - kChatBarHeight - kNavBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor grayColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView addObserver:self forKeyPath:kTableViewOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_tableView addObserver:self forKeyPath:kTableViewFrame options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _tableView;
}

- (LHChatBarView *)chatBarView {
    if (!_chatBarView) {
        _chatBarView = [[LHChatBarView alloc] initWithFrame:CGRectMake(0, SCREEN_H - kChatBarHeight, SCREEN_W, kChatBarHeight)];
        _chatBarView.backgroundColor = [UIColor greenColor];
        _chatBarView.tableView = self.tableView;
        _chatBarView.sendContent = ^(LHContentModel *content) {
            
        };
    }
    return _chatBarView;
}

@end
