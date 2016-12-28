//
//  LHChatInputView.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHChatBarView.h"
#import "KeyboardEmojiTextView.h"
#import "LHChatBarMoreView.h"
#import "KeyboardVC.h"
#import "LHContentModel.h"
#import "LHTools.h"
#import "TZImagePickerController.h"

CGFloat const kChatInputTextViewFont = 16.0f;
CGFloat const kChatEmojiHeight = 216.0f;
CGFloat const kChatMoreHeight = 130.0f;
CGFloat const kChatBatItemWH = 26.0f;

@interface LHChatBarView () <UITextViewDelegate, LHChatBarMoreViewDelegate,TZImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIViewAnimationCurve _animationCurve;
    CGFloat _animationDuration;
    CGFloat _keyboardHeight;
}

@property (nonatomic, strong) KeyboardEmojiTextView *textView;
@property (nonatomic, strong) UIButton *emojiBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) LHChatBarMoreView *moreView;
@property (nonatomic, strong) UIView *emojiView;
@property (nonatomic, strong) KeyboardVC *emojiKeyboardVC;

/** 是否正在切换键盘emoji */
@property (nonatomic, assign, getter=isEmojiKeyboard) BOOL emojiKeyboard;
/** 是否正在切换键盘more */
@property (nonatomic, assign, getter=isMoreKeyboard) BOOL moreKeyboard;
/** 是否系统键盘显示 */
@property (nonatomic, assign, getter=isShowingSystemKeyboard) BOOL showingSystemKeyboard;

@property (nonatomic, strong) LHPhotosModel *photos;
@property (nonatomic, strong) LHContentModel *contentModel;

@end

@implementation LHChatBarView


#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
        [self setupConfig];
    }
    return self;
}

- (void)setupSubViews {
    [self addSubview:self.textView];
    [self addSubview:self.emojiBtn];
    [self addSubview:self.moreBtn];
}

- (void)setupConfig {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.emojiBtn.frame = CGRectMake(10, self.height - kChatBatItemWH - 11, kChatBatItemWH, kChatBatItemWH);
    
    self.moreBtn.frame = CGRectMake(CGRectGetMaxX(self.emojiBtn.frame) + 10, self.height - kChatBatItemWH - 11, kChatBatItemWH, kChatBatItemWH);
    
    CGFloat textViewX = CGRectGetMaxX(self.moreBtn.frame) + 10;
    self.textView.frame = CGRectMake(textViewX, 7.5, SCREEN_W - textViewX - 10, self.height - 15);
}

#pragma mark - 事件监听
/**
 *  键盘弹出
 *
 *  @param notice 通知
 */
- (void)keyboardWillShow:(NSNotification *)notice {
    self.showingSystemKeyboard = YES;
    self.moreBtn.selected = NO;
    self.emojiBtn.selected = NO;
    
    NSDictionary *userInfo = [notice userInfo];
    CGRect endFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = (endFrame.origin.y != SCREEN_H) ? endFrame.size.height:0;
    if (!_keyboardHeight) return;
    
    CGRect beginRect = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if(!(beginRect.size.height > 0 && ( fabs(beginRect.origin.y - endRect.origin.y) > 0))) return;
    
    _animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    _animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        // 修改frame
        self.y = SCREEN_H - self.height - _keyboardHeight;
        _tableView.height = self.y - kNavBarHeight;
//        [_conversationChatVC scrollToBottomAnimated:NO refresh:NO];
    } completion:nil];
    
    // 添加动画
    if (self.emojiKeyboard) { // 当前展示的是表情键盘
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            self.emojiView.y = SCREEN_H - kChatEmojiHeight;
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.emojiView.y = SCREEN_H;
            self.moreView.y = SCREEN_H - kChatMoreHeight;
            [self.emojiView removeFromSuperview];
        }];
        
    } else if (self.isMoreKeyboard) { // 当前展示的是工具
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            self.moreView.y = SCREEN_H - kChatMoreHeight;
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.moreView removeFromSuperview];
        }];
    }
}


