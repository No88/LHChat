//
//  KeyboardVC.m
//  keyboardEmotion
//
//  Created by lenhart on 16/7/11.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "KeyboardVC.h"
#import "KeyboardEmojiModel.h"
#import "KeyboardEmojiPackage.h"
#import "KeyboardButton.h"

#pragma mark - 自定义表情cell
@interface KeyboardEmojiCell: UICollectionViewCell
/** 表情模型 */
@property (nonatomic, strong) KeyboardEmojiModel *emotion;


@property (nonatomic, strong) KeyboardButton *emojiButton;


+ (NSString *)identifier;
@end

@implementation KeyboardEmojiCell

- (void)setEmotion:(KeyboardEmojiModel *)emotion {
    UIImage *image = [UIImage imageWithContentsOfFile:emotion.imagePath];
    [self.emojiButton setImage:image forState:UIControlStateNormal];
    [self.emojiButton setTitle:emotion.code forState:UIControlStateNormal];
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.emojiButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.emojiButton.frame = CGRectInset(self.bounds, 4, 4);
}


+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}


#pragma mark - lazy
- (KeyboardButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [KeyboardButton new];
        _emojiButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_emojiButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _emojiButton.userInteractionEnabled = NO;
    }
    return _emojiButton;
}

@end


#pragma mark - 自定义布局
@interface KeyboardEmojiLayout: UICollectionViewFlowLayout

@end

@implementation KeyboardEmojiLayout

- (void)prepareLayout {
    CGFloat itemWith = [UIScreen mainScreen].bounds.size.width / 4;
    CGFloat itemHeight = 55;
    self.itemSize = CGSizeMake(itemWith, itemHeight);
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
//    self.collectionView.bounces = NO;
    
    // 让cell居中显示
    CGFloat offsetY = (self.collectionView.bounds.size.height - (2 * itemHeight)) * 0.48;
    self.collectionView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, offsetY);
}

@end



#pragma mark - 工具栏
@interface KeyboardToolBar: UIView

@property (nonatomic, strong) void (^emojiSend)();

@end

@implementation KeyboardToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor lh_colorWithHex:0xe1e1e5];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:lineView];
        
        UIScrollView *scrollView = [UIScrollView new];
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.bounces = NO;
        [self addSubview:scrollView];
        
        NSArray *images = @[@"Keyboard_first_emoticon"];
        CGFloat itemX = 0;
        CGFloat itemY = 0;
        CGFloat itemW = 62;
        CGFloat itemH = 37;
        UIImage *image = [UIImage lh_imageWithColor:[UIColor lh_colorWithHex:0xf2f2f6]];
        for (NSInteger i = 0; i < images.count; i++) {
            UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
            item.tag = i;
            itemX = i * itemW;
            item.frame = CGRectMake(itemX, itemY, itemW, itemH);
            
            [item setImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,images[i]]] forState:UIControlStateNormal];
            [item setBackgroundImage:image forState:UIControlStateSelected];
            [item setBackgroundImage:image forState:UIControlStateHighlighted];
            item.selected = !i;
            [scrollView addSubview:item];
        }
        scrollView.contentSize = CGSizeMake(images.count * itemW, 0);
        
        UIImageView *gradientMask = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"Keyboard_gradient_mask"]]];
        gradientMask.contentMode = UIViewContentModeRight;
        gradientMask.backgroundColor = [UIColor clearColor];
        gradientMask.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:gradientMask];
        
        UIButton *sendButotn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButotn.translatesAutoresizingMaskIntoConstraints = NO;
        sendButotn.titleLabel.font = [UIFont systemFontOfSize:15];
        [sendButotn setTitle:@"发送" forState:UIControlStateNormal];
        [sendButotn setTitleColor:[UIColor lh_colorWithHex:0xffffff] forState:UIControlStateNormal];
        [sendButotn setBackgroundImage:[UIImage lh_imageWithColor:[UIColor lh_colorWithHex:0x4285f4 alpha:0.3]] forState:UIControlStateHighlighted];
        [sendButotn setBackgroundImage:[UIImage lh_imageWithColor:[UIColor lh_colorWithHex:0x4285f4]] forState:UIControlStateNormal];
        [sendButotn addTarget:self action:@selector(sendClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButotn];
        
        NSDictionary *dict = @{@"lineView" : lineView,
                               @"scrollView" : scrollView,
                               @"gradientMask" : gradientMask,
                               @"sendButotn" : sendButotn};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lineView]-62-|" options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-[sendButotn(62)]-0-|" options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[gradientMask]-0-[sendButotn(62)]-0-|" options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lineView(0.5)]-0-|" options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|" options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[sendButotn]-0-|" options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0.5-[gradientMask]-0-|" options:0 metrics:nil views:dict]];
    }
    return self;
}

