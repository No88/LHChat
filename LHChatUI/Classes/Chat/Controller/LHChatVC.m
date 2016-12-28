//
//  LHChatVC.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatVC.h"
#import "LHChatBarView.h"
#import "LHContentModel.h"
#import "LHMessageModel.h"
#import "LHIMDBManager.h"
#import "LHTools.h"
#import "LHChatViewCell.h"
#import "LHChatTimeCell.h"
#import "SDImageCache.h"
#import "LHPhotoPreviewController.h"
#import "XSBrowserAnimateDelegate.h"

NSString *const kTableViewOffset = @"contentOffset";
NSString *const kTableViewFrame = @"frame";

@interface LHChatVC () <UITableViewDelegate, UITableViewDataSource, XSBrowserDelegate> {
    NSArray *_imageKeys;
}

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) LHChatBarView *chatBarView;
// 满足刷新
@property (nonatomic, assign, getter=isMeetRefresh) BOOL meetRefresh;
// 正在刷新
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSCache *rowHeight;

// 消息时间
@property (nonatomic, strong) NSString *lastTime;
@property (nonatomic, assign) CGFloat tableViewOffSetY;
@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, strong) XSBrowserAnimateDelegate *browserAnimateDelegate;

@end

@implementation LHChatVC


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupInit];
    
    [self loadMessageWithId:nil];
    
    [self scrollToBottomAnimated:NO refresh:YES];
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

#pragma mark - public
//刷新并滑动到底部
- (void)scrollToBottomAnimated:(BOOL)animated refresh:(BOOL)refresh {
    // 表格滑动到底部
    if (refresh) [self.tableView reloadData];
    if (!self.dataSource.count) return;
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

#pragma mark - private
- (void)dropDownLoadDataWithScrollView:(UIScrollView *)scrollView {
    if ([scrollView isMemberOfClass:[UITableView class]]) {
        if (!self.isHeaderRefreshing) return;
        
        LHMessageModel *model = self.messages.firstObject;
        self.tableViewOffSetY = (self.tableView.contentSize.height - self.tableView.contentOffset.y);
        [self loadMessageWithId:model.id];
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableViewOffSetY)];
        self.headerRefreshing = NO;
    }
}


- (void)loadMessageWithId:(NSString *)Id {
    NSArray *messages = [[LHIMDBManager shareManager] searchModelArr:[LHMessageModel class] byKey:Id];
    
    self.meetRefresh = messages.count == kMessageCount;
    
    [messages enumerateObjectsUsingBlock:^(LHMessageModel *messageModel, NSUInteger idx, BOOL * stop) {
        [self.dataSource insertObject:messageModel atIndex:0];
        [self.messages insertObject:messageModel atIndex:0];
        
        NSString *time = [LHTools processingTimeWithDate:messageModel.date];
        if (![self.lastTime isEqualToString:time]) {
            [self.dataSource insertObject:time atIndex:0];
            self.lastTime = time;
        }
    }];
    
    NSUInteger index = [self.dataSource indexOfObject:self.lastTime];
    if (index) {
        [self.dataSource removeObjectAtIndex:index];
        [self.dataSource insertObject:self.lastTime atIndex:0];
    }
}

- (NSIndexPath *)insertNewMessageOrTime:(id)NewMessage {
    NSIndexPath *index = [NSIndexPath indexPathForRow:self.dataSource.count inSection:0];
    [self.dataSource addObject:NewMessage];
    [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    return index;
}


- (void)sendMessage:(LHContentModel *)content {
    
    if (content.words && content.words.length) {
        // 文字类型
        [self seavMessage:content.words type:MessageBodyType_Text];
    }
    if (!content.photos && !content.photos.photos.count) return;
    // 图片类型
    [content.photos.photos enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * stop) {
        
        [self seavMessage:image type:MessageBodyType_Image];
    }];
}