- (void)keyboardWillHide:(NSNotification *)noti {
    self.showingSystemKeyboard = NO;
    if (self.emojiBtn.selected || self.moreBtn.selected) return;
    self.moreBtn.selected = NO;
    self.emojiBtn.selected = NO;
    
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardHeight = [aValue CGRectValue].size.height;
    
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0 options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.y = SCREEN_H - self.height;
        _tableView.height = self.y - kNavBarHeight;
    } completion:nil];
}


// 点击表情按钮
- (void)emojiBtnClick:(UIButton *)emojiBtn {
    [self.moreView removeFromSuperview];
    self.moreKeyboard = NO;
    UIView *emojiView = self.emojiView;
    if (self.moreBtn.selected) { // 工具+有选中
        self.emojiBtn.selected = YES;
        self.emojiKeyboard= YES;
        if (!self.isShowingSystemKeyboard) {
            self.moreView.y = SCREEN_H;
        }
        
        
        self.moreBtn.selected = NO;
        [self.superview addSubview:emojiView];
        // 2.更改inputToolBar 底部约束
        // 添加动画
        [UIView animateWithDuration:0.25 animations:^{
            self.y = SCREEN_H - kChatEmojiHeight - self.height;
            _tableView.height = self.y - kNavBarHeight;
            
            emojiView.y = SCREEN_H - kChatEmojiHeight;
        }];
        
    } else { // 工具+没有选中
        emojiBtn.selected = !emojiBtn.selected;
        if (emojiBtn.selected) {
            // 让vioce声音按钮,取消选择,隐藏录音按钮
            //            [self setVioceRecordStates];
            if (!self.isShowingSystemKeyboard) {
                self.emojiView.y = SCREEN_H;
            }
            
            [self.textView resignFirstResponder];
            self.emojiKeyboard = YES;
            [self.superview addSubview:emojiView];
            // 2.更改inputToolBar 底部约束
            
            
            // 添加动画
            [UIView animateWithDuration:0.25 animations:^{
                self.y = SCREEN_H - kChatEmojiHeight - self.height;
                _tableView.height = self.y - kNavBarHeight;
                
                emojiView.y = SCREEN_H - kChatEmojiHeight;
                // 4.把消息现在在顶部
                //                [self scrollToBottom:NO];
//                [_conversationChatVC scrollToBottomAnimated:NO refresh:NO];
            }];
        } else {
            self.emojiKeyboard = YES;
            [self.textView becomeFirstResponder];
        }
    }
}

// 点击工具按钮
- (void)moreBtnClick:(UIButton *)moreBtn {
    
    [self.emojiView removeFromSuperview];
    self.emojiKeyboard = NO;
    UIView *moreView = self.moreView;
    
    if (self.emojiBtn.selected) { // 表情键盘有选中
        self.moreBtn.selected = YES;
        self.moreKeyboard = YES;
        if (!self.showingSystemKeyboard) {
            self.moreView.y = SCREEN_H;
        }
        
        self.emojiView.y = SCREEN_H;
        self.emojiBtn.selected = NO;
        [self.superview addSubview:moreView];
        // 2.更改inputToolBar 底部约束
        
        
        // 添加动画
        [UIView animateWithDuration:0.25 animations:^{
            self.y = SCREEN_H - kChatMoreHeight - self.height;
            _tableView.height = self.y - kNavBarHeight;
            moreView.y = SCREEN_H - kChatMoreHeight;
        }];
        
    } else { // 表情键盘没有选择
        moreBtn.selected = !moreBtn.selected;
        if (moreBtn.selected) {
            // 让vioce声音按钮,取消选择,隐藏录音按钮
            
            if (!self.showingSystemKeyboard) {
                self.moreView.y = SCREEN_H;
            }
            [self.textView resignFirstResponder];
            self.moreKeyboard = YES;
            [self.superview addSubview:moreView];
            // 2.更改inputToolBar 底部约束
            
            
            // 添加动画
            [UIView animateWithDuration:0.25 animations:^{
                self.y = SCREEN_H - kChatMoreHeight - self.height;
                _tableView.height = self.y - kNavBarHeight;
                
                moreView.y = SCREEN_H - kChatMoreHeight;
                // 4.把消息现在在顶部
//                [_conversationChatVC scrollToBottomAnimated:NO refresh:NO];
            }];
            
        } else {
            self.moreKeyboard = YES;
            [self.textView becomeFirstResponder];
        }
    }
}