- (void)sendClick {
    !self.emojiSend ? : self.emojiSend();
}

@end


#pragma mark - KeyboardVC

@interface KeyboardVC () <UICollectionViewDelegate, UICollectionViewDataSource>


@property (nonatomic, strong) UICollectionView *collectionVeiw;
/** 所有配图 */
@property (nonatomic, strong) NSArray *packages;
@property (nonatomic, strong) UIPageControl *pageControl;
/** 工具栏 */
@property (nonatomic, strong) KeyboardToolBar *toolBarView;
@end

@implementation KeyboardVC

- (instancetype)initWithCallBack:(EmojiCallBack)callBack {
    if (self = [super init]) {
        self.emojiCallBack = callBack;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInit];
}

- (void)setupInit {
    self.view.backgroundColor = [UIColor lh_colorWithHex:0xf2f2f6];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor lh_colorWithHex:0xe1e1e5];
    lineView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:lineView];
    
    [self.view addSubview:self.collectionVeiw];
    self.collectionVeiw.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.pageControl];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.toolBarView];
    self.toolBarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *dict = @{@"lineView" : lineView,
                           @"collectionVeiw" : self.collectionVeiw,
                           @"pageControl" : self.pageControl,
                           @"toolBarView" : self.toolBarView};
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lineView]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionVeiw]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[pageControl]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolBarView]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lineView(0.5)]-0-[collectionVeiw]-13-[pageControl(7)]-7-[toolBarView(37)]-0-|" options:0 metrics:nil views:dict]];
    
}

#pragma mark - lazy 
- (UICollectionView *)collectionVeiw {
    if (!_collectionVeiw) {
        _collectionVeiw = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[KeyboardEmojiLayout alloc] init]];
        _collectionVeiw.backgroundColor = [UIColor clearColor];
        [_collectionVeiw registerClass:[KeyboardEmojiCell class] forCellWithReuseIdentifier:[KeyboardEmojiCell identifier]];
        _collectionVeiw.delegate = self;
        _collectionVeiw.dataSource = self;
    }
    return _collectionVeiw;
}

- (NSArray *)packages {
    if (!_packages) {
        _packages = [KeyboardEmojiPackage loadPackages];
    }
    return _packages;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        KeyboardEmojiPackage *package = self.packages.firstObject;
        _pageControl.numberOfPages = package.emojis.count / 8;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor lh_colorWithHex:0xe3e3e8];
        _pageControl.currentPageIndicatorTintColor = [UIColor lh_colorWithHex:0xbababf];
    }
    return _pageControl;
}

- (KeyboardToolBar *)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [KeyboardToolBar new];
        __weak KeyboardVC *weakKeyBoard = self;
        _toolBarView.emojiSend = ^() {
            !weakKeyBoard.emojiSend ? : weakKeyBoard.emojiSend();
        };
        _toolBarView.backgroundColor = [UIColor lh_colorWithHex:0xffffff];
    }
    return _toolBarView;
}

#pragma mark - 系统代理 UICollectionViewDataSource/ UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.packages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    KeyboardEmojiPackage *package = self.packages[section];
    return package.emojis.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KeyboardEmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KeyboardEmojiCell identifier] forIndexPath:indexPath];
    KeyboardEmojiPackage *package = self.packages[indexPath.section];
    cell.emotion = package.emojis[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KeyboardEmojiPackage *package = self.packages[indexPath.section];
    KeyboardEmojiModel *emotion = package.emojis[indexPath.item];
    
    !self.emojiCallBack ? : self.emojiCallBack(emotion);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    self.pageControl.currentPage = ABS(offsetX / [UIScreen mainScreen].bounds.size.width);
}

@end