- (void)seavMessage:(id)content type:(MessageBodyType)type {
    NSString *date = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    __block LHMessageModel *messageModel = [LHMessageModel new];
    messageModel.isSender = YES;
    messageModel.isRead = YES;
    messageModel.status = MessageDeliveryState_Delivering;
    messageModel.date = date;
    messageModel.type = type;
    switch (type) {
        case MessageBodyType_Text: {
            messageModel.content = content;
            break;
        }
        case MessageBodyType_Image: {
            UIImage *image = (UIImage *)content;
            messageModel.width = image.size.width;
            messageModel.height = image.size.height;
            [SDImageCache.sharedImageCache storeImage:image forKey:messageModel.date completion:nil];
            break;
        }
        default:
            break;
    }
    [[LHIMDBManager shareManager] insertModel:messageModel];
    NSString *time = [LHTools processingTimeWithDate:messageModel.date];
    if ([time isEqualToString:self.lastTime]) {
        [self insertNewMessageOrTime:time];
        self.lastTime = time;
    }
    NSIndexPath *index = [self insertNewMessageOrTime:messageModel];
    [self.messages addObject:messageModel];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
#warning 
    // 模仿延迟发送
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        messageModel.status = MessageDeliveryState_Delivered;
        LHMessageModel *dbMessageModel = [[LHIMDBManager shareManager] searchModel:[LHMessageModel class] keyValues:@{@"date" : date, @"status" : @(MessageDeliveryState_Delivering)}];
        dbMessageModel.status = MessageDeliveryState_Delivered;
        NSArray *cells = [self.tableView visibleCells];
        [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[LHChatViewCell class]]) {
                LHChatViewCell *messagecell = (LHChatViewCell *)obj;
                if ([messagecell.messageModel.date isEqualToString:dbMessageModel.date]) {
                    [messagecell layoutSubviews];
                    [[LHIMDBManager shareManager] insertModel:dbMessageModel];
                    *stop = YES;
                }
            }
        }];
        
        // 模仿消息回复
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dbMessageModel.isSender = NO;
            dbMessageModel.id = nil;
            [[LHIMDBManager shareManager] insertModel:dbMessageModel];
            NSIndexPath *index = [self insertNewMessageOrTime:dbMessageModel];
            [self.messages addObject:dbMessageModel];
            [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

#pragma mark - 事件监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kTableViewFrame]) {
        UITableView *tableView = (UITableView *)object;
        CGRect newValue = [change[NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldValue = [change[NSKeyValueChangeOldKey] CGRectValue];
        if (newValue.size.height != oldValue.size.height &&
            tableView.contentSize.height > newValue.size.height) {
            
            [tableView setContentOffset:CGPointMake(0, tableView.contentSize.height - newValue.size.height) animated:YES];
        }
        return;
    }
    
    //    UITableView *tableView = (UITableView *)object;
    CGPoint newValue = [change[NSKeyValueChangeNewKey] CGPointValue];
    CGPoint oldValue = [change[NSKeyValueChangeOldKey] CGPointValue];
    if (!self.headerRefreshing) self.headerRefreshing = newValue.y < 40 && self.isMeetRefresh;
//    DLog(@"newValue = %f, oldValue = %f", newValue.y, oldValue.y);
}

#pragma mark  cell事件处理
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    LHMessageModel *model = [userInfo objectForKey:kMessageKey];
    if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]) {
        //点击图片
        [self chatImageCellBubblePressed:model];
    }
}


// 图片的bubble被点击
- (void)chatImageCellBubblePressed:(LHMessageModel *)model {
    NSMutableArray *imageKeys = @[].mutableCopy;
    __block NSString *currentKey = nil;
    [self.messages enumerateObjectsUsingBlock:^(LHMessageModel *messageModel, NSUInteger idx, BOOL * stop) {
        if (messageModel.type == MessageBodyType_Image) {
            [imageKeys addObject:messageModel.date];
            if ([messageModel.date isEqualToString:model.date]) {
                currentKey = messageModel.date;
            }
        }
    }];
    
    _imageKeys = imageKeys.copy;
    _imageIndex = [imageKeys indexOfObject:currentKey];
    LHPhotoPreviewController *photoPreview = [LHPhotoPreviewController new];
    photoPreview.currentIndex = _imageIndex;
    photoPreview.models = imageKeys;
    self.browserAnimateDelegate.delegate = self;
    self.browserAnimateDelegate.index = _imageIndex;
    self.browserAnimateDelegate.im = YES;
    photoPreview.transitioningDelegate = self.browserAnimateDelegate;
    photoPreview.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:photoPreview animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataSource objectAtIndex:indexPath.row];
    
    if ([obj isKindOfClass:[NSString class]]) {
        LHChatTimeCell *timeCell = (LHChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LHChatTimeCell class])];
        if (!timeCell) {
            timeCell = [[LHChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([LHChatTimeCell class])];
        }
        
        timeCell.timeLable.text = (NSString *)obj;
        
        return timeCell;
    }
    
    LHMessageModel *messageModel = (LHMessageModel *)obj;
    
    NSString *cellIdentifier = [LHChatViewCell cellIdentifierForMessageModel:messageModel];
    LHChatViewCell *messageCell = (LHChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!messageCell) {
        messageCell = [[LHChatViewCell alloc] initWithMessageModel:messageModel reuseIdentifier:cellIdentifier];
    }
    
    messageCell.messageModel = messageModel;
    
    return messageCell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 31;
    } else {
        LHMessageModel *model = (LHMessageModel *)obj;
        CGFloat height = [[self.rowHeight objectForKey:model.id] floatValue];
        if (height) {
            return height;
        }
        height = [LHChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:model];
        [self.rowHeight setObject:@(height) forKey:model.id];
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isMeetRefresh) {
        return 40;
    }
    return 20;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DLog(@" scrollViewDidEndDecelerating == %.2f", scrollView.contentOffset.y);
    [self dropDownLoadDataWithScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        DLog(@"scrollView停止滚动，完全静止");
        [self dropDownLoadDataWithScrollView:scrollView];
    } else {
        DLog(@"用户停止拖拽，但是scrollView由于惯性，会继续滚动，并且减速");
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.chatBarView hideKeyboard];
}