#pragma mark - 公共方法
- (void)hideKeyboard {
    [self.superview endEditing:YES];
    
    // 添加动画
    [UIView animateWithDuration:0.25 animations:^{
        if (self.showingSystemKeyboard || self.emojiBtn.selected || self.moreBtn.selected) {
            self.moreView.y = SCREEN_H;
            self.emojiView.y = SCREEN_H;
        }
        self.y = SCREEN_H - self.height;
        _tableView.height = self.y - kNavBarHeight;
    } completion:^(BOOL finished) {
    }];
    self.moreBtn.selected = NO;
    self.emojiBtn.selected = NO;
}

#pragma mark - 私有方法
//重置状态
- (void)resetState {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.height = kChatBarHeight;
        CGFloat keyboardHeight = _keyboardHeight;
        if (self.moreBtn.selected) {
            keyboardHeight = kChatMoreHeight;
        }
        else if (self.emojiBtn.selected) {
            keyboardHeight = kChatEmojiHeight;
        }
        self.y = SCREEN_H - self.height - keyboardHeight;
        _tableView.height = self.y - kNavBarHeight;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!finished) return;
        self.contentModel = nil;
        _textView.text = @"";
        self.photos = nil;
    }];
}

- (NSRange)isPresenceExpressionWithText:(NSString *)text {
    NSInteger length = text.length;
    
    NSArray *array = [self emojiArrayWithText:text];
    
    NSInteger index = array.count;
    if (!index) return NSMakeRange(0, 0);
    while (index > 0) {
        index --;
        NSTextCheckingResult *result = array[index];
        if (length == result.range.location + result.range.length) {
            return result.range;
        }
    }
    return NSMakeRange(0, 0);
}

- (NSArray *)emojiArrayWithText:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\w+\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    return [regex matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
}


- (void)deleteEmoji:(NSString *)text range:(NSRange)range {
    text = [text substringToIndex:range.location];
    self.textView.text = text;
    [self textViewDidChange:self.textView];
}

#pragma mark - LHChatBarMoreViewDelegate
- (void)moreViewTakePicAction:(LHChatBarMoreView *)moreView {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:@"设备没有摄像头"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles: nil];
        [alertView show];
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if (![LHTools cameraLimit]) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请在iPhone的\"设置-隐私-相机\"选项中,允许LHChatUI访问你的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        [self.viewController presentViewController:picker animated:YES completion:nil];
    }
}