#pragma mark - XSBrowserDelegate
/** 获取一个和被点击cell一模一样的UIImageView */
- (UIImageView *)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate imageViewForRowAtIndex:(NSInteger)index {
    NSArray *cells = [self.tableView visibleCells];
    __block UIImageView *imageView = nil;
    [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LHChatViewCell class]]) {
            LHChatViewCell *cell = (LHChatViewCell *)obj;
            if (cell.messageModel.type == MessageBodyType_Image) {
                LHChatImageBubbleView *imageBubbleView = (LHChatImageBubbleView *)cell.bubbleView;
                if ([cell.messageModel.date isEqualToString:_imageKeys[index]]) {
                    imageView = [[UIImageView alloc] initWithImage:imageBubbleView.imageView.image];
                    imageView.frame = imageBubbleView.imageView.frame;
                    *stop = YES;
                }
            }
        }
    }];
    return imageView;
}

/** 获取被点击cell相对于keywindow的frame */
- (CGRect)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate fromRectForRowAtIndex:(NSInteger)index {
    NSArray *cells = [self.tableView visibleCells];
    __block LHChatImageBubbleView *currentImageBubbleView;
    __block UIImageView *imageView = nil;
    [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LHChatViewCell class]]) {
            LHChatViewCell *cell = (LHChatViewCell *)obj;
            if (cell.messageModel.type == MessageBodyType_Image) {
                LHChatImageBubbleView *imageBubbleView = (LHChatImageBubbleView *)cell.bubbleView;
                if ([cell.messageModel.date isEqualToString:_imageKeys[index]]) {
                    imageView = imageBubbleView.imageView;
                    currentImageBubbleView = imageBubbleView;
                    *stop = YES;
                }
            }
        }
    }];
    if (imageView) {
        return [currentImageBubbleView convertRect:imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    } else return CGRectZero;
}

/** 获取被点击cell中的图片, 将来在图片浏览器中显示的尺寸 */
- (CGRect)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate toRectForRowAtIndex:(NSInteger)index {
    __block CGSize size = CGSizeZero;
    [SDImageCache.sharedImageCache queryCacheOperationForKey:_imageKeys[index] done:^(UIImage * image, NSData * data, SDImageCacheType cacheType) {
        size = image.size;
    }];
    CGFloat height = size.height * SCREEN_W / size.width;
    if (height > SCREEN_H) {
        return CGRectMake(0, 0, SCREEN_W, height);
    } else {
        CGFloat offsetY = (SCREEN_H - height) * 0.5;
        return CGRectMake(0, offsetY, SCREEN_W, height);
    }
}

/** 是否在可视区域 */
- (BOOL)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate isVisibleForRowAtIndex:(NSInteger)index {
    NSArray *cells = [self.tableView visibleCells];
    __block BOOL isVisual = YES;
    [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LHChatViewCell class]]) {
            LHChatViewCell *cell = (LHChatViewCell *)obj;
            if (cell.messageModel.type == MessageBodyType_Image) {
                if ([cell.messageModel.date isEqualToString:_imageKeys[index]]) {
                    isVisual = NO;
                    *stop = YES;
                }
            }
        }
    }];
    return isVisual;
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, SCREEN_W, SCREEN_H - kChatBarHeight - kNavBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor lh_colorWithHex:0xffffff];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView addObserver:self forKeyPath:kTableViewOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_tableView addObserver:self forKeyPath:kTableViewFrame options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _tableView;
}

- (LHChatBarView *)chatBarView {
    if (!_chatBarView) {
        LHWeakSelf;
        _chatBarView = [[LHChatBarView alloc] initWithFrame:CGRectMake(0, SCREEN_H - kChatBarHeight, SCREEN_W, kChatBarHeight)];
        _chatBarView.backgroundColor = [UIColor lh_colorWithHex:0xf8f8fa];
        _chatBarView.tableView = self.tableView;
        _chatBarView.sendContent = ^(LHContentModel *content) {
            [weakSelf sendMessage:content];
        };
    }
    return _chatBarView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = @[].mutableCopy;
    }
    return _messages;
}

- (NSCache *)rowHeight {
    if (!_rowHeight) {
        _rowHeight = [NSCache new];
    }
    return _rowHeight;
}

- (XSBrowserAnimateDelegate *)browserAnimateDelegate {
    if (!_browserAnimateDelegate) {
        _browserAnimateDelegate = [XSBrowserAnimateDelegate shareInstance];
    }
    return _browserAnimateDelegate;
}

@end