- (void)moreViewPhotoAction:(LHChatBarMoreView *)moreVie {
    if (![LHTools photoLimit]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请在iPhone的\"设置-隐私-照片\"选项中,允许LHChatUI访问你的照片" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.alwaysEnableDoneBtn = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    
    static CGFloat maxHeight = 80.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight) {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
        [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-7.5, textView.contentSize.width, 10) animated:NO];
    } else {
        textView.scrollEnabled = NO;    // 不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
    }
    
    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        // 调整整个InputToolBar 的高度
        self.height = (15 + size.height) - kChatBarHeight < 5 ? kChatBarHeight : 15 + size.height;
        CGFloat keyboardHeight = _keyboardHeight;
        if (self.moreBtn.selected) {
            keyboardHeight = kChatMoreHeight;
        }
        else if (self.emojiBtn.selected) {
            keyboardHeight = kChatEmojiHeight;
        }
        
        self.y = SCREEN_H - self.height - keyboardHeight;
        _tableView.height = self.y - kNavBarHeight;
        [self layoutIfNeeded];
    } completion:nil];
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!text.length) {
        NSRange range = [self isPresenceExpressionWithText:textView.text];
        if (range.length) {
            [self deleteEmoji:textView.text range:range];
            return NO;
        }
        return YES;
    }
    else {
        // 判断按了return(send) 调用发送内容的方法
        if ([text isEqualToString:@"\n"]) {
            !self.sendContent ? : self.sendContent(self.contentModel);
            [self resetState];
            return NO;
        }
        return YES;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 发送拍摄图片
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.photos = [LHPhotosModel photosModelWitiPhotos:@[orgImage] originalPhoto:NO];
    !self.sendContent ? : self.sendContent(self.contentModel);
    [self resetState];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TZImagePickerControllerDelegate
// 相册选的图片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    self.photos = [LHPhotosModel photosModelWitiPhotos:photos originalPhoto:isSelectOriginalPhoto];
    !self.sendContent ? : self.sendContent(self.contentModel);
    [self resetState];
}


#pragma mark - lazy
- (KeyboardEmojiTextView *)textView {
    if (!_textView) {
        LHWeakSelf
        _textView = [KeyboardEmojiTextView new];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:kChatInputTextViewFont];
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.layer.borderColor = [UIColor lh_colorWithHex:0xe1e1e5].CGColor;
        _textView.layer.borderWidth = 0.5;
        _textView.showsVerticalScrollIndicator = YES;
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.layer.cornerRadius = 5;
        _textView.insertEmojiTextBlock = ^(UITextView *textView) {
            [weakSelf textViewDidChange:textView];
        };
        _textView.layoutManager.allowsNonContiguousLayout = NO;
    }
    return _textView;
}

- (UIButton *)emojiBtn {
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiBtn setImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"IM_Chat_expression"]] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"IM_Chat_keyboard"]] forState:UIControlStateSelected];
        [_emojiBtn addTarget:self action:@selector(emojiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"IM_Chat_more"]] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSString alloc] initWithFormat:@"%@/%@",recourcesPath,@"IM_Chat_keyboard"]] forState:UIControlStateSelected];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (LHChatBarMoreView *)moreView {
    if (!_moreView) {
        _moreView = [[LHChatBarMoreView alloc]initWithFrame:CGRectMake(0, SCREEN_H, SCREEN_W, kChatMoreHeight)];
        _moreView.backgroundColor = [UIColor lh_colorWithHex:0xf8f8f8];
        _moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _moreView.delegate = self;
        [self.superview addSubview:_moreView];
    }
    return _moreView;
}

- (UIView *)emojiView {
    if (!_emojiView) {
        _emojiView = self.emojiKeyboardVC.view;
        _emojiView.frame = CGRectMake(0, SCREEN_H, SCREEN_W, kChatEmojiHeight);
        [self.emojiKeyboardVC.view layoutIfNeeded];
        [self.superview addSubview:_emojiView];
    }
    return _emojiView;
}

- (KeyboardVC *)emojiKeyboardVC {
    if (!_emojiKeyboardVC) {
        LHWeakSelf;
        _emojiKeyboardVC = [[KeyboardVC alloc] initWithCallBack:^(KeyboardEmojiModel *keyboardEmoticon) {
            [weakSelf.textView insertEmojiText:keyboardEmoticon];
        }];
        _emojiKeyboardVC.emojiSend = ^() {
            !weakSelf.sendContent ? : weakSelf.sendContent(weakSelf.contentModel);
            [weakSelf resetState];
        };
    }
    return _emojiKeyboardVC;
}

- (LHContentModel *)contentModel {
    return [LHContentModel contentModelWitiPhotos:self.photos words:self.textView.text];
}

@end
